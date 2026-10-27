import os
import subprocess
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
MAKEFILES = [
    "Makefile",
    "arkanas/01_base.mk",
    "arkanas/02_ext.mk",
    "arkanas/03_arkpkg.mk",
    "arkanas/04_toolchain.mk",
    "arkanas/05_graphics.mk",
    "arkanas/06_graphics_ext.mk",
    "arkanas/07_iso.mk",
]


class StagingRootSafetyTests(unittest.TestCase):
    def setUp(self):
        self.tempdir = tempfile.TemporaryDirectory()
        self.container_root = Path(self.tempdir.name)
        (self.container_root / ".dockerenv").touch()
        self.cgroup_file = self.container_root / "proc/1/cgroup"
        self.cgroup_file.parent.mkdir(parents=True)
        self.cgroup_file.write_text("0::/\n")
        self.env = os.environ.copy()
        self.env["container"] = "docker"
        self.env["ARKANA_CONTAINER_ROOT"] = str(self.container_root)
        self.env["ARKANA_CGROUP_FILE"] = str(self.cgroup_file)

    def tearDown(self):
        self.tempdir.cleanup()

    def test_every_build_makefile_rejects_command_line_staging_override(self):
        for makefile in MAKEFILES:
            with self.subTest(makefile=makefile):
                result = subprocess.run(
                    [
                        "make",
                        "--no-print-directory",
                        "-n",
                        "-f",
                        makefile,
                        "STAGING_PATH=/",
                    ],
                    check=False,
                    cwd=REPO_ROOT,
                    env=self.env,
                    capture_output=True,
                    text=True,
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("refusing STAGING_PATH override", result.stderr)

    def test_glibc_makefile_rejects_environment_staging_override(self):
        env = self.env.copy()
        env["STAGING_PATH"] = "/tmp/arkana-host-staging-override"
        result = subprocess.run(
            [
                "make",
                "--no-print-directory",
                "-n",
                "-f",
                "arkanas/01_base.mk",
            ],
            check=False,
            cwd=REPO_ROOT,
            env=env,
            capture_output=True,
            text=True,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("refusing STAGING_PATH override", result.stderr)

    def test_glibc_install_passes_the_target_root_as_install_root(self):
        makefile = (REPO_ROOT / "arkanas/01_base.mk").read_text(encoding="utf-8")
        self.assertIn(
            "$(MAKE) DESTDIR=$(STAGING_PATH) "
            "install_root=$(STAGING_PATH) install",
            makefile,
        )

    def test_iso_ldconfig_runs_only_inside_the_iso_root(self):
        makefile = (REPO_ROOT / "arkanas/07_iso.mk").read_text(encoding="utf-8")
        remove_cache = "rm -f $(ISO_ROOT_PATH)/etc/ld.so.cache"
        target_ldconfig = "chroot $(ISO_ROOT_PATH) /usr/bin/ldconfig"
        self.assertIn(remove_cache, makefile)
        self.assertIn(target_ldconfig, makefile)
        self.assertLess(makefile.index(remove_cache), makefile.index(target_ldconfig))

    def test_build_container_masks_host_ldconfig(self):
        dockerfile = (REPO_ROOT / "Dockerfile").read_text(encoding="utf-8")
        self.assertIn("ln -sf /bin/true /sbin/ldconfig", dockerfile)


if __name__ == "__main__":
    unittest.main()
