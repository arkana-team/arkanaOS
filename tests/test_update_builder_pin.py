"""Keep the update script and container pinned to the same Arkup source."""

from __future__ import annotations

import unittest
from pathlib import Path

REPOSITORY = Path(__file__).resolve().parents[1]
ARKUP_COMMIT = "2df9786e00cf8a82b9ceecdae295972692ee653a"
ARKUP_REPOSITORY = "https://github.com/arkana-team/arkup.git"


class ArkupSourcePinTests(unittest.TestCase):
    def test_update_builder_uses_the_merged_upstream_arkup_revision(self) -> None:
        build_script = (REPOSITORY / "build-update.sh").read_text(encoding="utf-8")
        dockerfile = (REPOSITORY / "Dockerfile.update-builder").read_text(
            encoding="utf-8"
        )

        self.assertIn(f"ARKUP_GIT_REF=${{ARKUP_GIT_REF:-{ARKUP_COMMIT}}}", build_script)
        self.assertIn(f"ARG ARKUP_GIT_REF={ARKUP_COMMIT}", dockerfile)
        self.assertIn(f"ARG ARKUP_GIT_URL={ARKUP_REPOSITORY}", dockerfile)
        self.assertIn('--build-arg "ARKUP_GIT_REF=$ARKUP_GIT_REF"', build_script)


if __name__ == "__main__":
    unittest.main()
