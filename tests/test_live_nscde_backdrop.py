"""Keep live NsCDE startup resilient when FVWM's backdrop module is delayed."""

from __future__ import annotations

import unittest
from pathlib import Path


REPOSITORY = Path(__file__).resolve().parents[1]


class LiveNsCDEBackdropTests(unittest.TestCase):
    def test_live_session_sets_backdrop_before_starting_nscde(self) -> None:
        session = (REPOSITORY / "xinitrc").read_text(encoding="utf-8")
        live_condition = session.index(
            "if [ -f /run/initramfs/bootdev/boot/rootfs.sfs ]; then"
        )
        live_end = session.index("\nfi", live_condition)
        live_block = session[live_condition:live_end]

        self.assertIn("export NSCDE_SKIP_FIRST_RUN=1", live_block)
        self.assertIn("command -v fvwm-root", live_block)
        self.assertIn('"$HOME/.NsCDE/backer/Desk1-Solyaris.pm"', live_block)
        self.assertIn("fvwm-root --retain-pixmap", live_block)
        self.assertLess(session.index("fvwm-root --retain-pixmap"), session.index("exec /usr/bin/nscde"))

    def test_installed_sessions_do_not_force_live_backdrop(self) -> None:
        session = (REPOSITORY / "xinitrc").read_text(encoding="utf-8")
        live_condition = session.index(
            "if [ -f /run/initramfs/bootdev/boot/rootfs.sfs ]; then"
        )
        live_end = session.index("\nfi", live_condition)

        self.assertNotIn("fvwm-root", session[live_end:])

    def test_iso_recipe_installs_the_live_session_backdrop(self) -> None:
        recipe = (REPOSITORY / "arkanas/07_iso.mk").read_text(encoding="utf-8")

        self.assertIn("$(ISO_ROOT_PATH)/root/.NsCDE/backer", recipe)
        self.assertIn(
            "$(ISO_ROOT_PATH)/root/.NsCDE/backer/Desk$$desk-Solyaris.pm", recipe
        )
        self.assertIn(
            "$(ISO_ROOT_PATH)/etc/skel/.NsCDE/backer/", recipe
        )


if __name__ == "__main__":
    unittest.main()
