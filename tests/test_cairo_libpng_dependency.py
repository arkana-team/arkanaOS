"""Guard Cairo's graphics-stage libpng dependency and ABI."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class CairoLibpngDependencyTests(unittest.TestCase):
    def test_graphics_stage_builds_pinned_versioned_libpng_before_cairo(self) -> None:
        recipe = (ROOT / "arkanas/05_graphics.mk").read_text(encoding="utf-8")
        libpng = (ROOT / "arkanas/libpng.mk").read_text(encoding="utf-8")
        all_targets = next(
            line for line in recipe.splitlines() if line.startswith("all:")
        )

        self.assertIn(
            "LIBPNG_SHA256 = 4df396518620a7aa3651443e87d1b2862e4e88cad135a8b93423e01706232307",
            libpng,
        )
        self.assertIn(
            "LIBPNG_PATCH_SHA256 = 5b086fafe7e12784b28693e19a5bcf68677a8c52947115712a56c3d123944f6f",
            libpng,
        )
        self.assertIn("LDFLAGS=\"-fuse-ld=bfd\"", libpng)
        self.assertIn(
            "cairo: download-cairo libpng .cairo-$(CAIRO_VER)-libpng-done",
            recipe,
        )
        self.assertIn("libpng cairo", all_targets)
        self.assertIn("--wrap-mode=nofallback", recipe)
        self.assertIn("rm -rf $(CAIRO_PATH)/build", recipe)
        self.assertIn("include arkanas/libpng.mk", recipe)

    def test_iso_and_graphics_paths_share_verified_libpng_acquisition(self) -> None:
        graphics = (ROOT / "arkanas/05_graphics.mk").read_text(encoding="utf-8")
        iso = (ROOT / "arkanas/07_iso.mk").read_text(encoding="utf-8")
        libpng = (ROOT / "arkanas/libpng.mk").read_text(encoding="utf-8")
        self.assertIn("include arkanas/libpng.mk", graphics)
        self.assertIn("include arkanas/libpng.mk", iso)
        self.assertIn("cairo: download-cairo libpng .cairo-$(CAIRO_VER)-libpng-done", iso)
        self.assertIn("set -euo pipefail", libpng)
        self.assertIn("gzip -t \"$$patch_file\"", libpng)
        self.assertIn("touch \"$@\"", libpng)
        self.assertIn(".libpng-$(LIBPNG_VER)-obtained-verified", libpng)
        self.assertIn(".libpng-$(LIBPNG_VER)-bfd-done", libpng)
        self.assertNotIn(".libpng-obtained", libpng)
        self.assertNotIn(".libpng-done", libpng)

    def test_graphics_failure_artifact_includes_cmake_configure_log(self) -> None:
        workflow = (ROOT / ".github/workflows/03_stage3_graphics.yml").read_text(
            encoding="utf-8"
        )
        self.assertIn("*/build/CMakeFiles/CMakeConfigureLog.yaml", workflow)
        self.assertIn("src/*/build/CMakeFiles/CMakeConfigureLog.yaml", workflow)


if __name__ == "__main__":
    unittest.main()
