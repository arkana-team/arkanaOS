"""Keep target libraries available before staged tools execute in chroot."""

from __future__ import annotations

import re
import unittest
from pathlib import Path


ISO_RECIPE = Path(__file__).resolve().parents[1] / "arkanas" / "07_iso.mk"


def prerequisites_for(target: str, makefile: str) -> set[str]:
    match = re.search(rf"(?m)^{re.escape(target)}:\s*([^\n]*)$", makefile)
    if match is None:
        raise AssertionError(f"Make target not found: {target}")
    return set(match.group(1).split())


class IsoRuntimeDependencyTests(unittest.TestCase):
    def test_brotli_is_staged_before_grub_font_generation(self) -> None:
        makefile = ISO_RECIPE.read_text(encoding="utf-8")

        self.assertIn("brotli", prerequisites_for(".freetype-done", makefile))
        self.assertIn(
            ".freetype-done",
            prerequisites_for(".grub-$(GRUB_VER)-built", makefile),
        )
        self.assertIn(
            "chroot $(STAGING_PATH) /usr/bin/grub-mkfont",
            makefile,
        )


if __name__ == "__main__":
    unittest.main()
