import os
import re
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
DETECTOR = REPO_ROOT / "scripts/detect-container.sh"
BUILD_SCRIPT = REPO_ROOT / "build.sh"


class BuildSafetyTests(unittest.TestCase):
    def setUp(self):
        self.tempdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tempdir.name)
        self.cgroup_file = self.root / "proc/1/cgroup"
        self.cgroup_file.parent.mkdir(parents=True)
        self.write_cgroup("0::/\n")

    def tearDown(self):
        self.tempdir.cleanup()

    def write_cgroup(self, content):
        self.cgroup_file.write_text(content)

    def detect(self, runtime=""):
        env = os.environ.copy()
        env.pop("container", None)
        env["ARKANA_CONTAINER_ROOT"] = str(self.root)
        env["ARKANA_CGROUP_FILE"] = str(self.cgroup_file)
        if runtime:
            env["container"] = runtime
        result = subprocess.run(
            [str(DETECTOR)], check=True, capture_output=True, text=True, env=env
        )
        return result.stdout.strip() == "true"

    def test_root_cgroup_view_alone_is_not_container_proof(self):
        self.write_cgroup("0::/\n")
        self.assertFalse(self.detect())

    def test_host_init_scope_is_not_detected_as_container(self):
        self.write_cgroup("0::/init.scope\n")
        self.assertFalse(self.detect())

    def test_docker_and_podman_markers_are_detected(self):
        (self.root / ".dockerenv").touch()
        self.assertTrue(self.detect())
        (self.root / ".dockerenv").unlink()
        (self.root / "run").mkdir()
        (self.root / "run/.containerenv").touch()
        self.assertTrue(self.detect())

    def test_runtime_environment_and_cgroup_paths_are_detected(self):
        self.assertTrue(self.detect(runtime="podman"))
        self.assertFalse(self.detect(runtime="host"))
        self.write_cgroup("0::/kubepods.slice/pod123/containerd-456.scope\n")
        self.assertTrue(self.detect())

    def test_make_guard_refuses_an_ambiguous_root_cgroup(self):
        env = os.environ.copy()
        env.pop("container", None)
        env.pop("FORCE", None)
        env["container"] = "host"
        env["ARKANA_CONTAINER_ROOT"] = str(self.root)
        env["ARKANA_CGROUP_FILE"] = str(self.cgroup_file)
        result = subprocess.run(
            ["make", "--no-print-directory", "-n"],
            cwd=DETECTOR.parents[1],
            capture_output=True,
            text=True,
            env=env,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("must run in a detected container", result.stderr)

    def test_build_script_passes_cpu_limit_to_make_and_ninja(self):
        with tempfile.TemporaryDirectory() as temporary:
            sandbox = Path(temporary)
            fake_bin = sandbox / "bin"
            fake_bin.mkdir()
            docker_log = sandbox / "docker-args.log"
            fake_docker = fake_bin / "docker"
            fake_docker.write_text(
                "#!/bin/sh\nprintf '%s\\n' \"$@\" >> \"$DOCKER_ARGS_LOG\"\n"
                "printf '%s\\n' '--end-call--' >> \"$DOCKER_ARGS_LOG\"\n"
            )
            fake_docker.chmod(0o755)

            env = os.environ.copy()
            env["PATH"] = f"{fake_bin}{os.pathsep}{env['PATH']}"
            env["DOCKER_ARGS_LOG"] = str(docker_log)
            env["ARKANA_BUILD_CPUS"] = "1"
            env["ARKANA_BUILD_RAM_MB"] = "512"
            env["ARKANA_BUILD_SWAP_MB"] = "0"
            result = subprocess.run(
                ["bash", str(BUILD_SCRIPT)],
                cwd=sandbox,
                check=True,
                capture_output=True,
                text=True,
                env=env,
            )

            calls = docker_log.read_text().split("--end-call--\n")
            self.assertEqual(len(calls), 3, result.stdout + result.stderr)
            run_arguments = calls[1].splitlines()
            self.assertIn("THREADS=1", run_arguments)
            self.assertIn("NINJAJOBS=1", run_arguments)

    def test_make_uses_the_thread_limit_from_its_environment(self):
        (self.root / ".dockerenv").touch()
        env = os.environ.copy()
        env["container"] = "host"
        env["ARKANA_CONTAINER_ROOT"] = str(self.root)
        env["ARKANA_CGROUP_FILE"] = str(self.cgroup_file)
        env["THREADS"] = "1"
        result = subprocess.run(
            ["make", "--no-print-directory", "-n", "-p", "check-libs"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            env=env,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertRegex(result.stdout, r"(?m)^THREADS = 1$")

    def test_ninja_recipe_commands_use_the_thread_limit(self):
        pattern = re.compile(r"(?<![\w./-])ninja(?=\s|$)")
        checked = 0
        for recipe in (REPO_ROOT / "arkanas").glob("*.mk"):
            for line_number, line in enumerate(recipe.read_text().splitlines(), 1):
                if not line.startswith("\t") or "install -m755 ninja " in line:
                    continue
                for match in pattern.finditer(line):
                    self.assertTrue(
                        line[match.end() :].startswith(" -j$(THREADS)"),
                        f"{recipe}:{line_number} has an uncapped ninja invocation",
                    )
                    checked += 1
        self.assertGreater(checked, 0)


if __name__ == "__main__":
    unittest.main()
