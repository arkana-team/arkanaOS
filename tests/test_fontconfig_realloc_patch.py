"""Ensure the bundled Fontconfig fix is applied before compiling the library."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class FontconfigReallocPatchTests(unittest.TestCase):
    def test_recipe_applies_the_pinned_upstream_fix_before_configure(self) -> None:
        recipe = (ROOT / "arkanas/05_graphics.mk").read_text(encoding="utf-8")
        patch = (ROOT / "patches/fontconfig-2.17.1-realloc-offset.patch").read_text(
            encoding="utf-8"
        )

        self.assertIn(
            "FONTCONFIG_REALLOC_PATCH = $(CURDIR)/patches/fontconfig-2.17.1-realloc-offset.patch",
            recipe,
        )
        self.assertIn(
            "if ! grep -qF 'uintptr_t    old_leaves = (uintptr_t)leaves;' src/fccharset.c",
            recipe,
        )
        self.assertIn("patch -Np1 -i $(FONTCONFIG_REALLOC_PATCH)", recipe)
        self.assertLess(
            recipe.index("patch -Np1 -i $(FONTCONFIG_REALLOC_PATCH)"),
            recipe.index('./configure CFLAGS="-O2 -std=gnu17"'),
        )
        self.assertIn("610cbdd43f27573be458f13d076ef01eb6d3b6e0", patch)
        self.assertIn("uintptr_t    old_leaves = (uintptr_t)leaves;", patch)
        self.assertIn("FcOffsetToPtr (old_leaves, new_leaves[i], FcCharLeaf)", patch)


if __name__ == "__main__":
    unittest.main()
