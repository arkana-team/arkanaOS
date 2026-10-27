"""Ensure the ISO build includes the signed update client."""

from __future__ import annotations

import unittest
from pathlib import Path

REPOSITORY = Path(__file__).resolve().parents[1]
ARKUP_COMMIT = "ab6a1b7ee9321587b3ab1d371f56b04362ac35cb"
ARKUP_SHA256 = "64e3d9a9e259ce4a1094f589cdd61dc3d3540e714cdae8bec27adf3f12fd485a"


class ArkupSystemInstallTests(unittest.TestCase):
    def test_base_build_installs_the_verified_arkup_client(self) -> None:
        recipe = (REPOSITORY / "arkanas/03_arkpkg.mk").read_text(encoding="utf-8")

        self.assertIn("all: arkpkg arkcfg arkup", recipe)
        self.assertIn(f"ARKUP_VER = {ARKUP_COMMIT}", recipe)
        self.assertIn(
            "ARKUP_URL = https://github.com/arkana-team/arkup/archive/$(ARKUP_VER).tar.gz",
            recipe,
        )
        self.assertIn(f"ARKUP_SHA256 = {ARKUP_SHA256}", recipe)
        self.assertIn(
            "verify-arkup-source: $(SRC_PATH)/arkup-$(ARKUP_VER).tar.gz", recipe
        )
        self.assertIn("sha256sum -c -", recipe)
        self.assertIn(
            "test -f $(ARKUP_PATH)/Cargo.toml && test -f $(ARKUP_PATH)/Cargo.lock",
            recipe,
        )
        self.assertIn(
            "CARGO_BUILD_JOBS=1 CARGO_INCREMENTAL=0 cargo build --locked --release",
            recipe,
        )
        self.assertIn(
            "install -Dm755 $(ARKUP_PATH)/target/release/arkup $(STAGING_PATH)/usr/bin/arkup",
            recipe,
        )

    def test_update_builder_workflow_covers_the_system_install_recipe(self) -> None:
        workflow = (
            REPOSITORY / ".github/workflows/update-builder-tests.yml"
        ).read_text(encoding="utf-8")

        for path in (
            "arkanas/03_arkpkg.mk",
            "tests/test_arkup_system_install.py",
            "tests/test_update_builder_pin.py",
        ):
            with self.subTest(path=path):
                self.assertEqual(workflow.count(f'"{path}"'), 2)
        self.assertIn("-p 'test_update_builder*.py'", workflow)
        self.assertIn("-p 'test_arkup_system_install.py'", workflow)


if __name__ == "__main__":
    unittest.main()
