![Banner](https://raw.githubusercontent.com/arkana-team/branding/refs/heads/main/arkana_banner.png)

<h1 align="center">arkanaOS Source Files</h1>
<p>This repository contains everything needed to compile arkanaOS.</p>

## Build

```bash
git clone https://github.com/arkana-team/arkanaOS.git
cd arkanaOS
./build.sh
```

Boot the live ISO as root and run `arkana-install`. It partitions the selected
disk, copies the live system, installs GRUB for the detected boot mode, and
prompts for the new system's account, password, and timezone. The installer
erases the selected disk.
