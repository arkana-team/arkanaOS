![Banner](https://raw.githubusercontent.com/arkana-team/branding/refs/heads/main/arkana_banner.png)

<h1 align="center">arkanaOS Source Files</h1>
<p>This repository contains everything you'll need to compile our project.</p>

## Note
The distro is technically in an operational state, but it's not currently possible to confirm without burning arkanaOS to a DVD.

## Cloning and Building
To build the project, run the following commands:
```bash
git clone https://github.com/arkana-team/arkanaOS.git
cd arkanaOS
sudo make
```

You need to use `sudo` to build arkanaOS successfully.

> [!WARNING]
> It is recommended to use a separated environment for building arkanaOS. 
> 
> Building from within a partially compiled tree may cause host-side issues that may potentially crash the host.
