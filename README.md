![Banner](https://raw.githubusercontent.com/arkana-team/branding/refs/heads/main/arkana_banner.png)

<h1 align="center">arkanaOS Source Files</h1>
<p>This repository contains everything you'll need to compile our project.</p>

> [!NOTE]
> The distro is technically in an operational state, but it's not currently possible to confirm without burning arkanaOS to a DVD.

## Cloning and Building
To build the project, run the following commands:
```bash
git clone https://github.com/arkana-team/arkanaOS.git
cd arkanaOS
./build.sh
```

> [!NOTE]
> Please use the attached `build.sh` script to build arkanaOS.<br>
> Makefile builds are not supported, you can however override the Docker checks by running `make FORCE=1` as root.
