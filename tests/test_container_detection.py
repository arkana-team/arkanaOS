import os
import subprocess
import tempfile
import unittest
from pathlib import Path


DETECTOR = Path(__file__).resolve().parents[1] / "scripts/detect-container.sh"


class ContainerDetectionTests(unittest.TestCase):
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


if __name__ == "__main__":
    unittest.main()
