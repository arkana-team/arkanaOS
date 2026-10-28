#!/usr/bin/env python3
"""Verify that release signing and public keys form an Ed25519 keypair."""

from __future__ import annotations

import argparse
import base64
import os
import stat
import subprocess
import sys
from pathlib import Path

PKCS8_PREFIX = bytes.fromhex("302e020100300506032b657004220420")
SPKI_PREFIX = bytes.fromhex("302a300506032b6570032100")
MAX_KEY_FILE_BYTES = 256


def read_key(path: Path, *, private: bool) -> bytes:
    flags = os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0) | getattr(os, "O_CLOEXEC", 0)
    descriptor = os.open(path, flags)
    with os.fdopen(descriptor, "rb") as stream:
        metadata = os.fstat(stream.fileno())
        if not stat.S_ISREG(metadata.st_mode):
            raise ValueError(f"key file must be regular: {path}")
        if private and metadata.st_mode & 0o077:
            raise ValueError("signing key permissions must be no broader than 0600")
        if metadata.st_size > MAX_KEY_FILE_BYTES:
            raise ValueError(f"key file is too large: {path}")
        encoded = stream.read(MAX_KEY_FILE_BYTES + 1).strip()

    try:
        key = base64.b64decode(encoded, validate=True)
    except (ValueError, base64.binascii.Error) as error:
        raise ValueError(f"key file is not valid base64: {path}") from error
    if len(key) != 32:
        raise ValueError(f"key file must decode to exactly 32 bytes: {path}")
    return key


def verify_keypair(signing_path: Path, public_path: Path) -> None:
    signing_key = read_key(signing_path, private=True)
    public_key = read_key(public_path, private=False)
    result = subprocess.run(
        ["openssl", "pkey", "-inform", "DER", "-pubout", "-outform", "DER"],
        input=PKCS8_PREFIX + signing_key,
        capture_output=True,
        check=False,
        timeout=5,
    )
    if result.returncode != 0:
        raise ValueError("OpenSSL could not derive the public key from the signing key")
    if result.stdout != SPKI_PREFIX + public_key:
        raise ValueError("public key does not match the signing key")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("signing_key", type=Path)
    parser.add_argument("public_key", type=Path)
    args = parser.parse_args(argv)
    try:
        verify_keypair(args.signing_key, args.public_key)
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    print("valid Ed25519 update signing keypair")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
