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

## Desktop

The default X session is NsCDE with its four-color Solyaris palette, Solaris 7
backdrop, and Luxi Sans/Mono fonts. The NsCDE session is also installed under
`/usr/share/xsessions` for display managers.

## CLI installer
