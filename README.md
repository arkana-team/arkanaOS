![Banner](https://raw.githubusercontent.com/arkana-team/branding/refs/heads/main/arkana_banner.png)

<h1 align="center">arkanaOS Source Files</h1>
<p>This repository contains everything you'll need to compile our project.</p>

## Note
This is currently not ready. A working distro will come later.

## Cloning and Building
To clone and build
```
git clone https://github.com/arkana-team/arkanaOS.git
cd arkanaOS
make
```

## Dependencies
``` cmake meson ninja make gcc g++ ld as cc autoconf autoreconf automake sed awk tar wget grep gzip bzip2 xz mksquashfs makeinfo expect glib-mkenums rst2man pod2man curl xorriso mformat install xsltproc help2man python3 pip lzip ```

### Installation for dependencies
<details> <summary><strong>Debian/Ubuntu</strong></summary>

```apt-get update && apt-get install -y cmake meson ninja-build make gcc g++ binutils autoconf automake sed gawk tar wget grep gzip bzip2 xz-utils squashfs-tools texinfo expect libglib2.0-bin python3-docutils perl curl xorriso mtools xsltproc help2man python3 python3-pip lzip```

</details> <details> <summary><strong>Fedora</strong></summary>

```dnf install -y cmake meson ninja-build make gcc gcc-c++ binutils autoconf automake sed gawk tar wget grep gzip bzip2 xz squashfs-tools texinfo expect glib2 docutils perl-Pod-Simple curl xorriso mtools xsltproc help2man python3 python3-pip lzip```

</details> <details> <summary><strong>Arch Linux</strong></summary>

```pacman -Syu --noconfirm cmake meson ninja make gcc binutils autoconf automake sed gawk tar wget grep gzip bzip2 xz squashfs-tools texinfo expect glib2 python-docutils perl curl xorriso mtools xsltproc help2man python python-pip lzip```

</details> <details> <summary><strong>Gentoo</strong></summary>

```emerge --ask dev-util/cmake dev-util/meson dev-util/ninja sys-devel/make sys-devel/gcc sys-devel/binutils sys-devel/autoconf sys-devel/automake sys-apps/sed sys-apps/gawk app-arch/tar net-misc/wget sys-apps/grep app-arch/gzip app-arch/bzip2 app-arch/xz-utils sys-fs/squashfs-tools app-text/texinfo app-shells/expect dev-libs/glib app-text/docutils net-misc/curl sys-fs/xorriso app-misc/mtools dev-util/xsltproc app-text/help2man dev-lang/python dev-python/pip app-arch/lzip```

</details>
