"""Guard Cairo's graphics-stage libpng dependency and ABI."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class CairoLibpngDependencyTests(unittest.TestCase):
    def test_graphics_stage_builds_pinned_versioned_libpng_before_cairo(self) -> None:
        recipe = (ROOT / "arkanas/05_graphics.mk").read_text(encoding="utf-8")
        all_targets = next(
            line for line in recipe.splitlines() if line.startswith("all:")
        )

        self.assertIn(
            "LIBPNG_SHA256 = 4df396518620a7aa3651443e87d1b2862e4e88cad135a8b93423e01706232307",
            recipe,
        )
        self.assertIn("LDFLAGS=\"-fuse-ld=bfd\"", recipe)
        self.assertIn("cairo: download-cairo libpng .cairo-done", recipe)
        self.assertIn("libpng cairo", all_targets)
        self.assertIn("--wrap-mode=nofallback", recipe)


if __name__ == "__main__":
    unittest.main()
