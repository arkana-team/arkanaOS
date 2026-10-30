"""Guard jbigkit's shared-library build against upstream recipe regressions."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class JbigkitSharedLibraryTests(unittest.TestCase):
    def test_recipe_builds_and_stages_the_jbigkit_shared_abi(self) -> None:
        recipe = (ROOT / "arkanas/06_graphics_ext.mk").read_text(encoding="utf-8")
        start = recipe.index(".libjbig-done:")
        end = recipe.index("download-xwayland:", start)
        jbig_recipe = recipe[start:end]

        self.assertNotIn("JBIG_KIT_PATCH_URL", recipe)
        self.assertNotIn("curl", jbig_recipe)
        self.assertIn("-fPIC -c jbig.c -o jbig.pic.o", jbig_recipe)
        self.assertIn("-fPIC -c jbig_ar.c -o jbig_ar.pic.o", jbig_recipe)
        self.assertIn("-fPIC -c jbig85.c -o jbig85.pic.o", jbig_recipe)
        self.assertIn("-Wl,-soname,libjbig.so.2.1", jbig_recipe)
        self.assertIn("install -m 0755 libjbig.so.2.1", jbig_recipe)
        self.assertIn("ln -sf libjbig.so.2.1", jbig_recipe)


if __name__ == "__main__":
    unittest.main()
