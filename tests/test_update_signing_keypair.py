"""Validate the Ed25519 keypair checker used by weekly releases."""

from __future__ import annotations

import base64
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPOSITORY = Path(__file__).resolve().parents[1]
CHECKER = REPOSITORY / "scripts/verify-update-signing-keypair.py"
RFC8032_SEED = bytes.fromhex(
    "9d61b19deffd5a60ba844af492ec2cc4"
    "4449c5697b326919703bac031cae7f60"
)
RFC8032_PUBLIC = bytes.fromhex(
    "d75a980182b10ab7d54bfed3c964073a"
    "0ee172f3daa62325af021a68f707511a"
)


class UpdateSigningKeypairTests(unittest.TestCase):
    def check_pair(self, signing_key: bytes, public_key: bytes) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory(prefix="arkup-keypair-test-") as temporary:
            root = Path(temporary)
            signing_path = root / "release.key"
            public_path = root / "release.pub"
            signing_path.write_text(base64.b64encode(signing_key).decode() + "\n")
            signing_path.chmod(0o600)
            public_path.write_text(base64.b64encode(public_key).decode() + "\n")
            public_path.chmod(0o600)
            return subprocess.run(
                [sys.executable, str(CHECKER), str(signing_path), str(public_path)],
                capture_output=True,
                text=True,
                timeout=10,
                check=False,
            )

    def test_accepts_matching_rfc8032_keypair(self) -> None:
        result = self.check_pair(RFC8032_SEED, RFC8032_PUBLIC)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_rejects_mismatched_public_key(self) -> None:
        mismatched_public = bytes([RFC8032_PUBLIC[0] ^ 1]) + RFC8032_PUBLIC[1:]
        result = self.check_pair(RFC8032_SEED, mismatched_public)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("does not match", result.stderr)

    def test_rejects_wrong_key_length(self) -> None:
        result = self.check_pair(RFC8032_SEED[:-1], RFC8032_PUBLIC)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("exactly 32 bytes", result.stderr)


if __name__ == "__main__":
    unittest.main()
