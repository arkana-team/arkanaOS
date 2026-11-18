"""Keep procps-ng on its signed, checksum-pinned upstream release archive."""

import re
import unittest
from pathlib import Path

REPOSITORY = Path(__file__).resolve().parents[1]
MAKEFILE = REPOSITORY / "arkanas/02_ext.mk"
EXPECTED_SHA256 = "c2e6d193cc78f84cd6ddb72aaf6d5c6a9162f0470e5992092057f5ff518562fa"


class ProcpsNgSourcePinTests(unittest.TestCase):
    def test_release_archive_hash_and_versioned_stamp_flow_are_pinned(self):
        makefile = MAKEFILE.read_text(encoding="utf-8")
        self.assertIn("PROCPS_NG_VER = 4.0.5", makefile)
        self.assertIn(
            "PROCPS_NG_URL = https://downloads.sourceforge.net/project/"
            "procps-ng/Production/procps-ng-$(PROCPS_NG_VER).tar.xz",
            makefile,
        )
        self.assertIn(f"PROCPS_NG_SHA256 = {EXPECTED_SHA256}", makefile)
        self.assertIn(
            "PROCPS_NG_PATH = $(SRC_PATH)/procps-ng-$(PROCPS_NG_VER)",
            makefile,
        )
        self.assertIn(
            "PROCPS_NG_OBTAINED_STAMP = "
            ".procps-ng-$(PROCPS_NG_VER)-verified-obtained",
            makefile,
        )
        self.assertIn(
            "PROCPS_NG_DONE_STAMP = .procps-ng-$(PROCPS_NG_VER)-done",
            makefile,
        )

        recipe = re.search(
            r"(?m)^\$\(PROCPS_NG_OBTAINED_STAMP\):\n(?P<body>(?:\t[^\n]*\n)+)",
            makefile,
        )
        self.assertIsNotNone(recipe)
        body = recipe.group("body")
        self.assertLess(body.index("wget "), body.index("sha256sum -c -"))
        self.assertLess(body.index("sha256sum -c -"), body.index("mv "))
        self.assertLess(body.index("mv "), body.index('rm -rf "$(PROCPS_NG_PATH)"'))
        self.assertLess(body.index('rm -rf "$(PROCPS_NG_PATH)"'), body.index("tar xf "))
        self.assertIn("download-procps-ng: $(PROCPS_NG_OBTAINED_STAMP)", makefile)
        self.assertIn(
            "$(PROCPS_NG_DONE_STAMP): $(PROCPS_NG_OBTAINED_STAMP)",
            makefile,
        )

        build_recipe = re.search(
            r"(?m)^\$\(PROCPS_NG_DONE_STAMP\):[^\n]*\n(?P<body>(?:\t[^\n]*\n)+)",
            makefile,
        )
        self.assertIsNotNone(build_recipe)
        self.assertIn("./configure", build_recipe.group("body"))
        self.assertNotIn("./autogen.sh", build_recipe.group("body"))


if __name__ == "__main__":
    unittest.main()
