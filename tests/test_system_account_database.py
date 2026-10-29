import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read_group_database():
    records = {}
    group_ids = set()
    for line in (ROOT / "group").read_text(encoding="utf-8").splitlines():
        name, _password, gid, _members = line.split(":", 3)
        if name in records:
            raise AssertionError(f"duplicate group name: {name}")
        if gid in group_ids:
            raise AssertionError(f"duplicate group ID: {gid}")
        records[name] = int(gid)
        group_ids.add(gid)
    return records


class SystemAccountDatabaseTests(unittest.TestCase):
    def test_udev_device_groups_exist(self):
        groups = read_group_database()
        self.assertTrue({"cdrom", "dialout", "tape"}.issubset(groups))

    def test_uuidd_account_has_a_matching_private_group(self):
        groups = read_group_database()
        users = {}
        for line in (ROOT / "passwd").read_text(encoding="utf-8").splitlines():
            name, _password, uid, gid, _gecos, _home, _shell = line.split(":", 6)
            users[name] = (int(uid), int(gid))

        self.assertIn("uuidd", users)
        self.assertEqual(users["uuidd"][0], groups["uuidd"])
        self.assertEqual(users["uuidd"][1], groups["uuidd"])

    def test_pam_stack_drops_modules_not_built_in_the_image(self):
        recipe = (ROOT / "arkanas/01_base.mk").read_text(encoding="utf-8")
        self.assertIn("/pam_selinux\\.so/d", recipe)
        self.assertIn("/pam_console\\.so/d", recipe)

    def test_pam_build_stamp_tracks_its_recipe_and_account_sources(self):
        recipe = (ROOT / "arkanas/01_base.mk").read_text(encoding="utf-8")
        self.assertIn(
            ".linux-pam-done: $(CURDIR)/arkanas/01_base.mk "
            "$(CURDIR)/passwd $(CURDIR)/shadow $(CURDIR)/group",
            recipe,
        )


if __name__ == "__main__":
    unittest.main()
