import os
import shlex
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


def shell_tokens(line):
    return set(shlex.split(line.rstrip().removesuffix("\\"), comments=True))


def ldconfig_command_lines(lines):
    calls = []
    for line in lines:
        if line.lstrip().startswith("#"):
            continue
        shell_line = line.rstrip().removesuffix("\\")
        lexer = shlex.shlex(shell_line, posix=True, punctuation_chars=";&|<>()")
        lexer.whitespace_split = True
        lexer.commenters = "#"
        if any(Path(token).name == "ldconfig" for token in lexer):
            calls.append(line.strip())
    return calls


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
        lines = makefile.splitlines()
        target_lines = [
            index for index, line in enumerate(lines) if line.strip() == ".glibc-done:"
        ]
        self.assertEqual(len(target_lines), 1)
        recipe_lines = []
        for line in lines[target_lines[0] + 1 :]:
            if line and not line[0].isspace() and not line.lstrip().startswith("#"):
                break
            if not line.lstrip().startswith("#"):
                recipe_lines.append(line)
        required_tokens = {
            "$(MAKE)",
            "DESTDIR=$(STAGING_PATH)",
            "install_root=$(STAGING_PATH)",
            "install",
        }
        active_commands = [
            shell_tokens(line)
            for line in recipe_lines
            if line.strip()
        ]
        self.assertTrue(
            any(required_tokens.issubset(tokens) for tokens in active_commands),
            "glibc install command must actively set DESTDIR and install_root",
        )
        self.assertFalse(
            required_tokens.issubset(
                shell_tokens(
                    "\t# $(MAKE) DESTDIR=$(STAGING_PATH) "
                    "install_root=$(STAGING_PATH) install"
                )
            ),
            "shell comments must not satisfy the active install check",
        )

    def test_iso_ldconfig_runs_only_inside_the_iso_root(self):
        makefile = (REPO_ROOT / "arkanas/07_iso.mk").read_text(encoding="utf-8")
        remove_cache = "rm -f $(ISO_ROOT_PATH)/etc/ld.so.cache"
        target_ldconfig = "chroot $(ISO_ROOT_PATH) /usr/bin/ldconfig"
        self.assertIn(remove_cache, makefile)
        self.assertIn(target_ldconfig, makefile)
        self.assertLess(makefile.index(remove_cache), makefile.index(target_ldconfig))
        ldconfig_calls = ldconfig_command_lines(makefile.splitlines())
        self.assertEqual(ldconfig_calls, [target_ldconfig])
        self.assertEqual(
            ldconfig_command_lines(["\t/sbin/ldconfig; true"]),
            ["/sbin/ldconfig; true"],
        )
        self.assertEqual(
            ldconfig_command_lines(
                ["\t./configure --disable-ldconfig-at-install", "\t# ldconfig"]
            ),
            [],
        )

    def test_build_container_masks_host_ldconfig(self):
        dockerfile = (REPO_ROOT / "Dockerfile").read_text(encoding="utf-8")
        run_commands = [
            line.strip()
            for line in dockerfile.splitlines()
            if line.lstrip().startswith("RUN ")
        ]
        self.assertTrue(
            any(
                command.startswith(
                    "RUN sudo ln -sf /bin/true /sbin/ldconfig &&"
                )
                for command in run_commands
            )
        )


if __name__ == "__main__":
    unittest.main()
