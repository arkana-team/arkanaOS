"""Exercise the make-ca recipe against a local HTTPS server using real curl."""

import http.server
import os
import shlex
import shutil
import ssl
import subprocess
import tempfile
import threading
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CURL = shutil.which("curl")


@unittest.skipUnless(CURL and shutil.which("openssl") and shutil.which("make"),
                     "requires curl, openssl, and make")
class CaBundleDownloadTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temporary = tempfile.TemporaryDirectory()
        cls.addClassCleanup(cls.temporary.cleanup)
        cls.root = Path(cls.temporary.name)
        cls.cert = cls.root / "server.pem"
        key = cls.root / "server.key"
        subprocess.run(
            [
                "openssl", "req", "-x509", "-newkey", "rsa:2048", "-nodes",
                "-days", "1", "-subj", "/CN=curl.se",
                "-addext", "subjectAltName=DNS:curl.se",
                "-keyout", str(key), "-out", str(cls.cert),
            ],
            check=True, capture_output=True, timeout=30,
        )

        class Handler(http.server.BaseHTTPRequestHandler):
            def handle(self):
                try:
                    super().handle()
                except ConnectionResetError:
                    # A client rejecting the server certificate may reset the socket.
                    pass

            def do_GET(self):
                self.send_response(cls.status)
                self.send_header("Content-Length", str(len(cls.body)))
                self.end_headers()
                self.wfile.write(cls.body)

            def log_message(self, *args):
                pass

        cls.server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        cls.addClassCleanup(cls.server.server_close)
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(cls.cert, key)
        cls.server.socket = context.wrap_socket(cls.server.socket, server_side=True)
        thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        thread.start()
        cls.addClassCleanup(cls.server.shutdown)

    def setUp(self):
        temporary = tempfile.TemporaryDirectory(dir=self.root)
        self.addCleanup(temporary.cleanup)
        self.work = Path(temporary.name)
        (self.work / "arkanas").symlink_to(REPO_ROOT / "arkanas", target_is_directory=True)
        for directory in ("src", "staging", "output", "bin"):
            (self.work / directory).mkdir()
        (self.work / "src/Makefile").write_text("install:\n\t@:\n")
        # Redirect the connection while preserving the recipe's URL and TLS hostname.
        wrapper = self.work / "bin/curl"
        wrapper.write_text(
            f"#!/bin/sh\nexec {shlex.quote(CURL)} -q --noproxy '*' "
            f"--connect-to curl.se:443:127.0.0.1:{self.server.server_port} \"$@\"\n"
        )
        wrapper.chmod(0o755)
        self.bundle = self.work / "staging/etc/ssl/ca-bundle.crt"
        self.stamp = self.work / ".make-ca-done"
        type(self).body = self.cert.read_bytes()
        type(self).status = 200

    def run_recipe(self, trusted):
        env = os.environ.copy()
        for name in ("CURL_CA_BUNDLE", "SSL_CERT_FILE", "SSL_CERT_DIR", "STAGING_PATH"):
            env.pop(name, None)
        if trusted:
            env["CURL_CA_BUNDLE"] = str(self.cert)
        env["PATH"] = f"{self.work / 'bin'}{os.pathsep}{env['PATH']}"
        return subprocess.run(
            ["make", "--no-print-directory", "-f", "arkanas/02_ext.mk",
             ".make-ca-done", f"MAKE_CA_PATH={self.work / 'src'}"],
            cwd=self.work, env=env, capture_output=True, text=True, timeout=30,
        )

    def test_trusted_https_bundle_completes_the_recipe(self):
        result = self.run_recipe(trusted=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.bundle.read_bytes(), self.body)
        self.assertEqual(self.bundle.stat().st_mode & 0o777, 0o644)
        self.assertTrue(self.stamp.exists())

    def test_untrusted_certificate_cannot_install_a_bundle(self):
        result = self.run_recipe(trusted=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("curl: (60)", result.stderr)
        self.assertFalse(self.bundle.exists())
        self.assertFalse(self.stamp.exists())

    def test_http_errors_fail_the_recipe_without_installing_the_response(self):
        for status in (404, 500):
            with self.subTest(status=status):
                type(self).status = status
                result = self.run_recipe(trusted=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("curl: (22)", result.stderr)
                self.assertFalse(self.bundle.exists())
                self.assertFalse(self.stamp.exists())


if __name__ == "__main__":
    unittest.main()
