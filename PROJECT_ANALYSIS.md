# arkanaOS Project Analysis

## 1. High-level architecture

arkanaOS is a from-source Linux distribution for x86_64, built in the style of
Linux From Scratch (LFS) / Beyond LFS (BLFS). It does not use a binary package
repository for its own construction; every component is downloaded as a source
tarball, patched as needed, compiled, and installed into a private staging
rootfs. From that rootfs it assembles a bootable hybrid ISO.

The build is deliberately containerized: `build.sh` builds an Arch Linux Docker
image (`Dockerfile`) and runs `make` inside it, so the host system is never
modified (a prior non-Docker approach "destroyed systems" via `ld.so.cache`,
per commit history). The builder host's GCC, ccache, meson, cmake, etc. are used
as the bootstrap toolchain; the resulting staging tree is a `--sysroot`-targeted
root filesystem.

The runtime system is conventional LFS+systemd:
- **Init (PID 1):** systemd on the installed/live system; busybox `init` scripts
  (`liveinit`/`bootinit`) only run inside the initramfs.
- **Live root:** a zstd-compressed squashfs image (`rootfs.sfs`) mounted read-only
  and overlaid with a tmpfs (writable upper layer) via the overlayfs kernel
  module. In-memory changes are lost on reboot, as expected for a live CD.
- **Installed root:** `arkana-install` copies the live tree to a disk partition,
  installs GRUB, and generates fstab.
- **Package manager:** arkpkg, a deliberately minimal Rust package manager that
  installs local `.ark` packages (tar.lz4 archives) into a configurable root.
- **Desktop:** X11 (Xorg + Window Maker/openbox) and Wayland (labwc, weston) sessions.
  The default X session (`xinitrc`) starts `wmaker`; MATE is not part of the build.

### Component map
```
build.sh ──> Docker build ──> sudo make
   Makefile ──> arkanas/01..07 .mk ──> staging/  (rootfs)
                                         │
         └── 07_iso.mk: initramfs (busybox + liveinit + modules) ──> iso-staging/
                      iso: squashfs(rootfs) + vmlinuz + grub ──> output/arkana.iso
```

## 2. Repository structure

```
Makefile           top-level entry; enforces Docker, check-libs target
build.sh           Docker wrapper (build image + run `sudo make`)
Dockerfile         Arch Linux build container definition
arkanas/           7 numbered GNU Make modules (the "recipes")
  01_base.mk       base system + core libraries (glibc, systemd, bash, ...)
  02_ext.mk        extended utilities (curl, vim, sudo, networkmanager, ...)
  03_arkpkg.mk     builds arkpkg (Rust) into staging
  04_toolchain.mk  full dev toolchain (gcc, binutils, meson, cmake, python, ...)
  05_graphics.mk   X11 stack (xorg, mesa, openbox, ...)
  06_graphics_ext.mk  Wayland stack (wayland, weston, labwc, xwayland, ...)
  07_iso.mk        kernel, grub, busybox, initramfs + ISO assembly
src/               downloaded tarballs + extracted sources (gitignored)
  cross_file.txt   meson native file (sysroot flags for staging)
  arkpkg-main/     vendored arkpkg source (Rust) + docs/
staging/           the built rootfs (gitignored)
cpio-staging/      busybox initramfs root (gitignored)
iso-staging/       ISO staging tree (gitignored)
output/            arkana.iso + .ark packages (gitignored)
arkana-install     interactive hard-disk installer (bash)
genfstab           Arch's fstab generator (util-linux derived)
bootinit           initramfs /init for installed systems (mount root=)
liveinit           initramfs /init for the live CD (overlay search/mount)
arkcfg             prebuilt binary: display/sysinfo/power config tool (source NOT in repo)
neofetch           bundled upstream neofetch 7.1.0 (deprecated upstream)
xinitrc            X session startup (wmaker/openbox + wallpaper)
twmrc              TWM window-manager config (replaced by wmaker-config/)
busybox.config     busybox .config for the initramfs
linux.config       Linux 6.17.6 kernel .config
passwd shadow group  base system account files (installed by linux-pam recipe)
oldconfig.exp      expect script for interactive `make oldconfig`
.buildnum          monotonically increasing build counter
```

## 3. Component overview

- **Build driver** (`Makefile`, `build.sh`, `Dockerfile`): ensures the build runs
  in a container; sets `CC=ccache gcc`, GCC-15 `-std=gnu17` compatibility, and
  `-mtls-dialect=gnu` (workaround for glibc rejecting GLIBC_ABI_GNU2_TLS).
- **Recipe modules** (`arkanas/*.mk`): each defines `<pkg>_URL`, `<pkg>_VER`,
  `<pkg>_PATH` variables and `download-<pkg>`/`.<pkg>-obtained` plus
  `.<pkg>-done` stamp-guarded rules. Recipes use autotools, meson, cmake, or
  custom Makefiles, with heavy `sed` patching for upstream issues.
- **Kernel** (`07_iso.mk`): Linux 6.17.6, configured for devtmpfs, squashfs (as
  module), overlayfs, ISO9660, initramfs support.
- **Initramfs** (`cpio-staging/`): busybox 1.37.0 + kernel modules + `init`.
- **Rootfs** (`staging/`): ~400 MB staged system; systemd, X11, Wayland, Window Maker.
- **arkpkg** (`src/arkpkg-main/`): two binaries — `arkpkg` (install/remove/verify/
  info/list/search) and `arkpkg-build` (source dir → `.ark`).
- **arkcfg**: Rust-based config tool (display resolution, sysinfo, power). Only
  the compiled binary is committed; no source in this repo.
- **Installer** (`arkana-install`): partitions, rsyncs root, installs GRUB,
  configures users/timezone/hostname/sudo.

## 4. Build pipeline

1. `build.sh` builds the Docker image and runs `sudo make` with memory/CPU caps.
2. `Makefile` validates it's inside a container (unless `FORCE=1`), then runs
   each `arkanas/*.mk` module in numeric order:
   `01_base → 02_ext → 03_arkpkg → 04_toolchain → 05_graphics → 06_graphics_ext → 07_iso`.
   Each failing module aborts the build.
3. Each package rule is guarded by stamp files `.<name>-obtained` (downloaded+
   extracted) and `.<name>-done` (built+installed into `staging/` via `DESTDIR`
   or equivalent). Stamps make builds resumable after a failure.
4. `07_iso.mk` then:
   - `initramfs`: installs kernel modules into `cpio-staging/`, copies `liveinit`
     to `cpio-staging/init`, and packs `cpio | gzip` → `iso-staging/boot/initramfs.img`.
   - `boot-initramfs`: same with `bootinit` → `staging/boot/initramfs.img`.
   - `iso`: copies user tools into staging (`arkana-install`, `genfstab`,
     `neofetch`, `arkcfg`, `xinitrc`, `wmaker-config/`), runs `fc-cache` +
     `glib-compile-schemas` in a chroot, symlinks `/etc/ld.so.cache` to `/dev/null`,
     builds `rootfs.sfs` (`mksquashfs -comp zstd`), copies `bzImage`, writes
     `grub.cfg`, and runs `grub-mkrescue` → `output/arkana.iso`.
5. `Makefile check-libs` chroots into staging and `ldd`-scans every executable/
   library for unresolved dependencies (writes `libs.missing`).

## 5. Package manager design (arkpkg)

- **Philosophy:** minimal, Unix-like, plain-text everywhere; no repositories,
  mirrors, downloads, signing, or hooks. Packages are "data only."
- **Format:** `.ark` files are plain `tar.lz4` archives containing exactly an
  `ARKPKG` metadata file (Name/Description/Version/Arch/URL/License/Maintainer/
  Dependencies/Provides/Conflicts) and a `package/` payload tree.
- **Binaries:**
  - `arkpkg-build <dir> [-o out]` — packages a dir (ARKPKG + package/) into
    `<name>-<version>-<arch>.ark`.
  - `arkpkg {install,remove,verify,info,list,search}` with global `-y/-n/-f/
    --root` flags (root also from `$ARKPKG_ROOT`, default `/`).
- **Database** (under `<root>/etc/arkpkg/`):
  - `package.db` — `name version` lines.
  - `file.db` — `/abs/path=package` ownership lines.
  - `packages/<name>.arkinfo` — installed package record incl. authoritative
    `Files:` list, SHA-256 of the archive, install time.
  - Writes are atomic (tempfile+persist); op log at `<root>/var/log/arkpkg.log`.
- **Install:** 18-step sequence — extract to temp, validate metadata/arch, check
  already-installed (different version = implicit overwrite-style upgrade),
  check dependencies (via name or `Provides:`), conflicts, file-conflict prompts,
  copy files, write checksum, update DBs, with partial rollback.
- **Remove:** delete `.arkinfo`-listed files, prune empty dirs upward (respecting
  a protected-dirs set), update DBs. Dependent-package checking is a stub.
- **Verify:** read-only existence check of installed files (no checksums).
- **Exit codes:** 0–10 mapped to specific `ArkError` variants.

**Status:** arkpkg builds into the ISO, and 53 `.ark` packages exist in
`output/packages/`, but the build itself does NOT install the OS via arkpkg —
the rootfs is assembled directly via `DESTDIR`. The staging `etc/arkpkg` DB is
empty. (The `.ark` files appear to have been produced manually/adhoc.)

## 6. Installer flow (`arkana-install`)

1. Sanity checks: must run as root, all required binaries present, `/` must be an
   overlay mount (i.e. running from the Live CD).
2. Detects candidate block devices (>8 GB), lets the user pick if several.
3. Partitions: EFI → GPT (`1: 120M vfat`, `2: rest ext4`); legacy → MBR (msdos).
   Handles nvme/mmcblk `p` suffix partitions.
4. Formats, mounts target (`/mnt` + ESP at `/mnt/boot/efi` or `/mnt/boot`),
   `rsync -ax` copies the live overlay root to the disk.
5. Bootloader: binds /dev /sys /proc /run /tmp into the target, then
   `grub-install` (x86_64-efi with bootloader-id from PRETTY_NAME, or i386-pc),
   writes a custom `29_main` GRUB entry, `grub-mkconfig`.
6. Generates `/etc/fstab` via bundled `genfstab -U`.
7. Interactive config: hostname, root password, new user (wheel), user password,
   timezone (symlink to `/etc/localtime`), enables `%wheel` sudo.
8. Removes live-only artifacts (getty autologin override, `arkana-install` itself).

## 7. Boot process

- **Media boot:** GRUB (BIOS+UEFI, from `grub-mkrescue`) → `/boot/vmlinuz` +
  `/boot/initramfs.img`.
- **Live initramfs (`liveinit`, PID 1):** mounts proc/sys/dev/run; `mdev -s`
  populates devices; loads squashfs/overlay/isofs modules; scans `/sys/class/block/*`
  (excluding ram/loop/zram/fd) mounting each device RO looking for
  `boot/rootfs.sfs`; mounts squashfs RO + tmpfs overlay (75% RAM), stacks an
  overlayfs onto `/mnt/newroot`; moves virtual filesystems; `switch_root` →
  `/sbin/init` (systemd). `recovery=true` kernel param drops to an emergency shell.
- **Installed-system initramfs (`bootinit`):** same pattern but mounts the
  `root=PART` from the kernel cmdline directly, then switch_root to systemd.
- **systemd** then takes over the real system (getty autologin for the live root
  user via a getty@tty1 override).

## 8. Current limitations

- **arkcfg is a committed binary** with no in-repo source; cannot be patched/
  rebuilt from this repo.
- **arkpkg incomplete:** no `upgrade` command; remove-time dependent check is a
  stub; `verify` only checks existence; reverse-conflict check is dead code;
  symlinks are dereferenced on copy; hardcoded `x86_64` arch allowance; unused
  `log`/`simplelog` deps.
- **arkpkg not wired into the OS build:** rootfs is DESTDIR-built; arkpkg DB is
  never initialized; the 53 `.ark` packages are not installed by the build.
- **Swallowed failures:** many critical ISO steps end with `|| true`
  (mksquashfs, initramfs, kernel copy) — a broken ISO can be produced silently.
- **Hardcoded kernel version** (`linux-6.17.6`) in `07_iso.mk`.
- **Live network deps:** jbigkit applies an Arch packaging patch fetched from
  gitlab at build time.
- **Non-reproducible:** nightly timestamps, `.buildnum` counter, unpinned
  upstream URLs.
- **Plain HTTP URLs** for several packages (xorg apps/fonts, libndp, openbox).
- **DESTDIR/pkg-config friction:** many recipes `sed` the installed `.pc` files
  to rewrite `prefix=` — symptom of an incomplete sysroot setup.
- **x86_64 only**, no multilib, no cross-compiler (host toolchain + `--sysroot`).
- **`/etc/ld.so.cache` symlinked to `/dev/null`** in the image.
- **Live environment autologins as root** on tty1.
- **Minimal docs:** root README is 13 lines; most recipe knowledge lives in
  comments inside the `.mk` files.
- **Stray build artifacts committed:** `a.out`, `test.c`, `oldconfig.exp` are
  leftovers.

## 9. Potential improvements

1. Vendor `arkcfg` source and build it via an `arkanas/` recipe.
2. Finish arkpkg: real upgrade, removal dependents check, checksum verification,
   symlink-aware copy, honest arch check; remove dead code/unused deps.
3. Integrate arkpkg into the build (build `.ark`s from staging, install them, and
   initialize the DB) so the ISO is genuinely arkpkg-managed.
4. Replace `|| true` with real error handling; fail the build if squashfs/ISO
   assembly fails.
5. Parameterize the kernel version (shared variable instead of hardcoded string).
6. Vendor the jbigkit patch (no live-network build dependency).
7. Migrate plain-HTTP URLs to HTTPS.
8. Make builds reproducible (fixed timestamps, deterministic build number) and
   pin URL checksums.
9. Add CI that exercises the Docker build (even partial).
10. Investigate proper sysroot/cross setup to eliminate `.pc` sed rewriting.
11. Improve docs: expand root README, document recipe conventions and how to add
    a package.

## 10. Questions / ambiguities

- **arkcfg source:** where does the arkcfg binary come from, and where is its
  source maintained (separate arkana-team repo)? It is committed as a stripped
  binary with version 0.1.0.
- **`output/packages/*.ark`:** how were these produced? Nothing in the recipes
  invokes `arkpkg-build` for them. Are they intended to be installed by
  `arkana-install` or the live system?
- **Purpose of `neofetch`:** upstream neofetch is discontinued (as of Feb 2024);
  is this an intentional stable fork, or should it be replaced?
- **History:** commit `9b774a2 "deprecated: arkana packager is cancelled"`
  preceded the Rust arkpkg; the old `ark.c` packager no longer exists. Is arkpkg
  its successor by design?
- **Duplicate commits:** `4ecf03a` and `c38c2a3` share the same subject — likely
  a rebase artifact; confirm no divergence.
- **Live autologin root:** intended only for the live environment, or also
  configured on installed systems by `arkana-install` (it explicitly removes the
  override — good), but the tty override is baked into systemd recipe.
- **Recovery path:** the initramfs relies on `mdev`/busybox; is a full initramfs
  replacement (e.g. dracut-style) planned?
