"""Keep target libraries available before staged tools execute in chroot."""

from __future__ import annotations

import re
import unittest
from pathlib import Path


ISO_RECIPE = Path(__file__).resolve().parents[1] / "arkanas" / "07_iso.mk"


def prerequisites_for(target: str, makefile: str) -> set[str]:
    """Return the whitespace-delimited prerequisites for one make target."""
    match = re.search(rf"(?m)^{re.escape(target)}:\s*([^\n]*)$", makefile)
    if match is None:
        raise AssertionError(f"Make target not found: {target}")
    normal_prerequisites = match.group(1).split("|", maxsplit=1)[0]
    return set(normal_prerequisites.split())


class IsoRuntimeDependencyTests(unittest.TestCase):
    def test_brotli_is_staged_before_grub_font_generation(self) -> None:
        makefile = ISO_RECIPE.read_text(encoding="utf-8")

        self.assertIn(
            "$(BROTLI_DONE_STAMP)",
            prerequisites_for(".freetype-done", makefile),
        )
        self.assertIn(
            "$(BROTLI_OBTAINED_STAMP)",
            prerequisites_for("$(BROTLI_DONE_STAMP)", makefile),
        )
        self.assertIn(
            ".freetype-done",
            prerequisites_for(".grub-$(GRUB_VER)-built", makefile),
        )
        self.assertIn(
            "chroot $(STAGING_PATH) /usr/bin/grub-mkfont",
            makefile,
        )

    def test_graphite2_is_staged_before_harfbuzz_configuration(self) -> None:
        makefile = ISO_RECIPE.read_text(encoding="utf-8")

        self.assertIn(
            "$(GRAPHITE2_DONE_STAMP)",
            prerequisites_for("$(HARFBUZZ_DONE_STAMP)", makefile),
        )
        self.assertIn(
            "$(GRAPHITE2_OBTAINED_STAMP)",
            prerequisites_for("$(GRAPHITE2_DONE_STAMP)", makefile),
        )
        self.assertIn(
            "$(HARFBUZZ_OBTAINED_STAMP)",
            prerequisites_for("$(HARFBUZZ_DONE_STAMP)", makefile),
        )
        self.assertIn(
            "HARFBUZZ_OBTAINED_STAMP = .harfbuzz-$(HARFBUZZ_VER)-obtained",
            makefile,
        )
        self.assertIn(
            "HARFBUZZ_DONE_STAMP = .harfbuzz-$(HARFBUZZ_VER)-done",
            makefile,
        )
        self.assertIn(
            "BROTLI_OBTAINED_STAMP = .brotli-$(BROTLI_VER)-obtained",
            makefile,
        )
        self.assertIn(
            "BROTLI_DONE_STAMP = .brotli-$(BROTLI_VER)-done",
            makefile,
        )
        self.assertIn(
            "GRAPHITE2_OBTAINED_STAMP = .graphite2-$(GRAPHITE2_VER)-obtained",
            makefile,
        )
        self.assertIn(
            "GRAPHITE2_DONE_STAMP = .graphite2-$(GRAPHITE2_VER)-done",
            makefile,
        )
        self.assertIn(
            "harfbuzz: download-harfbuzz $(HARFBUZZ_DONE_STAMP)",
            makefile,
        )
        self.assertIn(
            "download-harfbuzz: $(HARFBUZZ_OBTAINED_STAMP)",
            makefile,
        )
        self.assertIn("-D graphite2=enabled", makefile)


if __name__ == "__main__":
    unittest.main()
