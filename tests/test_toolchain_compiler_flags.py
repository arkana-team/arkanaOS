import re
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]


class ToolchainCompilerFlagTests(unittest.TestCase):
    def test_ksh93_passes_a_single_compiler_name_to_its_package_builder(self):
        recipe = (REPO_ROOT / "arkanas/05_graphics.mk").read_text(
            encoding="utf-8"
        )
        ksh_target = (
            recipe.split("ksh93: .ksh93-done", 1)[1]
            .split("# Install pure-Python desktop integration dependencies", 1)[0]
        )

        self.assertIn("AST_NO_DYLIB=y CC=gcc bin/package make", ksh_target)
        self.assertNotIn("bin/package CC=gcc", ksh_target)

    def test_graphics_cpp_recipes_use_a_cpp_language_standard(self):
        recipe = (REPO_ROOT / "arkanas/06_graphics_ext.mk").read_text(
            encoding="utf-8"
        )
        flags = re.findall(r'^\s*CXXFLAGS="([^"]+)"', recipe, re.MULTILINE)

        self.assertEqual(len(flags), 2)
        for value in flags:
            self.assertIn("-std=gnu++17", value)
            self.assertNotIn("-std=gnu17", value)

    def test_graphite2_uses_a_cpp_language_standard(self):
        recipe = (REPO_ROOT / "arkanas/07_iso.mk").read_text(encoding="utf-8")

        self.assertIn('CMAKE_CXX_FLAGS="-O2 -std=gnu++17"', recipe)
        self.assertNotIn('CMAKE_CXX_FLAGS="-O2 -std=gnu17"', recipe)

    def test_ninja_bootstrap_does_not_forward_c_only_flags_to_cpp(self):
        recipe = (REPO_ROOT / "arkanas/04_toolchain.mk").read_text(
            encoding="utf-8"
        )

        self.assertRegex(
            recipe,
            r'CFLAGS="-O2 -pipe" CXXFLAGS="-O2 -pipe -std=gnu\+\+17" '
            r'python3 configure\.py --bootstrap',
        )

    def test_cmake_bootstrap_disables_its_test_targets(self):
        recipe = (REPO_ROOT / "arkanas/04_toolchain.mk").read_text(
            encoding="utf-8"
        )
        cmake_target = (
            recipe.split("cmake: download-cmake .cmake-done", 1)[1]
            .split(".cmake-done:\n", 1)[1]
            .split("# Download gc", 1)[0]
        )

        bootstrap_command = cmake_target.split("&& $(MAKE)", 1)[0]
        self.assertIn("./bootstrap", bootstrap_command)
        self.assertIn("-- -DBUILD_TESTING:BOOL=OFF", bootstrap_command)
        self.assertLess(
            cmake_target.index("./bootstrap"),
            cmake_target.index("$(MAKE) -j$(THREADS)"),
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
