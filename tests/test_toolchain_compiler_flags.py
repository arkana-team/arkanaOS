from pathlib import Path
import re
import unittest


REPO_ROOT = Path(__file__).resolve().parents[1]


class ToolchainCompilerFlagTests(unittest.TestCase):
    def test_graphics_cpp_recipes_use_a_cpp_language_standard(self):
        recipe = (REPO_ROOT / "arkanas/06_graphics_ext.mk").read_text(
            encoding="utf-8"
        )
        flags = re.findall(r'^\s*CXXFLAGS="([^"]+)"', recipe, re.MULTILINE)

        self.assertEqual(len(flags), 2)
        for value in flags:
            self.assertIn("-std=gnu++17", value)
            self.assertNotIn("-std=gnu17", value)

    def test_ninja_bootstrap_does_not_forward_c_only_flags_to_cpp(self):
        recipe = (REPO_ROOT / "arkanas/04_toolchain.mk").read_text(
            encoding="utf-8"
        )

        self.assertRegex(
            recipe,
            r'CFLAGS="-O2 -pipe" CXXFLAGS="-O2 -pipe -std=gnu\+\+17" '
            r'python3 configure\.py --bootstrap',
        )

    def test_git_install_reuses_the_build_feature_and_linker_flags(self):
        recipe = (REPO_ROOT / "arkanas/04_toolchain.mk").read_text(
            encoding="utf-8"
        )
        git_target = (
            recipe.split("git: pkgconf download-git .git-done", 1)[1]
            .split(".git-done:\n", 1)[1]
            .split("\n.PHONY", 1)[0]
        )

        self.assertIn("$(GIT_BUILD_OPTIONS) all", git_target)
        self.assertIn(
            "$(GIT_BUILD_OPTIONS) DESTDIR=$(STAGING_PATH) install", git_target
        )
        for option in (
            "prefix=/usr",
            "CURL_CONFIG=$(STAGING_PATH)/usr/bin/curl-config",
            "USE_LIBPCRE2=YesPlease",
            "NO_GETTEXT=YesPlease",
            "NO_TCLTK=YesPlease",
            "NO_PYTHON=YesPlease",
            "NO_RUST=YesPlease",
            'CFLAGS="-O2 -std=gnu17"',
            "LDFLAGS=",
        ):
            with self.subTest(option=option):
                self.assertIn(option, recipe)


if __name__ == "__main__":
    unittest.main()
