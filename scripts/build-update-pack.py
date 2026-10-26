#!/usr/bin/env python3
"""Build a signed arkup delta between two arkanaOS root trees."""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import shlex
import shutil
import stat
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path, PurePosixPath


SYSTEM_METADATA = (
    "etc/arkana-build-number",
    "etc/arkana-release-prefix",
    "etc/arkana-release-id",
    "etc/arkana-release-version",
    "etc/arkana-release-version-id",
    "etc/arkana-release-prerelease",
    "etc/os-release",
    "etc/issue",
)
CHUNK_SIZE = 1024 * 1024


class BuildError(Exception):
    """An input tree or update delta cannot be represented safely by arkup."""


@dataclass(frozen=True)
class Node:
    kind: str
    mode: int
    digest: str | None = None
    target: str | None = None


@dataclass(frozen=True)
class Tree:
    root: Path
    nodes: dict[str, Node]
    directories: dict[str, int]


@dataclass(frozen=True)
class Release:
    build: int
    prefix: str
    version: str
    version_id: str
    release_id: str
    display: str


def is_protected_path(relative: str) -> bool:
    """Match arkup's protected runtime and package-manager state paths."""
    parts = PurePosixPath(relative).parts
    if not parts:
        return False
    if relative == "etc/ld.so.cache" or relative.startswith("etc/ld.so.cache/"):
        return True
    if relative in {"etc/localtime", "etc/resolv.conf"}:
        return True
    for root in ("etc/arkup", "etc/arkpkg"):
        if relative == root or relative.startswith(root + "/"):
            return True
    if parts[0] in {"dev", "proc", "sys", "run", "tmp", "home", "root", "srv"}:
        return True
    if len(parts) >= 2 and parts[0] == "var" and parts[1] in {
        "cache",
        "lib",
        "log",
        "spool",
        "tmp",
    }:
        return True
    return len(parts) >= 2 and parts[:2] == ("usr", "local")


def _relative(path: Path, root: Path) -> str:
    relative = path.relative_to(root).as_posix()
    try:
        relative.encode("utf-8")
    except UnicodeEncodeError as error:
        raise BuildError(f"update paths must be valid UTF-8: {relative!r}") from error
    if not relative or relative == "." or "\\" in relative:
        raise BuildError(f"invalid update path: {relative!r}")
    if any(part in {"", ".", ".."} for part in relative.split("/")):
        raise BuildError(f"unsafe update path: {relative!r}")
    return relative


def _file_digest(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(CHUNK_SIZE), b""):
            digest.update(block)
    return digest.hexdigest()


def snapshot_tree(root: Path) -> Tree:
    """Index regular files and symlinks without following links or caching data."""
    try:
        root = root.resolve(strict=True)
    except OSError as error:
        raise BuildError(f"cannot access root tree {root}: {error}") from error
    if not root.is_dir():
        raise BuildError(f"root tree is not a directory: {root}")

    nodes: dict[str, Node] = {}
    directories: dict[str, int] = {}

    def walk_error(error: OSError) -> None:
        raise BuildError(f"cannot scan root tree: {error}") from error

    for current, dirnames, filenames in os.walk(
        root, topdown=True, followlinks=False, onerror=walk_error
    ):
        current_path = Path(current)
        retained_dirs: list[str] = []
        for name in sorted(dirnames):
            path = current_path / name
            relative = _relative(path, root)
            if is_protected_path(relative):
                continue
            metadata = path.lstat()
            if stat.S_ISDIR(metadata.st_mode):
                directories[relative] = stat.S_IMODE(metadata.st_mode)
                retained_dirs.append(name)
            elif stat.S_ISLNK(metadata.st_mode):
                target = os.readlink(path)
                try:
                    target.encode("utf-8")
                except UnicodeEncodeError as error:
                    raise BuildError(f"symlink target must be valid UTF-8: {relative}") from error
                nodes[relative] = Node("symlink", stat.S_IMODE(metadata.st_mode), target=target)
            else:
                raise BuildError(f"unsupported filesystem object: {path}")
        dirnames[:] = retained_dirs

        for name in sorted(filenames):
            path = current_path / name
            relative = _relative(path, root)
            if relative == ".arkana-iso-root" or is_protected_path(relative):
                continue
            metadata = path.lstat()
            mode = stat.S_IMODE(metadata.st_mode)
            if stat.S_ISREG(metadata.st_mode):
                nodes[relative] = Node("file", mode, digest=_file_digest(path))
            elif stat.S_ISLNK(metadata.st_mode):
                target = os.readlink(path)
                try:
                    target.encode("utf-8")
                except UnicodeEncodeError as error:
                    raise BuildError(f"symlink target must be valid UTF-8: {relative}") from error
                nodes[relative] = Node("symlink", mode, target=target)
            else:
                raise BuildError(f"unsupported filesystem object: {path}")

    return Tree(root, nodes, directories)


def _read_regular_text(root: Path, relative: str, *, single_line: bool = True) -> str:
    path = root / relative
    try:
        parent = root
        for component in PurePosixPath(relative).parts[:-1]:
            parent /= component
            if not stat.S_ISDIR(parent.lstat().st_mode):
                raise BuildError(f"release metadata parent must be a real directory: {parent}")
        metadata = path.lstat()
        if not stat.S_ISREG(metadata.st_mode):
            raise BuildError(f"release metadata must be a regular file: {path}")
        value = path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        raise BuildError(f"cannot read release metadata {path}: {error}") from error
    value = value.removesuffix("\n")
    if not value or "\r" in value or "\x00" in value:
        raise BuildError(f"invalid release metadata in {path}")
    if single_line and "\n" in value:
        raise BuildError(f"invalid release metadata in {path}")
    return value


def _expected_release(prefix: str, build: int) -> tuple[str, str, str, str]:
    if prefix == "nightly":
        return "nightly", "nightly", f"nightly-build-{build}", "true"
    patterns = (
        (r"r([1-9][0-9]*)-a([1-9][0-9]*)", "alpha", "true"),
        (r"r([1-9][0-9]*)-b([1-9][0-9]*)", "beta", "true"),
        (r"r([1-9][0-9]*)-([1-9][0-9]*)", "stable", "false"),
    )
    for pattern, channel, prerelease in patterns:
        match = re.fullmatch(pattern, prefix)
        if not match:
            continue
        release = match.group(1)
        if channel == "alpha":
            number = match.group(2)
            version = f"{release}.0 (alpha {number})"
            version_id = f"{release}.0-alpha{number}"
            tag_prefix = f"v{version_id}"
        elif channel == "beta":
            number = match.group(2)
            version = f"{release}.0 (beta {number})"
            version_id = f"{release}.0-beta{number}"
            tag_prefix = f"v{version_id}"
        else:
            version = f"{release}.0"
            version_id = version
            tag_prefix = f"v{version}"
        return version, version_id, f"{tag_prefix}-build-{build}", prerelease
    raise BuildError(f"unsupported arkanaOS release prefix: {prefix!r}")


def read_release(root: Path) -> Release:
    """Read and cross-check version files before trusting update sequence data."""
    try:
        root = root.resolve(strict=True)
    except OSError as error:
        raise BuildError(f"cannot access release root {root}: {error}") from error
    if not root.is_dir():
        raise BuildError(f"release root is not a directory: {root}")
    build_text = _read_regular_text(root, "etc/arkana-build-number")
    if not re.fullmatch(r"[1-9][0-9]*", build_text):
        raise BuildError(f"invalid build number in {root}/etc/arkana-build-number")
    build = int(build_text)
    prefix = _read_regular_text(root, "etc/arkana-release-prefix")
    version = _read_regular_text(root, "etc/arkana-release-version")
    version_id = _read_regular_text(root, "etc/arkana-release-version-id")
    release_id = _read_regular_text(root, "etc/arkana-release-id")
    prerelease = _read_regular_text(root, "etc/arkana-release-prerelease")
    expected_version, expected_id, expected_tag, expected_prerelease = _expected_release(
        prefix, build
    )
    if (version, version_id, release_id, prerelease) != (
        expected_version,
        expected_id,
        expected_tag,
        expected_prerelease,
    ):
        raise BuildError(f"inconsistent release metadata in {root}")

    os_release: dict[str, str] = {}
    os_release_text = _read_regular_text(root, "etc/os-release", single_line=False)
    # os-release values are shell-quoted data; parse tokens without evaluating shell.
    for line in os_release_text.splitlines():
        if not line or line.startswith("#"):
            continue
        key, separator, raw_value = line.partition("=")
        if not separator:
            raise BuildError(f"invalid /etc/os-release line: {line!r}")
        if not re.fullmatch(r"[A-Z0-9_]+", key) or key in os_release:
            raise BuildError(f"invalid or duplicate /etc/os-release field {key!r}")
        try:
            parts = shlex.split(raw_value, posix=True)
        except ValueError as error:
            raise BuildError(f"invalid /etc/os-release field {key!r}") from error
        if len(parts) != 1:
            raise BuildError(f"invalid /etc/os-release field {key!r}")
        os_release[key] = parts[0]
    display = f"{version} build {build}"
    expected_fields = {
        "NAME": "arkanaOS",
        "ID": "arkana",
        "VERSION": display,
        "VERSION_ID": version_id,
        "PRETTY_NAME": f"arkanaOS {display}",
    }
    if any(os_release.get(key) != value for key, value in expected_fields.items()):
        raise BuildError(f"/etc/os-release does not match release metadata in {root}")
    issue = _read_regular_text(root, "etc/issue")
    if issue != f"arkanaOS {display}":
        raise BuildError(f"/etc/issue does not match release metadata in {root}")

    marker = root / ".arkana-iso-root"
    try:
        marker.lstat()
    except FileNotFoundError:
        pass
    else:
        if _read_regular_text(root, ".arkana-iso-root") != "arkanaOS ISO root":
            raise BuildError(f"invalid arkanaOS root marker in {root}")
    return Release(build, prefix, version, version_id, release_id, display)


def compute_delta(base: Tree, target: Tree) -> tuple[list[str], list[str]]:
    """Return changed target paths and deleted base paths, rejecting shape hazards."""
    base_dirs = set(base.directories)
    target_dirs = set(target.directories)
    conflicts = (base_dirs & target.nodes.keys()) | (target_dirs & base.nodes.keys())
    if conflicts:
        path = sorted(conflicts)[0]
        raise BuildError(f"file/directory transition cannot be represented by arkup: {path}")

    changed = [
        path
        for path, node in target.nodes.items()
        if base.nodes.get(path) != node
    ]
    deleted = sorted(base.nodes.keys() - target.nodes.keys())

    for path, mode in target.directories.items():
        if path in base.directories:
            if base.directories[path] != mode:
                raise BuildError(f"arkup cannot update directory permissions: {path}")
        elif mode != 0o755 and any(item.startswith(path + "/") for item in changed):
            raise BuildError(
                f"arkup creates new directories with mode 0755; cannot add files below {path} mode {mode:04o}"
            )

    changed_set = set(changed) | set(deleted)
    for path in changed_set:
        parts = path.split("/")
        for index in range(1, len(parts)):
            parent = "/".join(parts[:index])
            if parent in changed_set:
                raise BuildError(
                    f"parent and descendant changes cannot share one arkup pack: {parent}, {path}"
                )
    return sorted(changed), deleted


def stage_delta(target: Tree, changed: list[str], destination: Path) -> None:
    """Copy only changed regular files and symlinks into a temporary pack root."""
    destination.mkdir(mode=0o755, parents=True, exist_ok=False)
    for relative in changed:
        source = target.root / relative
        output = destination / relative
        output.parent.mkdir(mode=0o755, parents=True, exist_ok=True)
        node = target.nodes[relative]
        if node.kind == "file":
            shutil.copyfile(source, output, follow_symlinks=False)
            output.chmod(node.mode, follow_symlinks=False)
        elif node.kind == "symlink":
            os.symlink(node.target, output)
        else:
            raise BuildError(f"unsupported update entry type {node.kind!r}: {relative}")


def _write_checksum(package: Path, sidecar: Path) -> None:
    digest = _file_digest(package)
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    descriptor = os.open(sidecar, flags, 0o644)
    try:
        with os.fdopen(descriptor, "w", encoding="ascii") as stream:
            stream.write(f"{digest}  {package.name}\n")
            stream.flush()
            os.fsync(stream.fileno())
    except BaseException:
        sidecar.unlink(missing_ok=True)
        raise


def build_update(
    base_root: Path,
    target_root: Path,
    output_dir: Path,
    signing_key: Path,
    public_key: Path,
    arkup: str = "arkup",
    architecture: str = "x86_64",
    description: str | None = None,
) -> Path | None:
    try:
        base_root = base_root.resolve(strict=True)
        target_root = target_root.resolve(strict=True)
    except OSError as error:
        raise BuildError(f"cannot access input root tree: {error}") from error
    if base_root == target_root or base_root.is_relative_to(target_root) or target_root.is_relative_to(base_root):
        raise BuildError("base and target roots must be separate, non-nested trees")
    base_release = read_release(base_root)
    target_release = read_release(target_root)
    if target_release.build <= base_release.build:
        raise BuildError(
            f"target build {target_release.build} must be newer than base build {base_release.build}"
        )
    base = snapshot_tree(base_root)
    target = snapshot_tree(target_root)

    output_dir = output_dir.resolve(strict=False)
    for tree in (base, target):
        if output_dir == tree.root or output_dir.is_relative_to(tree.root):
            raise BuildError(f"output directory must be outside root trees: {output_dir}")
    output_dir.mkdir(parents=True, exist_ok=True)
    output_dir = output_dir.resolve(strict=True)

    changed, deleted = compute_delta(base, target)
    if not changed and not deleted:
        print("No system changes found; no .aup package was created.")
        return None

    filename = f"arkanaos-{target_release.release_id}.aup"
    output = output_dir / filename
    sidecar = output_dir / f"{filename}.sha256"
    if os.path.lexists(output) or os.path.lexists(sidecar):
        raise BuildError(f"refusing to overwrite existing update artifact: {output}")
    if not stat.S_ISREG(signing_key.lstat().st_mode) or not stat.S_ISREG(
        public_key.lstat().st_mode
    ):
        raise BuildError("signing key and matching public verification key must be regular files")

    system_files = sorted(set(changed) & set(SYSTEM_METADATA))
    system_files.extend(sorted(set(deleted) & set(SYSTEM_METADATA)))
    update_description = description or (
        f"arkanaOS system update from build {base_release.build} "
        f"to build {target_release.build}"
    )
    with tempfile.TemporaryDirectory(prefix=".arkana-update-stage-", dir=output_dir) as temporary:
        temporary_root = Path(temporary)
        staged = temporary_root / "root"
        stage_delta(target, changed, staged)
        temporary_package = temporary_root / "update.aup"
        command = [
            arkup,
            "pack",
            "--source",
            str(staged),
            "--name",
            "arkanaos-system",
            "--version",
            target_release.display,
            "--sequence",
            str(target_release.build),
            "--arch",
            architecture,
            "--description",
            update_description,
            "--signing-key",
            str(signing_key),
            "--output",
            str(temporary_package),
        ]
        for path in deleted:
            command.extend(("--delete", path))
        for path in system_files:
            command.extend(("--system-file", path))
        subprocess.run(command, check=True)
        subprocess.run(
            [arkup, "verify", str(temporary_package), "--key", str(public_key)],
            check=True,
        )
        if not temporary_package.is_file() or temporary_package.stat().st_size == 0:
            raise BuildError("arkup did not produce a non-empty update pack")
        os.link(temporary_package, output)
        try:
            # Update archives are public distribution artifacts, unlike signing keys.
            os.chmod(output, 0o644)
            _write_checksum(output, sidecar)
        except BaseException:
            output.unlink(missing_ok=True)
            raise

    directory_fd = os.open(output_dir, os.O_RDONLY | getattr(os, "O_DIRECTORY", 0))
    try:
        os.fsync(directory_fd)
    finally:
        os.close(directory_fd)
    print(
        f"Built {output} ({len(changed)} changed, {len(deleted)} deleted; "
        f"build {base_release.build} -> {target_release.build})."
    )
    print(f"SHA-256: {sidecar}")
    return output


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build a signed arkup update from a base and target arkanaOS root tree."
    )
    parser.add_argument("--base-root", type=Path, required=True)
    parser.add_argument("--target-root", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--signing-key", type=Path, required=True)
    parser.add_argument("--public-key", type=Path, required=True)
    parser.add_argument("--arkup", default="arkup")
    parser.add_argument("--architecture", default="x86_64")
    parser.add_argument("--description")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        build_update(
            args.base_root,
            args.target_root,
            args.output_dir,
            args.signing_key,
            args.public_key,
            args.arkup,
            args.architecture,
            args.description,
        )
    except (BuildError, OSError, subprocess.CalledProcessError) as error:
        print(f"arkana-update-builder: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
