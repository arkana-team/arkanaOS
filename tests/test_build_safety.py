import hashlib
import io
import os
import re
import shutil
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
DETECTOR = REPO_ROOT / "scripts/detect-container.sh"
BUILD_SCRIPT = REPO_ROOT / "build.sh"
ISO_MAKEFILE = REPO_ROOT / "arkanas/07_iso.mk"


class IsoRootBindingTests(unittest.TestCase):
    def test_iso_root_tmp_is_cleaned_and_restored_before_squashfs(self):
        recipe = ISO_MAKEFILE.read_text(encoding="utf-8")
        guard = recipe.index(
            'test "$(ISO_ROOT_PATH)" = "$(OUTPUT_PATH)/iso-root"'
        )
        cleanup = recipe.index('rm -rf -- "$(ISO_ROOT_PATH)/tmp"')
        recreate = recipe.index(
            'install -d -o 0 -g 0 -m 1777 "$(ISO_ROOT_PATH)/tmp"', cleanup
        )
        size_calculation = recipe.index("INSTALL_ROOT_BYTES=$$", recreate)
        squashfs = recipe.index("mksquashfs $(ISO_ROOT_PATH)", size_calculation)

        self.assertLess(guard, cleanup)
        self.assertLess(cleanup, recreate)
        self.assertLess(recreate, size_calculation)
        self.assertLess(size_calculation, squashfs)

    def test_make_rejects_custom_iso_root_during_parse(self):
        with tempfile.TemporaryDirectory() as temporary:
            custom_root = Path(temporary) / "custom-iso-root"
            result = subprocess.run(
                [
                    "make",
                    "--no-print-directory",
                    "-n",
                    "-f",
                    str(ISO_MAKEFILE),
                    "iso",
                    f"ISO_ROOT_PATH={custom_root}",
                ],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("refusing ISO_ROOT_PATH override", result.stderr)

    def test_iso_recipe_guard_rejects_symlinked_output_parent(self):
        with tempfile.TemporaryDirectory() as temporary:
            work = Path(temporary)
            outside = work / "outside"
            outside_root = outside / "iso-root"
            sentinel = outside_root / "sentinel"
            sentinel.parent.mkdir(parents=True)
            sentinel.write_text("keep", encoding="utf-8")
            (work / "output").symlink_to(outside, target_is_directory=True)

            recipe = ISO_MAKEFILE.read_text(encoding="utf-8")
            guard = next(
                line.strip()
                for line in recipe.splitlines()
                if line.strip().startswith("@test ")
                and "realpath -m --" in line
                and "ISO_ROOT_PATH" in line
            )
            command = (
                guard.removeprefix("@")
                .replace("$$", "$")
                .replace("$(ISO_ROOT_PATH)", "output/iso-root")
                .replace(
                    "$(ARKANA_CANONICAL_ISO_ROOT)",
                    str(work / "output/iso-root"),
                )
            )
            result = subprocess.run(
                ["bash", "-c", command],
                cwd=work,
                capture_output=True,
                text=True,
                check=False,
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertTrue(sentinel.is_file())


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

    def run_build_script(self, release_prefix=None, script=BUILD_SCRIPT):
        bin_dir = self.root / "bin"
        bin_dir.mkdir(exist_ok=True)
        docker = bin_dir / "docker"
        docker.write_text(
            "#!/bin/sh\nprintf '%s\\n' \"$*\" >> \"$DOCKER_LOG\"\n",
            encoding="utf-8",
        )
        docker.chmod(0o755)
        log = self.root / "docker.log"
        env = os.environ.copy()
        env.pop("ARKANA_RELEASE_PREFIX", None)
        if release_prefix is not None:
            env["ARKANA_RELEASE_PREFIX"] = release_prefix
        env.update(
            {
                "PATH": f"{bin_dir}{os.pathsep}{env['PATH']}",
                "DOCKER_LOG": str(log),
                "ARKANA_BUILD_CPUS": "1",
                "ARKANA_BUILD_RAM_MB": "512",
                "ARKANA_BUILD_SWAP_MB": "0",
            }
        )
        result = subprocess.run(
            [str(script)],
            cwd=self.root,
            env=env,
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
        return result, log

    def test_build_entrypoints_pass_the_alpha_prefix_and_allow_override(self):
        for script in (REPO_ROOT / "build", BUILD_SCRIPT):
            for requested, expected in ((None, "r1-a1"), ("nightly", "nightly")):
                with self.subTest(script=script.name, release_prefix=requested):
                    (self.root / "docker.log").unlink(missing_ok=True)
                    result, log = self.run_build_script(requested, script)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    invocations = log.read_text(encoding="utf-8").splitlines()
                    self.assertEqual(len(invocations), 2)
                    self.assertIn(
                        f"-e ARKANA_RELEASE_PREFIX={expected}", invocations[1]
                    )

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
        env["FORCE"] = "1"
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
        self.assertIn("refusing to build outside a detected container", result.stderr)

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


class LibfuseInstallSafetyTests(unittest.TestCase):
    def test_libfuse_install_is_rootless_and_stays_in_staging(self):
        makefile = (REPO_ROOT / "arkanas/01_base.mk").read_text(encoding="utf-8")
        start = makefile.index(".libfuse-done:")
        end = makefile.index("# Download D-Bus", start)
        recipe = makefile[start:end]

        self.assertEqual(recipe.count("-Duseroot=false"), 2)
        self.assertIn("-Dudevrulesdir=/usr/lib/udev/rules.d", recipe)
        self.assertIn("-Dinitscriptdir=", recipe)
        self.assertIn("meson setup --reconfigure", recipe)
        meson_commands = [
            line.strip() for line in recipe.splitlines() if "meson setup" in line
        ]
        self.assertEqual(len(meson_commands), 2)
        self.assertIn("--reconfigure", meson_commands[0])
        self.assertIn("-Dinitscriptdir=;", meson_commands[0])
        self.assertNotIn(" .;", meson_commands[0])
        self.assertNotIn(" ..;", meson_commands[0])
        self.assertNotIn("--reconfigure", meson_commands[1])
        self.assertIn("-Dinitscriptdir= ..;", meson_commands[1])
        self.assertIn("DESTDIR=$(STAGING_PATH) ninja -j$(THREADS) install", recipe)
        self.assertIn("chown root:root $(STAGING_PATH)/usr/bin/fusermount3", recipe)
        self.assertIn("chmod u+s $(STAGING_PATH)/usr/bin/fusermount3", recipe)


class LibndpSourceSafetyTests(unittest.TestCase):
    def setUp(self):
        self.tempdir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tempdir.cleanup)
        self.root = Path(self.tempdir.name)
        for directory in ("arkanas", "src", "staging", "output", "bin"):
            (self.root / directory).mkdir()
        for name in ("02_ext.mk", "staging-guard.mk"):
            shutil.copyfile(REPO_ROOT / "arkanas" / name, self.root / "arkanas" / name)

        self.release = self.root / "release.tar.gz"
        with tarfile.open(self.release, "w:gz") as archive:
            for name, content, mode in (
                ("configure", '#!/bin/sh\necho configure >> "$FLOW_LOG"\n', 0o755),
                ("Makefile", 'all:\n\t@echo build >> "$$FLOW_LOG"\n'
                 'install:\n\t@echo install >> "$$FLOW_LOG"\n', 0o644),
            ):
                data = content.encode()
                entry = tarfile.TarInfo(f"libndp-1.9/{name}")
                entry.size = len(data)
                entry.mode = mode
                archive.addfile(entry, io.BytesIO(data))
        self.digest = hashlib.sha256(self.release.read_bytes()).hexdigest()
        self.cached = self.root / "src/libndp-1.9.tar.gz"
        self.source = self.root / "src/libndp-1.9"
        self.flow_log = self.root / "flow.log"
        self.wget_log = self.root / "wget.log"
        wget = self.root / "bin/wget"
        wget.write_text(
            '#!/bin/sh\nprintf "%s\\n" "$@" >> "$WGET_LOG"\n'
            'while [ "$1" != "-O" ]; do shift; done\n'
            'cp "$RELEASE_ARCHIVE" "$2"\n'
        )
        wget.chmod(0o755)
        self.env = os.environ.copy()
        self.env.pop("STAGING_PATH", None)
        self.env.update({
            "PATH": f"{self.root / 'bin'}{os.pathsep}{self.env['PATH']}",
            "FLOW_LOG": str(self.flow_log),
            "WGET_LOG": str(self.wget_log),
            "RELEASE_ARCHIVE": str(self.release),
        })

    def run_libndp(self, target="libndp", fixture_digest=True):
        arguments = ["make", "--no-print-directory", "-f", "arkanas/02_ext.mk", target]
        if fixture_digest:
            arguments.append(f"LIBNDP_SHA256={self.digest}")
        return subprocess.run(
            arguments, cwd=self.root, env=self.env, capture_output=True,
            text=True, timeout=30, check=False,
        )

    def seed_legacy_source(self):
        self.source.mkdir()
        (self.source / "unverified-leftover").touch()
        configure = self.source / "configure"
        configure.write_text('#!/bin/sh\necho unverified >> "$FLOW_LOG"\nexit 1\n')
        configure.chmod(0o755)
        for stamp in (".libndp-obtained", ".libndp-done"):
            (self.root / stamp).touch()

    def test_download_uses_https_and_verified_build_is_incremental(self):
        result = self.run_libndp()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.flow_log.read_text().splitlines(), ["configure", "build", "install"])
        requests = self.wget_log.read_text()
        self.assertTrue(requests.splitlines()[-1].startswith("https://"))
        stamp = self.root / ".libndp-done"
        built_at = stamp.stat().st_mtime_ns

        result = self.run_libndp()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("libndp-1.9.tar.gz: OK", result.stdout)
        self.assertEqual(stamp.stat().st_mtime_ns, built_at)
        self.assertEqual(self.wget_log.read_text(), requests)
        self.assertEqual(self.flow_log.read_text().splitlines(), ["configure", "build", "install"])

    def test_untrusted_download_is_rejected_before_extraction(self):
        result = self.run_libndp(fixture_digest=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("FAILED", result.stdout)
        self.assertFalse(self.source.exists())
        self.assertFalse(self.flow_log.exists())
        self.assertFalse((self.root / ".libndp-verified-obtained").exists())
        self.assertFalse((self.root / ".libndp-done").exists())

    def test_legacy_source_is_replaced_before_direct_compile_target(self):
        shutil.copyfile(self.release, self.cached)
        self.seed_legacy_source()
        result = self.run_libndp(".libndp-done")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse((self.source / "unverified-leftover").exists())
        self.assertEqual(self.flow_log.read_text().splitlines(), ["configure", "build", "install"])
        self.assertFalse(self.wget_log.exists())

    def test_corrupt_legacy_cache_blocks_build_despite_old_stamps(self):
        self.cached.write_bytes(b"untrusted archive")
        self.seed_legacy_source()
        result = self.run_libndp()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("FAILED", result.stdout)
        self.assertFalse(self.flow_log.exists())
        self.assertFalse(self.wget_log.exists())
        self.assertFalse((self.root / ".libndp-verified-obtained").exists())

    def test_corrupt_cache_is_rejected_after_successful_build(self):
        result = self.run_libndp()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        previous_flow = self.flow_log.read_text()
        self.cached.write_bytes(b"corrupted cached archive")
        for target in ("download-libndp", "libndp", ".libndp-done"):
            with self.subTest(target=target):
                result = self.run_libndp(target)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("FAILED", result.stdout)
                self.assertEqual(self.flow_log.read_text(), previous_flow)


class GraphicsAndIsoSourceSafetyTests(unittest.TestCase):
    PACKAGES = (
        ("openbox", "3.6.1", "05_graphics.mk"),
        ("libisoburn", "1.5.6", "07_iso.mk"),
        ("libburn", "1.5.6", "07_iso.mk"),
        ("libisofs", "1.5.6", "07_iso.mk"),
    )

    def prepare(self, package, version, makefile):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.package = package
        self.makefile = makefile
        for directory in ("arkanas", "src", "staging/root", "output", "bin"):
            (self.root / directory).mkdir(parents=True)
        for name in (makefile, "staging-guard.mk"):
            shutil.copyfile(REPO_ROOT / "arkanas" / name, self.root / "arkanas" / name)
        (self.root / "xinitrc").touch()
        self.release = self.root / "release.tar.gz"
        with tarfile.open(self.release, "w:gz") as archive:
            for name, content, mode in (
                ("configure", '#!/bin/sh\necho configure >> "$FLOW_LOG"\n', 0o755),
                ("Makefile", 'all clean install:\n\t@echo $@ >> "$$FLOW_LOG"\n', 0o644),
                ("test/poll.c", "void catch_int () {}\n", 0o644),
            ):
                data = content.encode()
                entry = tarfile.TarInfo(f"{package}-{version}/{name}")
                entry.size = len(data)
                entry.mode = mode
                archive.addfile(entry, io.BytesIO(data))
        self.digest = hashlib.sha256(self.release.read_bytes()).hexdigest()
        self.cached = self.root / f"src/{package}-{version}.tar.gz"
        self.source = self.root / f"src/{package}-{version}"
        self.flow_log = self.root / "flow.log"
        self.wget_log = self.root / "wget.log"
        self.obtained = self.root / f".{package}-verified-obtained"
        self.done = self.root / f".{package}-done"
        wget = self.root / "bin/wget"
        wget.write_text(
            '#!/bin/sh\nprintf "%s\\n" "$@" >> "$WGET_LOG"\n'
            'while [ "$1" != "-O" ]; do shift; done\n'
            'cp "$RELEASE_ARCHIVE" "$2" || exit 1\n'
            'exit "${WGET_EXIT_CODE:-0}"\n'
        )
        wget.chmod(0o755)
        autoreconf = self.root / "bin/autoreconf"
        autoreconf.write_text('#!/bin/sh\necho autoreconf >> "$FLOW_LOG"\n')
        autoreconf.chmod(0o755)
        self.env = os.environ.copy()
        self.env.pop("STAGING_PATH", None)
        self.env.update({
            "PATH": f"{self.root / 'bin'}{os.pathsep}{self.env['PATH']}",
            "FLOW_LOG": str(self.flow_log),
            "WGET_LOG": str(self.wget_log),
            "RELEASE_ARCHIVE": str(self.release),
            "WGET_EXIT_CODE": "0",
        })

    def run_package(self, target=None, fixture_digest=True):
        arguments = ["make", "--no-print-directory", "-f", f"arkanas/{self.makefile}",
                     target or self.package]
        if self.package == "libisoburn":
            # Exercise this recipe independently of the libburn/libisofs builds.
            arguments.extend(["-o", "libburn", "-o", "libisofs"])
        if fixture_digest:
            arguments.append(f"{self.package.upper()}_SHA256={self.digest}")
        return subprocess.run(
            arguments, cwd=self.root, env=self.env, capture_output=True,
            text=True, timeout=30, check=False,
        )

    def seed_legacy_source(self):
        self.source.mkdir()
        (self.source / "unverified-leftover").touch()
        configure = self.source / "configure"
        configure.write_text('#!/bin/sh\necho unverified >> "$FLOW_LOG"\nexit 1\n')
        configure.chmod(0o755)
        (self.root / f".{self.package}-obtained").touch()
        self.done.touch()

    def assert_built(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        expected = ["configure", "all", "install"]
        if self.package == "openbox":
            expected.insert(0, "autoreconf")
        elif self.package == "libisoburn":
            expected.insert(1, "clean")
        self.assertEqual(self.flow_log.read_text().splitlines(), expected)
        self.assertTrue(self.obtained.exists())
        self.assertTrue(self.done.exists())

    def test_https_download_and_incremental_verified_build(self):
        for package in self.PACKAGES:
            with self.subTest(package=package[0]):
                self.prepare(*package)
                self.assert_built(self.run_package())
                requests = self.wget_log.read_text()
                self.assertTrue(requests.splitlines()[-1].startswith("https://"))
                built_at = self.done.stat().st_mtime_ns
                result = self.run_package()
                self.assert_built(result)
                self.assertIn(f"{self.cached.name}: OK", result.stdout)
                self.assertEqual(self.done.stat().st_mtime_ns, built_at)
                self.assertEqual(self.wget_log.read_text(), requests)

    def test_untrusted_download_is_rejected_before_extraction_or_build(self):
        for package in self.PACKAGES:
            with self.subTest(package=package[0]):
                self.prepare(*package)
                result = self.run_package(fixture_digest=False)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("FAILED", result.stdout)
                self.assertFalse(self.source.exists())
                self.assertFalse(self.flow_log.exists())
                self.assertFalse(self.obtained.exists())
                self.assertFalse(self.done.exists())

    def test_legacy_stamps_and_sources_cannot_bypass_verification(self):
        for package in self.PACKAGES:
            with self.subTest(package=package[0]):
                self.prepare(*package)
                shutil.copyfile(self.release, self.cached)
                self.seed_legacy_source()
                self.assert_built(self.run_package(self.done.name))
                self.assertFalse((self.source / "unverified-leftover").exists())
                self.assertFalse(self.wget_log.exists())

    def test_corrupt_legacy_cache_blocks_direct_compile_target(self):
        for package in self.PACKAGES:
            with self.subTest(package=package[0]):
                self.prepare(*package)
                self.cached.write_bytes(b"untrusted archive")
                self.seed_legacy_source()
                result = self.run_package(self.done.name)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("FAILED", result.stdout)
                self.assertFalse(self.flow_log.exists())
                self.assertFalse(self.obtained.exists())

    def test_corrupt_cache_blocks_all_targets_after_successful_build(self):
        for package in self.PACKAGES:
            with self.subTest(package=package[0]):
                self.prepare(*package)
                self.assert_built(self.run_package())
                previous_flow = self.flow_log.read_text()
                self.cached.write_bytes(b"corrupted cached archive")
                for target in (f"download-{self.package}", self.package, self.done.name):
                    result = self.run_package(target)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("FAILED", result.stdout)
                    self.assertEqual(self.flow_log.read_text(), previous_flow)

    def test_interrupted_download_is_not_cached_or_extracted(self):
        for package in self.PACKAGES:
            with self.subTest(package=package[0]):
                self.prepare(*package)
                self.env["WGET_EXIT_CODE"] = "1"
                result = self.run_package()
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(self.cached.exists())
                self.assertFalse(self.source.exists())
                self.assertFalse(self.obtained.exists())
                self.assertFalse(self.done.exists())
                self.env["WGET_EXIT_CODE"] = "0"
                self.assert_built(self.run_package())


if __name__ == "__main__":
    unittest.main()
