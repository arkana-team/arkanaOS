![Banner](https://raw.githubusercontent.com/arkana-team/branding/refs/heads/main/arkana_banner.png)

<h1 align="center">arkanaOS Source Files</h1>
<p>This repository contains everything needed to compile arkanaOS.</p>

## Build

Build the hybrid BIOS/UEFI ISO from the project container:

```bash
git clone https://github.com/arkana-team/arkanaOS.git
cd arkanaOS
./build.sh
```

The ISO uses GRUB for legacy BIOS and x86_64 UEFI. Its Linux image includes
AMD Radeon/AMDGPU and Intel i915/Xe graphics drivers, plus Intel IGC Ethernet
and iwlwifi wireless support. Matching graphics and Intel wireless firmware is
present in both the live image and installed system.

Each base build adds a random increment from 1 to 250 to `.buildnum`. The new
number is saved in that file and in `/etc/arkana-build-number` in the build
ISO. GitHub Actions reserves and pushes the next number before compiling, so
future clones start from the latest CI build. A local build updates `.buildnum`
in its working tree; commit and push that file to share the new number with
other clones.

## Desktop

The default X session is NsCDE with its four-color Solyaris palette, Solaris 7
backdrop, and Luxi Sans/Mono fonts. The NsCDE session is also installed under
`/usr/share/xsessions` for display managers.

## CLI installer

Boot the live ISO as root and run `arkana-install`. It partitions the selected
disk, copies the live system, installs GRUB for the detected boot mode, and
prompts for the new system's account, password, and timezone. The installer
erases the selected disk.
