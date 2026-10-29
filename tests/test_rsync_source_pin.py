"""Keep rsync source fetches pinned to the upstream GitHub release asset."""

import re
import unittest
from pathlib import Path


REPOSITORY = Path(__file__).resolve().parents[1]
MAKEFILE = REPOSITORY / "arkanas/02_ext.mk"
EXPECTED_URL = (
    "https://github.com/RsyncProject/rsync/releases/download/"
    "v3.4.1/rsync-3.4.1.tar.gz"
)
EXPECTED_SHA256 = "2924bcb3a1ed8b551fc101f740b9f0fe0a202b115027647cf69850d65fd88c52"


class RsyncSourcePinTests(unittest.TestCase):
    def test_release_url_hash_and_verified_stamp_flow_are_pinned(self):
        makefile = MAKEFILE.read_text(encoding="utf-8")
        self.assertIn(f"RSYNC_URL = {EXPECTED_URL}", makefile)
        self.assertIn(f"RSYNC_SHA256 = {EXPECTED_SHA256}", makefile)

        recipe = re.search(
            r"(?ms)^\.rsync-verified-obtained:\n(?P<body>(?:\t.*\n)+)",
            makefile,
        )
        self.assertIsNotNone(recipe)
        body = recipe.group("body")
        self.assertLess(body.index("wget "), body.index("sha256sum -c -"))
        self.assertLess(
            body.index("sha256sum -c -"), body.index('rm -rf "$(RSYNC_PATH)"')
        )
        self.assertLess(
            body.index('rm -rf "$(RSYNC_PATH)"'), body.index("tar xf ")
        )
        self.assertIn("download-rsync: .rsync-verified-obtained", makefile)
        self.assertIn(".rsync-done: .rsync-verified-obtained", makefile)
        self.assertNotIn("download-rsync: .rsync-obtained", makefile)


if __name__ == "__main__":
    unittest.main()
