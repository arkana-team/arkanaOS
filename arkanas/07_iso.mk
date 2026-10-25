# Enable multi-threaded Bash operation
SHELL = bash
.DEFAULT_GOAL := all
THREADS ?= $(shell nproc)
MKSQUASHFS_THREADS ?= $(THREADS)
.NOTPARALLEL:

# Paths used to build the ISO components
SRC_PATH = $(shell realpath -m ./src)
include arkanas/staging-guard.mk
STAGING_PATH = $(shell realpath -m ./staging)
CPIO_STAGING_PATH = $(shell realpath -m ./cpio-staging)
ISO_STAGING_PATH = $(shell realpath -m ./iso-staging)
OUTPUT_PATH = $(shell realpath -m ./output)
ISO_ROOT_PATH = $(OUTPUT_PATH)/iso-root
override ARKANA_CANONICAL_ISO_ROOT := $(shell realpath -m .)/output/iso-root
ifneq ($(abspath $(ISO_ROOT_PATH)), $(abspath $(ARKANA_CANONICAL_ISO_ROOT)))
$(error refusing ISO_ROOT_PATH override; the ISO pruners require $(ARKANA_CANONICAL_ISO_ROOT))
endif

# Cpio
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/cpio.html
CPIO_URL = https://mirrors.ocf.berkeley.edu/gnu/cpio/cpio-2.15.tar.gz
CPIO_FALLBACK_URL = https://ftp.gnu.org/gnu/cpio/cpio-2.15.tar.gz
CPIO_VER = 2.15
CPIO_PATH = $(SRC_PATH)/cpio-$(CPIO_VER)

# libisoburn (provides xorriso required by grub-mkrescue)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/multimedia/libisoburn.html
LIBISOBURN_URL = https://files.libburnia-project.org/releases/libisoburn-1.5.6.tar.gz
LIBISOBURN_VER = 1.5.6
LIBISOBURN_SHA256 = 2b80a6f73dd633a5d243facbe97a15e5c9a07644a5e1a242c219b9375a45f71b
LIBISOBURN_PATH = $(SRC_PATH)/libisoburn-$(LIBISOBURN_VER)

# Libburn
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/multimedia/libburn.html
LIBBURN_URL = https://files.libburnia-project.org/releases/libburn-1.5.6.tar.gz
LIBBURN_VER = 1.5.6
LIBBURN_SHA256 = 7295491b4be5eeac5e7a3fb2067e236e2955ffdc6bbd45f546466edee321644b
LIBBURN_PATH = $(SRC_PATH)/libburn-$(LIBBURN_VER)

# Libisofs
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/multimedia/libisofs.html
LIBISOFS_URL = https://files.libburnia-project.org/releases/libisofs-1.5.6.tar.gz
LIBISOFS_VER = 1.5.6
LIBISOFS_SHA256 = 0152d66a9d340b659fe9c880eb9190f3570fb477ac07cf52e8bcd134a1d30d70
LIBISOFS_PATH = $(SRC_PATH)/libisofs-$(LIBISOFS_VER)

# mtools (provides mformat required by libisoburn)
# URL: https://mirrors.ocf.berkeley.edu/gnu/mtools/ (w/o instructions)
MTOOLS_URL = https://mirrors.ocf.berkeley.edu/gnu/mtools/mtools-4.0.49.tar.gz
MTOOLS_FALLBACK_URL = https://ftp.gnu.org/gnu/mtools/mtools-4.0.49.tar.gz
MTOOLS_VER = 4.0.49
MTOOLS_PATH = $(SRC_PATH)/mtools-$(MTOOLS_VER)

# BusyBox 
# URL: https://www.busybox.net/downloads/ (down)
BUSYBOX_URL = https://cdimage.debian.org/mirror/slackware.com/slackware-current/source/installer/sources/busybox/busybox-1.37.0.tar.bz2
BUSYBOX_VER = 1.37.0
BUSYBOX_PATH = $(SRC_PATH)/busybox-$(BUSYBOX_VER)

# Linux kernel
# URL: https://kernel.org/ (w/o instructions as LFS builds a rootfs)
LINUX_URL = https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.57.tar.xz
LINUX_VER = 6.18.57
LINUX_SHA256 = 5bd9acdc82ec5efc3790ae840e5aaa40dfde7efff261cf6dde902dc570acf98c
LINUX_PATH = $(SRC_PATH)/linux-$(LINUX_VER)

# GRUB (bootloader)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/grub-efi.html
GRUB_URL = https://gitlab.freedesktop.org/api/v4/projects/26558/packages/generic/source-assets/grub-$(GRUB_VER)/grub-$(GRUB_VER).tar.xz
GRUB_FONT_URL = https://unifoundry.com/pub/unifont/unifont-16.0.01/font-builds/unifont-16.0.01.pcf.gz
GRUB_SHA256 = f0db0104927df0b9a48bc41b735c702936190d17eb2d73d3018fa77474a0cabe
GRUB_VER = 2.16
GRUB_ARCHIVE = grub-$(GRUB_VER).tar.xz
GRUB_OBTAINED_STAMP = .grub-$(GRUB_VER)-obtained
GRUB_BUILD_STAMP = .grub-$(GRUB_VER)-built
GRUB_DONE_STAMP = .grub-$(GRUB_VER)-done
GRUB_PATH = $(SRC_PATH)/grub-$(GRUB_VER)
GRUB_DESTDIR = $(SRC_PATH)/grub-$(GRUB_VER)-destdir

# Freetype
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/freetype2.html
FREETYPE_URL = https://downloads.sourceforge.net/freetype/freetype-2.13.3.tar.xz
FREETYPE_VER = 2.13.3
FREETYPE_PATH = $(SRC_PATH)/freetype-$(FREETYPE_VER)

# Harfbuzz
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/harfbuzz.html
HARFBUZZ_URL = https://github.com/harfbuzz/harfbuzz/releases/download/11.4.1/harfbuzz-11.4.1.tar.xz
HARFBUZZ_VER = 11.4.1
HARFBUZZ_PATH = $(SRC_PATH)/harfbuzz-$(HARFBUZZ_VER)

# Glib
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/glib2.html
GLIB_URL = https://download.gnome.org/sources/glib/2.78/glib-2.78.6.tar.xz
GLIB_VER = 2.78.6
GLIB_PATH = $(SRC_PATH)/glib-$(GLIB_VER)

# Libffi
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/libffi.html
LIBFFI_URL = https://github.com/libffi/libffi/releases/download/v3.5.2/libffi-3.5.2.tar.gz
LIBFFI_VER = 3.5.2
LIBFFI_PATH = $(SRC_PATH)/libffi-$(LIBFFI_VER)

# Elfutils (only needed to provide libelf)
# URL: https://gcc.gnu.org/pub/elfutils/ (w/o instructions)
ELFUTILS_URL = https://gcc.gnu.org/pub/elfutils/0.193/elfutils-0.193.tar.bz2
ELFUTILS_VER = 0.193
ELFUTILS_PATH = $(SRC_PATH)/elfutils-$(ELFUTILS_VER)

# Brotli
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/brotli.html
BROTLI_URL = https://github.com/google/brotli/archive/v1.1.0/brotli-1.1.0.tar.gz
BROTLI_VER = 1.1.0
BROTLI_PATH = $(SRC_PATH)/brotli-$(BROTLI_VER)

# PCRE2
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/pcre2.html
PCRE2_URL = https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.47/pcre2-10.47.tar.bz2
PCRE2_VER = 10.47
PCRE2_PATH = $(SRC_PATH)/pcre2-$(PCRE2_VER)

# Cairo
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/cairo.html
CAIRO_URL = https://www.cairographics.org/releases/cairo-1.18.4.tar.xz
CAIRO_VER = 1.18.4
CAIRO_PATH = $(SRC_PATH)/cairo-$(CAIRO_VER)

# Fontconfig
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/fontconfig.html
FONTCONFIG_URL = https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/fontconfig/2.17.1/fontconfig-2.17.1.tar.xz
FONTCONFIG_VER = 2.17.1
FONTCONFIG_PATH = $(SRC_PATH)/fontconfig-$(FONTCONFIG_VER)

# Expat
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/expat.html
EXPAT_URL = https://github.com/libexpat/libexpat/releases/download/R_2_7_1/expat-2.7.1.tar.gz
EXPAT_VER = 2.7.1
EXPAT_PATH = $(SRC_PATH)/expat-$(EXPAT_VER)

# Graphite2
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/graphite2.html
GRAPHITE2_URL = https://github.com/silnrsi/graphite/releases/download/1.3.14/graphite2-1.3.14.tgz
GRAPHITE2_VER = 1.3.14
GRAPHITE2_PATH = $(SRC_PATH)/graphite2-$(GRAPHITE2_VER)

# Pixman
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/pixman.html
PIXMAN_URL = https://www.cairographics.org/releases/pixman-0.46.4.tar.gz
PIXMAN_VER = 0.46.4
PIXMAN_PATH = $(SRC_PATH)/pixman-$(PIXMAN_VER)

# Libpng
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libpng.html
LIBPNG_URL = https://downloads.sourceforge.net/libpng/libpng-1.6.50.tar.xz
LIBPNG_PATCH_URL = https://downloads.sourceforge.net/sourceforge/libpng-apng/libpng-1.6.47-apng.patch.gz # use APNG
LIBPNG_VER = 1.6.50
LIBPNG_PATH = $(SRC_PATH)/libpng-$(LIBPNG_VER)

# LZO
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/lzo.html
LZO_URL = https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
LZO_VER = 2.10
LZO_PATH = $(SRC_PATH)/lzo-$(LZO_VER)

# squashfs-tools
# URL: https://github.com/plougher/squashfs-tools/releases
SQUASHFS_TOOLS_URL = https://github.com/plougher/squashfs-tools/archive/refs/tags/4.7.4.tar.gz
SQUASHFS_TOOLS_VER = 4.7.4
SQUASHFS_TOOLS_PATH = $(SRC_PATH)/squashfs-tools-$(SQUASHFS_TOOLS_VER)

# Efibootmgr (GRUB for EFI needs it)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/efibootmgr.html
EFIBOOTMGR_URL = https://github.com/rhboot/efibootmgr/archive/18/efibootmgr-18.tar.gz
EFIBOOTMGR_VER = 18
EFIBOOTMGR_PATH = $(SRC_PATH)/efibootmgr-$(EFIBOOTMGR_VER)

# Efivar
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/efivar.html
EFIVAR_URL = https://github.com/rhboot/efivar/archive/39/efivar-39.tar.gz
EFIVAR_VER = 39
EFIVAR_PATH = $(SRC_PATH)/efivar-$(EFIVAR_VER)

# Firefox
FIREFOX_URL = https://archive.mozilla.org/pub/firefox/releases/158.0/linux-x86_64/en-US/firefox-158.0.tar.xz
FIREFOX_VER = 158.0
FIREFOX_SHA512 = da90b8c7c6f391935508f99a54d730e5141044c0ce0e915900ecb3f208e840f10a4cf8d38d76852335e6c436bbe2a16e1bf72945fe067340ad94d9ae98f41c59

# Firefox runtime libraries omitted from the base package list
ALSA_URL = https://www.alsa-project.org/files/pub/lib/alsa-lib-1.2.16.1.tar.bz2
ALSA_VER = 1.2.16.1
ALSA_PATH = $(SRC_PATH)/alsa-lib-$(ALSA_VER)
AT_SPI_URL = https://download.gnome.org/sources/at-spi2-core/2.54/at-spi2-core-2.54.2.tar.xz
AT_SPI_VER = 2.54.2
AT_SPI_PATH = $(SRC_PATH)/at-spi2-core-$(AT_SPI_VER)
GTK3_URL = https://download.gnome.org/sources/gtk/3.24/gtk-3.24.52.tar.xz
GTK3_VER = 3.24.52
GTK3_PATH = $(SRC_PATH)/gtk-$(GTK3_VER)
LIBXDAMAGE_URL = https://xorg.freedesktop.org/archive/individual/lib/libXdamage-1.1.7.tar.xz
LIBXDAMAGE_VER = 1.1.7
LIBXDAMAGE_PATH = $(SRC_PATH)/libXdamage-$(LIBXDAMAGE_VER)

download-firefox: .firefox-obtained
.firefox-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O firefox-$(FIREFOX_VER).tar.xz $(FIREFOX_URL)
	cd $(SRC_PATH) && echo '$(FIREFOX_SHA512)  firefox-$(FIREFOX_VER).tar.xz' | sha512sum -c -
	cd $(SRC_PATH) && tar xf firefox-$(FIREFOX_VER).tar.xz -C $(SRC_PATH)
	touch .firefox-obtained

firefox: download-firefox .firefox-done
.firefox-done:
	mkdir -p $(STAGING_PATH)/opt/firefox
	cp -a $(SRC_PATH)/firefox/. $(STAGING_PATH)/opt/firefox/
	mkdir -p $(STAGING_PATH)/usr/bin
	ln -sf /opt/firefox/firefox $(STAGING_PATH)/usr/bin/firefox
	mkdir -p $(STAGING_PATH)/usr/share/applications
	printf '[Desktop Entry]\nName=Firefox\nComment=Browse the World Wide Web\nExec=/opt/firefox/firefox %%u\nTerminal=false\nType=Application\nCategories=Network;WebBrowser;\nMimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;\n' > $(STAGING_PATH)/usr/share/applications/firefox.desktop
	touch .firefox-done

# Targets
all: build initramfs boot-initramfs iso

build: cpio busybox linux linux-firmware grub freetype harfbuzz glib libffi elfutils brotli pcre2 cairo fontconfig expat graphite2 pixman libpng libisoburn libburn libisofs mtools squashfs-tools lzo efibootmgr efivar alsa-lib at-spi2-core libXdamage gtk3

download-alsa-lib: .alsa-lib-obtained
.alsa-lib-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O alsa-lib-$(ALSA_VER).tar.bz2 $(ALSA_URL) && tar xf alsa-lib-$(ALSA_VER).tar.bz2
	touch .alsa-lib-obtained

alsa-lib: download-alsa-lib .alsa-lib-done
.alsa-lib-done:
	cd $(ALSA_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr --disable-python && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .alsa-lib-done

download-at-spi2-core: .at-spi2-core-obtained
.at-spi2-core-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O at-spi2-core-$(AT_SPI_VER).tar.xz $(AT_SPI_URL) && tar xf at-spi2-core-$(AT_SPI_VER).tar.xz
	touch .at-spi2-core-obtained

at-spi2-core: download-at-spi2-core .at-spi2-core-done
.at-spi2-core-done:
	rm -rf $(AT_SPI_PATH)/build && mkdir -p $(AT_SPI_PATH)/build && cd $(AT_SPI_PATH)/build && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	PKG_CONFIG_LIBDIR="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" PKG_CONFIG_SYSROOT_DIR="$(STAGING_PATH)" \
	CPPFLAGS="-I$(STAGING_PATH)/usr/include" CFLAGS="-O2 -pipe -I$(STAGING_PATH)/usr/include" LDFLAGS="-L$(STAGING_PATH)/usr/lib -Wl,-rpath-link=$(STAGING_PATH)/usr/lib" \
	meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release --wrap-mode=nofallback \
	-Ddocs=false -Dintrospection=disabled -Dgtk2_atk_adaptor=false -Dx11=enabled && ninja -j$(THREADS) && DESTDIR=$(STAGING_PATH) ninja -j$(THREADS) install
	touch .at-spi2-core-done

download-libXdamage: .libXdamage-obtained
.libXdamage-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libXdamage-$(LIBXDAMAGE_VER).tar.xz $(LIBXDAMAGE_URL) && tar xf libXdamage-$(LIBXDAMAGE_VER).tar.xz
	touch .libXdamage-obtained

libXdamage: download-libXdamage .libXdamage-done
.libXdamage-done:
	cd $(LIBXDAMAGE_PATH) && PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	PKG_CONFIG_LIBDIR="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" PKG_CONFIG_SYSROOT_DIR="$(STAGING_PATH)" \
	CPPFLAGS="-I$(STAGING_PATH)/usr/include" CFLAGS="-O2 -std=gnu17 -I$(STAGING_PATH)/usr/include" \
	LDFLAGS="-L$(STAGING_PATH)/usr/lib -Wl,-rpath-link=$(STAGING_PATH)/usr/lib" \
	./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libXdamage-done

download-gtk3: .gtk3-obtained
.gtk3-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O gtk-$(GTK3_VER).tar.xz $(GTK3_URL) && tar xf gtk-$(GTK3_VER).tar.xz
	touch .gtk3-obtained

gtk3: download-gtk3 alsa-lib at-spi2-core libXdamage .gtk3-done
.gtk3-done:
	rm -rf $(GTK3_PATH)/build && mkdir -p $(GTK3_PATH)/build && cd $(GTK3_PATH)/build && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	PKG_CONFIG_LIBDIR="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" PKG_CONFIG_SYSROOT_DIR="$(STAGING_PATH)" \
	CPPFLAGS="-I$(STAGING_PATH)/usr/include" CFLAGS="-O2 -pipe -I$(STAGING_PATH)/usr/include" LDFLAGS="-L$(STAGING_PATH)/usr/lib -Wl,-rpath-link=$(STAGING_PATH)/usr/lib" \
	meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release --wrap-mode=nofallback \
	-Dx11_backend=true -Dwayland_backend=true -Dbroadway_backend=false -Dcolord=no -Dcloudproviders=false -Dtracker3=false \
	-Dprint_backends=file -Dgtk_doc=false -Dman=false -Dintrospection=false -Ddemos=false -Dexamples=false -Dtests=false && \
	ninja -j$(THREADS) && DESTDIR=$(STAGING_PATH) ninja -j$(THREADS) install
	touch .gtk3-done

# Download cpio
download-cpio: .cpio-obtained

.cpio-obtained:
	cd $(SRC_PATH) && ( wget --tries=5 --timeout=30 -O cpio-$(CPIO_VER).tar.gz $(CPIO_URL) || wget --tries=5 --timeout=30 -O cpio-$(CPIO_VER).tar.gz $(CPIO_FALLBACK_URL) ) && tar xf cpio-$(CPIO_VER).tar.gz
	touch .cpio-obtained

# Compile cpio
cpio: download-cpio .cpio-done

.cpio-done:
	cd $(CPIO_PATH) && sed -e "/^extern int (\*xstat)/s/()/(const char * restrict,  struct stat * restrict)/" -i src/extern.h && \
	sed -e "/^int (\*xstat)/s/()/(const char * restrict,  struct stat * restrict)/" -i src/global.c && \
	./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --enable-mt --with-rmt=/usr/lib/rmt && $(MAKE) -j$(THREADS) && \
	makeinfo --html -o doc/html doc/cpio.texi && \
	makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi && \
	makeinfo --plaintext -o doc/cpio.txt doc/cpio.texi && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install && install -v -m755 -d $(STAGING_PATH)/usr/share/doc/cpio-$(CPIO_VER)/html && \
	install -v -m644 doc/html/* $(STAGING_PATH)/usr/share/doc/cpio-$(CPIO_VER)/html && \
	install -v -m644 doc/cpio.{html,txt} $(STAGING_PATH)/usr/share/doc/cpio-$(CPIO_VER)
	touch .cpio-done

# Download libisoburn
.PHONY: download-libisoburn verify-libisoburn
download-libisoburn: .libisoburn-verified-obtained

$(SRC_PATH)/libisoburn-$(LIBISOBURN_VER).tar.gz:
	wget --tries=5 --timeout=30 -O "$@.tmp" $(LIBISOBURN_URL) && mv "$@.tmp" "$@"

# Check even cached archives when the extraction/build stamps already exist.
verify-libisoburn: $(SRC_PATH)/libisoburn-$(LIBISOBURN_VER).tar.gz
	cd $(SRC_PATH) && echo '$(LIBISOBURN_SHA256)  libisoburn-$(LIBISOBURN_VER).tar.gz' | sha256sum -c -

# A new stamp replaces source trees extracted before verification was required.
.libisoburn-verified-obtained: $(SRC_PATH)/libisoburn-$(LIBISOBURN_VER).tar.gz | verify-libisoburn
	rm -rf $(LIBISOBURN_PATH)
	cd $(SRC_PATH) && tar xf libisoburn-$(LIBISOBURN_VER).tar.gz
	touch $@

# Compile libisoburn
libisoburn: libburn libisofs download-libisoburn .libisoburn-done

.libisoburn-done: .libisoburn-verified-obtained
	cd $(LIBISOBURN_PATH) && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	PKG_CONFIG_LIBDIR="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_PATH)" \
	CPPFLAGS="-I$(STAGING_PATH)/usr/include" \
	LDFLAGS="-L$(STAGING_PATH)/usr/lib -Wl,-rpath-link=$(STAGING_PATH)/usr/lib" \
	./configure CFLAGS="-O2 -std=gnu17 -fno-stack-protector" --prefix=/usr --enable-pkg-check-modules --disable-ldconfig-at-install && \
	$(MAKE) clean && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libisoburn-done

# Download libburn
.PHONY: download-libburn verify-libburn
download-libburn: .libburn-verified-obtained

$(SRC_PATH)/libburn-$(LIBBURN_VER).tar.gz:
	wget --tries=5 --timeout=30 -O "$@.tmp" $(LIBBURN_URL) && mv "$@.tmp" "$@"

# Check even cached archives when the extraction/build stamps already exist.
verify-libburn: $(SRC_PATH)/libburn-$(LIBBURN_VER).tar.gz
	cd $(SRC_PATH) && echo '$(LIBBURN_SHA256)  libburn-$(LIBBURN_VER).tar.gz' | sha256sum -c -

# A new stamp replaces source trees extracted before verification was required.
.libburn-verified-obtained: $(SRC_PATH)/libburn-$(LIBBURN_VER).tar.gz | verify-libburn
	rm -rf $(LIBBURN_PATH)
	cd $(SRC_PATH) && tar xf libburn-$(LIBBURN_VER).tar.gz
	touch $@

# Compile libburn
libburn: download-libburn .libburn-done

.libburn-done: .libburn-verified-obtained
	cd $(LIBBURN_PATH) && sed -i 's/catch_int ()/catch_int (int signum)/' test/poll.c && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --disable-static && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libburn-done

# Download libisofs
.PHONY: download-libisofs verify-libisofs
download-libisofs: .libisofs-verified-obtained

$(SRC_PATH)/libisofs-$(LIBISOFS_VER).tar.gz:
	wget --tries=5 --timeout=30 -O "$@.tmp" $(LIBISOFS_URL) && mv "$@.tmp" "$@"

# Check even cached archives when the extraction/build stamps already exist.
verify-libisofs: $(SRC_PATH)/libisofs-$(LIBISOFS_VER).tar.gz
	cd $(SRC_PATH) && echo '$(LIBISOFS_SHA256)  libisofs-$(LIBISOFS_VER).tar.gz' | sha256sum -c -

# A new stamp replaces source trees extracted before verification was required.
.libisofs-verified-obtained: $(SRC_PATH)/libisofs-$(LIBISOFS_VER).tar.gz | verify-libisofs
	rm -rf $(LIBISOFS_PATH)
	cd $(SRC_PATH) && tar xf libisofs-$(LIBISOFS_VER).tar.gz
	touch $@

# Compile libisofs
libisofs: download-libisofs .libisofs-done

.libisofs-done: .libisofs-verified-obtained
	cd $(LIBISOFS_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --disable-static && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libisofs-done

# Download mtools
download-mtools: .mtools-obtained

.mtools-obtained:
	cd $(SRC_PATH) && ( wget --tries=5 --timeout=30 -O mtools-$(MTOOLS_VER).tar.gz $(MTOOLS_URL) || wget --tries=5 --timeout=30 -O mtools-$(MTOOLS_VER).tar.gz $(MTOOLS_FALLBACK_URL) ) && tar xf mtools-$(MTOOLS_VER).tar.gz
	touch .mtools-obtained

# Compile mtools
mtools: download-mtools .mtools-done

.mtools-done:
	cd $(MTOOLS_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .mtools-done

# Download Busybox
download-busybox: .busybox-obtained

.busybox-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O busybox-$(BUSYBOX_VER).tar.bz2 $(BUSYBOX_URL) && tar xf busybox-$(BUSYBOX_VER).tar.bz2
	touch .busybox-obtained

# Compile BusyBox
busybox: download-busybox .busybox-done

.busybox-done:
	mkdir -p $(CPIO_STAGING_PATH)/{boot,dev,etc,home,mnt,opt,proc,root,run,sys,tmp,var}
	cp busybox.config $(BUSYBOX_PATH)/.config && cd $(BUSYBOX_PATH) && yes "" | make oldconfig && \
	$(MAKE) -j$(THREADS) && $(MAKE) install && cp -a _install/* $(CPIO_STAGING_PATH)
	touch .busybox-done

# Download Linux kernel
download-linux: .linux-$(LINUX_VER)-obtained

.linux-$(LINUX_VER)-obtained: $(CURDIR)/arkanas/07_iso.mk
	if [ ! -f $(LINUX_PATH)/Makefile ]; then cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O linux-$(LINUX_VER).tar.xz $(LINUX_URL) && echo '$(LINUX_SHA256)  linux-$(LINUX_VER).tar.xz' | sha256sum -c - && tar xf linux-$(LINUX_VER).tar.xz; fi
	touch $@

# Compile Linux kernel
linux: download-linux .linux-$(LINUX_VER)-done

.linux-$(LINUX_VER)-done: $(CURDIR)/linux.config $(CURDIR)/arkanas/07_iso.mk
	# Linus, you've fucked with the SBAT file config and my builder broke!
	$(MAKE) -C $(LINUX_PATH) mrproper && cp $(CURDIR)/linux.config $(LINUX_PATH)/.config && cd $(LINUX_PATH) && $(MAKE) olddefconfig && \
	$(MAKE) -j$(THREADS) KBUILD_BUILD_HOST="arkana" KBUILD_BUILD_USER="arkana" all && cp arch/x86/boot/bzImage $(STAGING_PATH)/boot/vmlinuz && \
	$(MAKE) -C $(LINUX_PATH) headers_install INSTALL_HDR_PATH=$(STAGING_PATH)/usr
	rm -rf $(STAGING_PATH)/lib/modules
	$(MAKE) -C $(LINUX_PATH) INSTALL_MOD_PATH=$(STAGING_PATH) modules_install
	touch $@

# Pin host firmware so the live image and installed system support current hardware.
LINUX_FIRMWARE_TAG = 20260916
LINUX_FIRMWARE_PATH = $(SRC_PATH)/linux-firmware-$(LINUX_FIRMWARE_TAG)
WIRELESS_REGDB_TAG = master-2026-09-03
WIRELESS_REGDB_COMMIT = 389b9b702cf9018e9a9078ccc4fa8eaae2e054e3
WIRELESS_REGDB_PATH = $(SRC_PATH)/wireless-regdb-2026-09-03

.PHONY: linux-firmware
linux-firmware: .linux-firmware-done
.linux-firmware-done: $(CURDIR)/arkanas/07_iso.mk
	if ! [ -d $(LINUX_FIRMWARE_PATH)/.git ]; then \
	  git clone --depth 1 --branch $(LINUX_FIRMWARE_TAG) https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git $(LINUX_FIRMWARE_PATH); \
	fi
	if ! [ -d $(WIRELESS_REGDB_PATH)/.git ]; then \
	  git clone --depth 1 --branch $(WIRELESS_REGDB_TAG) https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git $(WIRELESS_REGDB_PATH); \
	fi
	test "$$(git -C $(WIRELESS_REGDB_PATH) rev-parse HEAD)" = "$(WIRELESS_REGDB_COMMIT)"
	git -C $(LINUX_FIRMWARE_PATH) sparse-checkout set amdgpu i915 xe radeon amd-ucode intel LICENSES
	install -d $(STAGING_PATH)/lib/firmware $(CPIO_STAGING_PATH)/lib/firmware $(STAGING_PATH)/usr/share/licenses/linux-firmware $(STAGING_PATH)/usr/share/licenses/wireless-regdb
	rm -rf $(STAGING_PATH)/lib/firmware/ath9k_htc $(STAGING_PATH)/lib/firmware/ath10k $(STAGING_PATH)/lib/firmware/ath11k $(STAGING_PATH)/lib/firmware/ath12k $(STAGING_PATH)/lib/firmware/intel $(CPIO_STAGING_PATH)/lib/firmware/ath9k_htc $(CPIO_STAGING_PATH)/lib/firmware/ath10k $(CPIO_STAGING_PATH)/lib/firmware/ath11k $(CPIO_STAGING_PATH)/lib/firmware/ath12k $(CPIO_STAGING_PATH)/lib/firmware/intel
	for firmware in amdgpu i915 xe radeon amd-ucode intel; do \
	  test -d $(LINUX_FIRMWARE_PATH)/$$firmware || { echo "Missing firmware directory: $$firmware" >&2; exit 1; }; \
	  cp -a $(LINUX_FIRMWARE_PATH)/$$firmware $(STAGING_PATH)/lib/firmware/ || exit 1; \
	  cp -a $(LINUX_FIRMWARE_PATH)/$$firmware $(CPIO_STAGING_PATH)/lib/firmware/ || exit 1; \
	done
	awk '$$1 == "Link:" && $$4 ~ /^(amdgpu|i915|xe|radeon|amd-ucode|intel\/iwlwifi)\// { print $$2, $$4 }' $(LINUX_FIRMWARE_PATH)/WHENCE | while read -r firmware target; do \
	  test -e $(STAGING_PATH)/lib/firmware/$$target || continue; \
	  ln -sf "$$target" $(STAGING_PATH)/lib/firmware/$$firmware || exit 1; \
	  ln -sf "$$target" $(CPIO_STAGING_PATH)/lib/firmware/$$firmware || exit 1; \
	done
	for firmware in regulatory.db regulatory.db.p7s; do \
	  test -f $(WIRELESS_REGDB_PATH)/$$firmware || { echo "Missing regulatory data: $$firmware" >&2; exit 1; }; \
	  install -m 644 $(WIRELESS_REGDB_PATH)/$$firmware $(STAGING_PATH)/lib/firmware/; \
	  install -m 644 $(WIRELESS_REGDB_PATH)/$$firmware $(CPIO_STAGING_PATH)/lib/firmware/; \
	done
	find $(CPIO_STAGING_PATH)/lib/firmware -mindepth 1 -maxdepth 1 ! -name regulatory.db ! -name regulatory.db.p7s -exec rm -rf {} + # Keep the tiny regulatory database for early wireless setup; bulk firmware stays in SquashFS.
	cp -a $(LINUX_FIRMWARE_PATH)/LICENSES $(STAGING_PATH)/usr/share/licenses/linux-firmware/
	install -m 644 $(WIRELESS_REGDB_PATH)/LICENSE $(STAGING_PATH)/usr/share/licenses/wireless-regdb/LICENSE
	touch .linux-firmware-done

# Download GRUB
download-grub: $(GRUB_OBTAINED_STAMP)

.grub-$(GRUB_VER)-obtained:
	cd $(SRC_PATH) && \
	if [ ! -f $(GRUB_ARCHIVE) ]; then \
	  wget --tries=5 --timeout=30 -O $(GRUB_ARCHIVE).part $(GRUB_URL) && \
	  echo "$(GRUB_SHA256)  $(GRUB_ARCHIVE).part" | sha256sum -c - && \
	    mv $(GRUB_ARCHIVE).part $(GRUB_ARCHIVE); \
	fi && \
	echo "$(GRUB_SHA256)  $(GRUB_ARCHIVE)" | sha256sum -c - && \
	tar xf $(GRUB_ARCHIVE) && \
	wget --tries=5 --timeout=30 -O unifont-16.0.01.pcf.gz $(GRUB_FONT_URL)
	touch $(GRUB_OBTAINED_STAMP)

# Compile GRUB
grub: $(GRUB_DONE_STAMP)

# Keep the i386-pc kernel at the BIOS load address required by GRUB.
.grub-$(GRUB_VER)-built: .freetype-done $(GRUB_OBTAINED_STAMP)
	cd $(GRUB_PATH) && rm -rf build-efi build-pc $(GRUB_DESTDIR) && rm -f grub-core/extra_deps.lst && \
	cd $(GRUB_PATH) && \
	mkdir -p build-efi && cd build-efi && \
	CFLAGS="-O2 -std=gnu17" CPPFLAGS="" LDFLAGS="" PKG_CONFIG_PATH=$(STAGING_PATH)/usr/lib/pkgconfig ../configure --prefix=/usr --sysconfdir=/etc --disable-efiemu --with-platform=efi \
	--target=x86_64 --disable-werror && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(GRUB_DESTDIR) install && \
	cd $(GRUB_PATH) && mkdir -p build-pc && cd build-pc && \
	CFLAGS="-O2 -std=gnu17" CPPFLAGS="" LDFLAGS="" PKG_CONFIG_PATH=$(STAGING_PATH)/usr/lib/pkgconfig ../configure --prefix=/usr --sysconfdir=/etc --disable-efiemu --with-platform=pc \
	--target=i386 --disable-werror && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(GRUB_DESTDIR) install && \
	test "$$(readelf -h grub-core/kernel.exec | awk '/Entry point address:/ { print $$4 }')" = "0x9000" && \
	test -x $(GRUB_DESTDIR)/usr/sbin/grub-install && \
	test -x $(GRUB_DESTDIR)/usr/bin/grub-mkrescue && \
	test -d $(GRUB_DESTDIR)/usr/lib/grub/x86_64-efi && \
	test -d $(GRUB_DESTDIR)/usr/lib/grub/i386-pc && \
	test -f $(GRUB_DESTDIR)/usr/share/bash-completion/completions/grub
	touch $(GRUB_BUILD_STAMP)

$(GRUB_DONE_STAMP): $(GRUB_BUILD_STAMP)

	# Font data here
	rm -rf $(STAGING_PATH)/usr/lib/grub $(STAGING_PATH)/usr/share/grub $(STAGING_PATH)/etc/grub.d && \
	mkdir -p $(STAGING_PATH)/usr/bin $(STAGING_PATH)/usr/sbin && \
	find $(STAGING_PATH)/usr/bin -maxdepth 1 \( -type f -o -type l \) -name 'grub-*' -delete && \
	find $(STAGING_PATH)/usr/sbin -maxdepth 1 \( -type f -o -type l \) -name 'grub-*' -delete && \
	rm -f $(STAGING_PATH)/etc/bash_completion.d/grub \
	  $(STAGING_PATH)/usr/share/bash-completion/completions/grub \
	  $(STAGING_PATH)/usr/share/info/grub.info* \
	  $(STAGING_PATH)/usr/share/man/man8/grub-* && \
	find $(STAGING_PATH)/usr/share/locale -type f -path '*/LC_MESSAGES/grub.mo' -delete && \
	for source_path in $(GRUB_DESTDIR)/*; do \
	  if [ "$$source_path" = "$(GRUB_DESTDIR)/usr" ] && [ -L $(STAGING_PATH)/usr/sbin ]; then \
	    for usr_path in "$$source_path"/*; do \
	      if [ "$$usr_path" = "$$source_path/sbin" ]; then \
	        cp -a "$$usr_path"/. $(STAGING_PATH)/usr/bin/ || exit 1; \
	      else \
	        cp -a "$$usr_path" $(STAGING_PATH)/usr/ || exit 1; \
	      fi; \
	    done; \
	  else \
	    cp -a "$$source_path" $(STAGING_PATH)/ || exit 1; \
	  fi; \
	done && \
	mkdir -p $(STAGING_PATH)/usr/share/fonts/unifont $(STAGING_PATH)/usr/share/grub && \
	gunzip -c $(SRC_PATH)/unifont-16.0.01.pcf.gz > $(STAGING_PATH)/usr/share/fonts/unifont/unifont.pcf && \
	chroot $(STAGING_PATH) /usr/bin/grub-mkfont -o /usr/share/grub/unicode.pf2 /usr/share/fonts/unifont/unifont.pcf

	touch $(GRUB_DONE_STAMP)

# Download freetype
download-freetype: .freetype-obtained

.freetype-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O freetype-$(FREETYPE_VER).tar.xz $(FREETYPE_URL) && tar xf freetype-$(FREETYPE_VER).tar.xz
	touch .freetype-obtained

# Compile freetype
freetype: download-freetype .freetype-done

.freetype-done:
	cd $(FREETYPE_PATH) && sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg && \
	sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" -i include/freetype/config/ftoption.h && \
	./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --enable-freetype-config --disable-static && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .freetype-done

# Download harfbuzz
download-harfbuzz: .harfbuzz-obtained

.harfbuzz-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O harfbuzz-$(HARFBUZZ_VER).tar.xz $(HARFBUZZ_URL) && tar xf harfbuzz-$(HARFBUZZ_VER).tar.xz
	touch .harfbuzz-obtained

# Compile harfbuzz
harfbuzz: download-harfbuzz .harfbuzz-done

.harfbuzz-done:
	mkdir -p $(HARFBUZZ_PATH)/build	&& cd $(HARFBUZZ_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release \
	-D graphite2=enabled && ninja -j$(THREADS) && DESTDIR=$(STAGING_PATH) ninja -j$(THREADS) install
	touch .harfbuzz-done

# Download glib
download-glib: .glib-obtained

.glib-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O glib-$(GLIB_VER).tar.xz $(GLIB_URL) && tar xf glib-$(GLIB_VER).tar.xz
	touch .glib-obtained

# Compile glib
glib: download-glib .glib-done

.glib-done:
	mkdir -p $(GLIB_PATH)/build
	sed -i 's/free_sized (mem, size)/free(mem)/' $(GLIB_PATH)/glib/gmem.c
	sed -i 's/free_aligned_sized (mem, alignment, size)/free(mem)/' $(GLIB_PATH)/glib/gmem.c
	cd $(GLIB_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release \
	-D glib_debug=disabled -D sysprof=disabled && ninja -j$(THREADS) && DESTDIR=$(STAGING_PATH) ninja -j$(THREADS) install
	touch .glib-done

# Download libffi
download-libffi: .libffi-obtained

.libffi-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libffi-$(LIBFFI_VER).tar.gz $(LIBFFI_URL) && tar xf libffi-$(LIBFFI_VER).tar.gz
	touch .libffi-obtained

# Compile libffi
libffi: download-libffi .libffi-done

.libffi-done:
	cd $(LIBFFI_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --disable-static && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libffi-done

# Download elfutils
download-elfutils: .elfutils-obtained

.elfutils-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O elfutils-$(ELFUTILS_VER).tar.bz2 $(ELFUTILS_URL) && tar xf elfutils-$(ELFUTILS_VER).tar.bz2
	touch .elfutils-obtained

# Compile elfutils
elfutils: download-elfutils .elfutils-done

.elfutils-done:
	mkdir -p $(STAGING_PATH)/usr/lib/pkgconfig
	cd $(ELFUTILS_PATH) && ./configure --prefix=/usr --disable-werror CFLAGS="-O2 -std=gnu17 -Wno-error=discarded-qualifiers" && $(MAKE) -j$(THREADS) && install -D -m644 config/libelf.pc $(STAGING_PATH)/usr/lib/pkgconfig/libelf.pc
	for lib in libelf debuginfod libdw; do \
		$(MAKE) -C $(SRC_PATH)/elfutils-$(ELFUTILS_VER)/$$lib DESTDIR=$(STAGING_PATH) install || exit 1; \
	done
	touch .elfutils-done

# Download brotli
download-brotli: .brotli-obtained

.brotli-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O brotli-$(BROTLI_VER).tar.gz $(BROTLI_URL) && tar xf brotli-$(BROTLI_VER).tar.gz
	touch .brotli-obtained

# Compile brotli
brotli: download-brotli .brotli-done

.brotli-done:
	mkdir -p $(BROTLI_PATH)/build && cd $(BROTLI_PATH)/build && cmake -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release .. && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .brotli-done

# Download PCRE2
download-pcre2: .pcre2-obtained

.pcre2-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O pcre2-$(PCRE2_VER).tar.bz2 $(PCRE2_URL) && tar xf pcre2-$(PCRE2_VER).tar.bz2
	touch .pcre2-obtained

# Compile PCRE2
pcre2: download-pcre2 .pcre2-done

.pcre2-done:
	cd $(PCRE2_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --docdir=/usr/share/doc/pcre2-$(PCRE2_VER) --enable-unicode --enable-jit --enable-pcre2-16 \
	--enable-pcre2-32 --enable-pcre2grep-libz --enable-pcre2grep-libbz2 --enable-pcre2test-libreadline --disable-static && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .pcre2-done

# Download cairo
download-cairo: .cairo-obtained

.cairo-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O cairo-$(CAIRO_VER).tar.xz $(CAIRO_URL) && tar xf cairo-$(CAIRO_VER).tar.xz
	touch .cairo-obtained

# Compile cairo
cairo: download-cairo .cairo-done

.cairo-done:
	mkdir -p $(CAIRO_PATH)/build && cd $(CAIRO_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release .. && ninja -j$(THREADS) && \
	DESTDIR=$(STAGING_PATH) ninja -j$(THREADS) install
	touch .cairo-done

# Download fontconfig
download-fontconfig: .fontconfig-obtained

.fontconfig-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O fontconfig-$(FONTCONFIG_VER).tar.xz $(FONTCONFIG_URL) && tar xf fontconfig-$(FONTCONFIG_VER).tar.xz
	touch .fontconfig-obtained

# Compile fontconfig
fontconfig: download-fontconfig .fontconfig-done

.fontconfig-done:
	cd $(FONTCONFIG_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-docs \
	--docdir=/usr/share/doc/fontconfig-$(FONTCONFIG_VER) && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .fontconfig-done

# Download expat
download-expat: .expat-obtained

.expat-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O expat-$(EXPAT_VER).tar.gz $(EXPAT_URL) && tar xf expat-$(EXPAT_VER).tar.gz
	touch .expat-obtained

# Compile expat
expat: download-expat .expat-done

.expat-done:
	cd $(EXPAT_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --disable-static --docdir=/usr/share/doc/expat-$(EXPAT_VER) && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .expat-done

# Download graphite2
download-graphite2: .graphite2-obtained

.graphite2-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O graphite2-$(GRAPHITE2_VER).tgz $(GRAPHITE2_URL) && tar xf graphite2-$(GRAPHITE2_VER).tgz
	touch .graphite2-obtained

# Compile graphite2
graphite2: download-graphite2 .graphite2-done

.graphite2-done:
    # Outdated build system, cool.
	mkdir -p $(GRAPHITE2_PATH)/build && cd $(GRAPHITE2_PATH)/build && sed -i '/Font.h/i #include <cstdint>' ../tests/featuremap/featuremaptest.cpp && \
	cmake -D CMAKE_POLICY_VERSION_MINIMUM=3.5 -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_C_FLAGS="-O2 -std=gnu17" -D CMAKE_CXX_FLAGS="-O2 -std=gnu17" .. && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .graphite2-done

# Download pixman
download-pixman: .pixman-obtained

.pixman-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O pixman-$(PIXMAN_VER).tar.gz $(PIXMAN_URL) && tar xf pixman-$(PIXMAN_VER).tar.gz
	touch .pixman-obtained

# Compile pixman
pixman: download-pixman .pixman-done

.pixman-done:
	mkdir -p $(PIXMAN_PATH)/build && cd $(PIXMAN_PATH)/build && meson setup --prefix=/usr --native-file $(SRC_PATH)/cross_file.txt --buildtype=release .. && ninja -j$(THREADS) && \
	DESTDIR=$(STAGING_PATH) ninja -j$(THREADS) install
	touch .pixman-done

# Download libpng
download-libpng: .libpng-obtained

.libpng-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libpng-$(LIBPNG_VER).tar.xz $(LIBPNG_URL) && tar xf libpng-$(LIBPNG_VER).tar.xz && \
	cd $(LIBPNG_PATH) && curl -s -L $(LIBPNG_PATCH_URL) | gzip -d | patch -p1
	touch .libpng-obtained

# Compile libpng
libpng: download-libpng .libpng-done

.libpng-done:
	# BFD is needed for libpng's PNG16_0 symbol versions, which Cairo requires.
	cd $(LIBPNG_PATH) && { $(MAKE) distclean >/dev/null 2>&1 || true; } && \
	CFLAGS="-O2 -std=gnu17" LDFLAGS="-fuse-ld=bfd" ./configure --prefix=/usr --disable-static && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && \
	mkdir -p $(STAGING_PATH)/usr/share/doc/libpng-$(LIBPNG_VER) && cp README libpng-manual.txt $(STAGING_PATH)/usr/share/doc/libpng-$(LIBPNG_VER)
	touch .libpng-done

# Download squashfs-tools
download-squashfs-tools: .squashfs-tools-obtained
.squashfs-tools-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O squashfs-tools-$(SQUASHFS_TOOLS_VER).tar.gz $(SQUASHFS_TOOLS_URL) && tar xf squashfs-tools-$(SQUASHFS_TOOLS_VER).tar.gz
	touch .squashfs-tools-obtained

# Compile squashfs-tools
squashfs-tools: download-squashfs-tools .squashfs-tools-done
.squashfs-tools-done:
	cd $(SQUASHFS_TOOLS_PATH)/squashfs-tools && $(MAKE) -j$(THREADS) && $(MAKE) INSTALL_PREFIX=$(STAGING_PATH)/usr install
	touch .squashfs-tools-done

# Download LZO
download-lzo: .lzo-obtained
.lzo-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O lzo-$(LZO_VER).tar.gz $(LZO_URL) && tar xf lzo-$(LZO_VER).tar.gz
	touch .lzo-obtained

# Compile LZO
lzo: download-lzo .lzo-done
.lzo-done:
	cd $(LZO_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --enable-shared --disable-static --docdir=/usr/share/doc/lzo-$(LZO_VER) && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .lzo-done

# Download efibootmgr
download-efibootmgr: .efibootmgr-obtained
.efibootmgr-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O efibootmgr-$(EFIBOOTMGR_VER).tar.gz $(EFIBOOTMGR_URL) && tar xf efibootmgr-$(EFIBOOTMGR_VER).tar.gz
	touch .efibootmgr-obtained

# Compile efibootmgr
efibootmgr: download-efibootmgr .efibootmgr-done
.efibootmgr-done:
	cd $(EFIBOOTMGR_PATH) && $(MAKE) -j$(THREADS) EFIDIR=arkana EFI_LOADER=grubx64.efi && $(MAKE) install EFIDIR=arkana DESTDIR=$(STAGING_PATH)
	touch .efibootmgr-done

# Download efivar
download-efivar: .efivar-obtained
.efivar-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O efivar-$(EFIVAR_VER).tar.gz $(EFIVAR_URL) && tar xf efivar-$(EFIVAR_VER).tar.gz
	touch .efivar-obtained

# Compile efivar
efivar: download-efivar .efivar-done
.efivar-done:
	cd $(EFIVAR_PATH) && $(MAKE) -j$(THREADS) ENABLE_DOCS=0 && $(MAKE) install ENABLE_DOCS=0 LIBDIR=/usr/lib DESTDIR=$(STAGING_PATH)
	touch .efivar-done

# Assemble initramfs
.PHONY: initramfs
initramfs:
	mkdir -p $(ISO_STAGING_PATH)/boot/grub
	cp liveinit $(CPIO_STAGING_PATH)/init
	rm -rf $(CPIO_STAGING_PATH)/lib/modules
	$(MAKE) -C $(LINUX_PATH) INSTALL_MOD_PATH=$(CPIO_STAGING_PATH) modules_install
	bash -o pipefail -c 'cd "$(CPIO_STAGING_PATH)" && find . | cpio -oH newc | gzip > "$(ISO_STAGING_PATH)/boot/initramfs.img"'

.PHONY: boot-initramfs
boot-initramfs:
	cp bootinit $(CPIO_STAGING_PATH)/init
	bash -o pipefail -c 'cd "$(CPIO_STAGING_PATH)" && find . | cpio -oH newc | gzip > "$(STAGING_PATH)/boot/initramfs.img"'

# Create ISO file for booting
.PHONY: iso
iso: grub
	@test "$$(realpath -m -- "$(ISO_ROOT_PATH)")" = "$(ARKANA_CANONICAL_ISO_ROOT)" || { printf '%s\n' "error: ISO_ROOT_PATH must resolve to $(ARKANA_CANONICAL_ISO_ROOT); ISO pruners use that root" >&2; exit 1; }
	rm -rf $(ISO_ROOT_PATH)
	mkdir -p $(ISO_ROOT_PATH)
	# Rootless builds cannot preserve foreign UID/ACL metadata or copy static device nodes.
	rsync -a --no-owner --no-group --exclude='/dev/fuse' \
	  --exclude='/tmp/arkana-grub-iso-source.*' --exclude='/tmp/arkana-grub-iso-output.*' \
	  $(STAGING_PATH)/ $(ISO_ROOT_PATH)/
	printf 'arkanaOS ISO root\n' > $(ISO_ROOT_PATH)/.arkana-iso-root
	# Keep the browser and optional development/diagnostic tools in arkpkg packages.
	rm -rf $(ISO_ROOT_PATH)/opt/firefox $(ISO_ROOT_PATH)/usr/lib/git-core \
	  $(ISO_ROOT_PATH)/usr/libexec/git-core $(ISO_ROOT_PATH)/usr/share/git-core \
	  $(ISO_ROOT_PATH)/usr/share/fastfetch $(ISO_ROOT_PATH)/usr/share/vim \
	  $(ISO_ROOT_PATH)/usr/share/NsCDE/integration/firefox \
	  $(ISO_ROOT_PATH)/usr/share/licenses/fastfetch \
	  $(ISO_ROOT_PATH)/usr/share/doc/vim-*
	rm -f $(ISO_ROOT_PATH)/usr/bin/firefox $(ISO_ROOT_PATH)/usr/bin/fastfetch \
	  $(ISO_ROOT_PATH)/usr/bin/git* $(ISO_ROOT_PATH)/usr/bin/vim* \
	  $(ISO_ROOT_PATH)/usr/bin/ex $(ISO_ROOT_PATH)/usr/bin/view \
	  $(ISO_ROOT_PATH)/usr/bin/rvim $(ISO_ROOT_PATH)/usr/bin/rview \
	  $(ISO_ROOT_PATH)/usr/share/applications/firefox.desktop \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/fastfetch.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/vim.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/vimdiff.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/vimtutor.1 \
	  $(ISO_ROOT_PATH)/usr/share/bash-completion/completions/fastfetch \
	  $(ISO_ROOT_PATH)/usr/share/bash-completion/completions/git \
	  $(ISO_ROOT_PATH)/usr/share/fish/vendor_completions.d/fastfetch.fish \
	  $(ISO_ROOT_PATH)/usr/share/fish/vendor_completions.d/git.fish \
	  $(ISO_ROOT_PATH)/usr/share/zsh/site-functions/_fastfetch \
	  $(ISO_ROOT_PATH)/usr/share/zsh/site-functions/_git
	find $(ISO_ROOT_PATH)/usr/share/locale -path '*/LC_MESSAGES/git.mo' -delete
	# Move optional image, debugger, ISO authoring, and nested X servers into arkpkg packages.
	rm -rf $(ISO_ROOT_PATH)/usr/lib/ImageMagick-7.1.2 \
	  $(ISO_ROOT_PATH)/usr/share/ImageMagick-7 $(ISO_ROOT_PATH)/usr/share/gdb
	rm -f $(ISO_ROOT_PATH)/usr/bin/animate $(ISO_ROOT_PATH)/usr/bin/compare \
	  $(ISO_ROOT_PATH)/usr/bin/composite $(ISO_ROOT_PATH)/usr/bin/conjure \
	  $(ISO_ROOT_PATH)/usr/bin/convert $(ISO_ROOT_PATH)/usr/bin/display \
	  $(ISO_ROOT_PATH)/usr/bin/identify $(ISO_ROOT_PATH)/usr/bin/import \
	  $(ISO_ROOT_PATH)/usr/bin/magick $(ISO_ROOT_PATH)/usr/bin/magick-script \
	  $(ISO_ROOT_PATH)/usr/bin/mogrify $(ISO_ROOT_PATH)/usr/bin/montage \
	  $(ISO_ROOT_PATH)/usr/bin/stream $(ISO_ROOT_PATH)/usr/bin/gdb \
	  $(ISO_ROOT_PATH)/usr/bin/gdb-add-index $(ISO_ROOT_PATH)/usr/bin/gdbserver \
	  $(ISO_ROOT_PATH)/usr/bin/xorriso $(ISO_ROOT_PATH)/usr/bin/xorriso-dd-target \
	  $(ISO_ROOT_PATH)/usr/bin/xorriso-tcltk $(ISO_ROOT_PATH)/usr/bin/xorrisofs \
	  $(ISO_ROOT_PATH)/usr/bin/Xnest $(ISO_ROOT_PATH)/usr/bin/Xvfb \
	  $(ISO_ROOT_PATH)/usr/bin/gdbm_dump $(ISO_ROOT_PATH)/usr/bin/gdbm_load \
	  $(ISO_ROOT_PATH)/usr/bin/gdbmtool $(ISO_ROOT_PATH)/usr/bin/xmlcatalog \
	  $(ISO_ROOT_PATH)/usr/bin/xml2-config $(ISO_ROOT_PATH)/usr/bin/xmllint \
	  $(ISO_ROOT_PATH)/usr/bin/xmlwf $(ISO_ROOT_PATH)/usr/bin/cjpeg \
	  $(ISO_ROOT_PATH)/usr/bin/djpeg $(ISO_ROOT_PATH)/usr/bin/jpegtran \
	  $(ISO_ROOT_PATH)/usr/bin/rdjpgcom $(ISO_ROOT_PATH)/usr/bin/wrjpgcom \
	  $(ISO_ROOT_PATH)/usr/bin/cwebp $(ISO_ROOT_PATH)/usr/bin/dwebp \
	  $(ISO_ROOT_PATH)/usr/bin/gif2webp $(ISO_ROOT_PATH)/usr/bin/img2webp \
	  $(ISO_ROOT_PATH)/usr/bin/webpinfo $(ISO_ROOT_PATH)/usr/bin/webpmux \
	  $(ISO_ROOT_PATH)/usr/bin/openssl \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/gdb.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/gdb-add-index.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/gdbserver.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/xorriso.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/xorriso-dd-target.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/xorriso-tcltk.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/xorrisofs.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/Xnest.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/Xvfb.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/gdbm_dump.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/gdbm_load.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/gdbmtool.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/xmlcatalog.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/xmllint.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/xmlwf.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/cjpeg.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/djpeg.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/jpegtran.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/rdjpgcom.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wrjpgcom.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/cwebp.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/gif2webp.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/img2webp.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/webpinfo.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/webpmux.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/openssl*.1ssl \
	  $(ISO_ROOT_PATH)/usr/share/man/man5/openssl*.5ssl \
	  $(ISO_ROOT_PATH)/usr/share/man/man7/openssl*.7ssl
	# FAT image helpers are available as an optional arkpkg package.
	rm -f $(ISO_ROOT_PATH)/usr/bin/mattrib $(ISO_ROOT_PATH)/usr/bin/mcopy \
	  $(ISO_ROOT_PATH)/usr/bin/mdel $(ISO_ROOT_PATH)/usr/bin/mdeltree \
	  $(ISO_ROOT_PATH)/usr/bin/mdir $(ISO_ROOT_PATH)/usr/bin/mdoctorfat \
	  $(ISO_ROOT_PATH)/usr/bin/mformat $(ISO_ROOT_PATH)/usr/bin/mlabel \
	  $(ISO_ROOT_PATH)/usr/bin/mmd $(ISO_ROOT_PATH)/usr/bin/mmove \
	  $(ISO_ROOT_PATH)/usr/bin/mpartition $(ISO_ROOT_PATH)/usr/bin/mrd \
	  $(ISO_ROOT_PATH)/usr/bin/mren $(ISO_ROOT_PATH)/usr/bin/mshowfat \
	  $(ISO_ROOT_PATH)/usr/bin/mtools $(ISO_ROOT_PATH)/usr/bin/mtoolstest \
	  $(ISO_ROOT_PATH)/usr/bin/mtype $(ISO_ROOT_PATH)/usr/bin/mzip \
	  $(ISO_ROOT_PATH)/usr/share/info/mtools.info \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mattrib.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mcopy.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mdel.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mdeltree.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mdir.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mdoctorfat.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mformat.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mlabel.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mmd.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mmove.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mpartition.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mrd.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mren.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mshowfat.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mtools.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mtoolstest.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mtype.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/mzip.1
	# Retain Python itself and its build support, but omit upstream self-tests and test fixtures.
	rm -rf $(ISO_ROOT_PATH)/usr/lib/python3.13/test $(ISO_ROOT_PATH)/usr/lib/installed-tests
	python3 prune-runtime-docs
	python3 prune-optional-devel
	# Keep the default image focused on NsCDE; optional window managers and SDKs are packages.
	rm -rf $(ISO_ROOT_PATH)/etc/xdg/openbox $(ISO_ROOT_PATH)/usr/include/openbox \
	  $(ISO_ROOT_PATH)/usr/lib/openbox-* $(ISO_ROOT_PATH)/usr/share/themes/*/openbox-3 \
	  $(ISO_ROOT_PATH)/usr/share/gnome-session/sessions/openbox* \
	  $(ISO_ROOT_PATH)/usr/share/wayland-protocols $(ISO_ROOT_PATH)/usr/include/wayland-protocols \
	  $(ISO_ROOT_PATH)/usr/share/wayland $(ISO_ROOT_PATH)/usr/include/libweston-14 \
	  $(ISO_ROOT_PATH)/usr/include/weston $(ISO_ROOT_PATH)/usr/include/wlroots-0.19 \
	  $(ISO_ROOT_PATH)/usr/include/sfdo-*.h $(ISO_ROOT_PATH)/usr/include/libseat.h \
	  $(ISO_ROOT_PATH)/usr/include/xkbcommon $(ISO_ROOT_PATH)/usr/include/X11/extensions/xwaylandproto.h \
	  $(ISO_ROOT_PATH)/usr/lib/libweston-14 $(ISO_ROOT_PATH)/usr/lib/weston \
	  $(ISO_ROOT_PATH)/usr/lib/weston-* $(ISO_ROOT_PATH)/usr/lib/xkbcommon \
	  $(ISO_ROOT_PATH)/usr/share/weston $(ISO_ROOT_PATH)/usr/share/libweston-14 \
	  $(ISO_ROOT_PATH)/usr/share/wayland-sessions/labwc.desktop \
	  $(ISO_ROOT_PATH)/usr/share/wayland-sessions/weston.desktop \
	  $(ISO_ROOT_PATH)/usr/share/xdg-desktop-portal/labwc-portals.conf \
	  $(ISO_ROOT_PATH)/usr/share/applications/openbox.desktop \
	  $(ISO_ROOT_PATH)/usr/share/applications/org.freedesktop.Xwayland.desktop \
	  $(ISO_ROOT_PATH)/usr/share/xsessions/openbox*.desktop \
	  $(ISO_ROOT_PATH)/usr/share/gnome/wm-properties/openbox.desktop \
	  $(ISO_ROOT_PATH)/usr/share/pixmaps/openbox.png \
	  $(ISO_ROOT_PATH)/usr/share/locale/*/LC_MESSAGES/openbox.mo \
	  $(ISO_ROOT_PATH)/usr/share/locale/*/LC_MESSAGES/labwc.mo \
	  $(ISO_ROOT_PATH)/usr/share/licenses/documentation/openbox-3.6.1 \
	  $(ISO_ROOT_PATH)/usr/share/licenses/documentation/labwc* \
	  $(ISO_ROOT_PATH)/usr/share/licenses/documentation/wlroots* \
	  $(ISO_ROOT_PATH)/usr/share/licenses/documentation/weston* \
	  $(ISO_ROOT_PATH)/usr/share/licenses/documentation/seatd* \
	  $(ISO_ROOT_PATH)/usr/share/licenses/documentation/wayland-* \
	  $(ISO_ROOT_PATH)/usr/share/licenses/documentation/xwayland* \
	  $(ISO_ROOT_PATH)/usr/share/licenses/documentation/libxkbcommon*
	rm -f $(ISO_ROOT_PATH)/usr/bin/openbox* $(ISO_ROOT_PATH)/usr/bin/labwc \
	  $(ISO_ROOT_PATH)/usr/bin/weston* $(ISO_ROOT_PATH)/usr/bin/Xwayland \
	  $(ISO_ROOT_PATH)/usr/bin/seatd $(ISO_ROOT_PATH)/usr/bin/seatd-launch \
	  $(ISO_ROOT_PATH)/usr/bin/wayland-scanner $(ISO_ROOT_PATH)/usr/bin/xkbcli \
	  $(ISO_ROOT_PATH)/usr/lib/libobrender.* $(ISO_ROOT_PATH)/usr/lib/libobt.* \
	  $(ISO_ROOT_PATH)/usr/lib/libweston-14.so* $(ISO_ROOT_PATH)/usr/lib/libwlroots-0.19.so \
	  $(ISO_ROOT_PATH)/usr/lib/libsfdo-* $(ISO_ROOT_PATH)/usr/lib/libseat.so* \
	  $(ISO_ROOT_PATH)/usr/lib/pkgconfig/obrender-3.5.pc \
	  $(ISO_ROOT_PATH)/usr/lib/pkgconfig/obt-3.5.pc \
	  $(ISO_ROOT_PATH)/usr/lib/pkgconfig/wlroots-0.19.pc \
	  $(ISO_ROOT_PATH)/usr/lib/pkgconfig/libsfdo-*.pc \
	  $(ISO_ROOT_PATH)/usr/lib/pkgconfig/libseat.pc \
	  $(ISO_ROOT_PATH)/usr/lib/pkgconfig/libweston-14.pc \
	  $(ISO_ROOT_PATH)/usr/lib/pkgconfig/weston.pc \
	  $(ISO_ROOT_PATH)/usr/lib/pkgconfig/wayland-*.pc \
	  $(ISO_ROOT_PATH)/usr/lib/pkgconfig/xkbcommon*.pc \
	  $(ISO_ROOT_PATH)/usr/share/pkgconfig/libweston-14-protocols.pc \
	  $(ISO_ROOT_PATH)/usr/share/pkgconfig/wayland-protocols.pc \
	  $(ISO_ROOT_PATH)/usr/share/pkgconfig/xwaylandproto.pc \
	  $(ISO_ROOT_PATH)/usr/share/aclocal/wayland-scanner.m4 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/openbox*.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/labwc*.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/weston*.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/seatd*.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/Xwayland.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wayland-scanner.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/xkbcli*.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man5/weston*.5 \
	  $(ISO_ROOT_PATH)/usr/share/man/man7/weston*.7 \
	  $(ISO_ROOT_PATH)/usr/lib/systemd/system/seatd.service \
	  $(ISO_ROOT_PATH)/etc/systemd/system/multi-user.target.wants/seatd.service \
	  $(ISO_ROOT_PATH)/usr/include/wayland-*.h \
	  $(ISO_ROOT_PATH)/usr/include/wayland-version.h
	cp -a arkana-install $(ISO_ROOT_PATH)/usr/bin/arkana-install
	cp -a genfstab $(ISO_ROOT_PATH)/usr/bin/genfstab
	cp -a neofetch $(ISO_ROOT_PATH)/usr/bin/neofetch
	chmod +x $(ISO_ROOT_PATH)/usr/bin/neofetch
	cp -a xinitrc $(ISO_ROOT_PATH)/root/.xinitrc
	mkdir -p $(ISO_ROOT_PATH)/etc/skel && cp -a xinitrc $(ISO_ROOT_PATH)/etc/skel/.xinitrc
	install -D -m 0755 xinitrc $(ISO_ROOT_PATH)/usr/bin/arkana-nscde-session
	install -D -o 0 -g 0 -m 0644 bash_profile $(ISO_ROOT_PATH)/root/.bash_profile
	install -D -o 0 -g 0 -m 0644 bash_profile $(ISO_ROOT_PATH)/etc/skel/.bash_profile
	install -D -o 0 -g 0 -m 0644 securetty $(ISO_ROOT_PATH)/etc/securetty
	install -D -o 0 -g 0 -m 0644 nscde-config/Xresources $(ISO_ROOT_PATH)/etc/X11/Xresources.d/arkanaOS
	install -D -o 0 -g 0 -m 0644 bashrc $(ISO_ROOT_PATH)/root/.bashrc
	install -D -o 0 -g 0 -m 0644 bashrc $(ISO_ROOT_PATH)/etc/skel/.bashrc
	install -D -o 0 -g 0 -m 0644 bashrc $(ISO_ROOT_PATH)/etc/profile.d/arkana-shell.sh
	mkdir -p $(ISO_ROOT_PATH)/root/.NsCDE/backer $(ISO_ROOT_PATH)/etc/skel/.NsCDE/backer
	cp -a nscde-config/Backdrops.fvwmgen $(ISO_ROOT_PATH)/root/.NsCDE/
	cp -a nscde-config/Backdrops.fvwmgen $(ISO_ROOT_PATH)/etc/skel/.NsCDE/
	for desk in 1 2 3 4 5 6 7 8; do \
	  chroot $(ISO_ROOT_PATH) /usr/lib/NsCDE/palette_colorgen -p /usr/share/NsCDE/palettes/Solyaris.dp -n 4 -i /usr/share/NsCDE/backdrops/Solyaris.pm -P 3 -b > $(ISO_ROOT_PATH)/root/.NsCDE/backer/Desk$$desk-Solyaris.pm || exit 1; \
	  cp $(ISO_ROOT_PATH)/root/.NsCDE/backer/Desk$$desk-Solyaris.pm $(ISO_ROOT_PATH)/etc/skel/.NsCDE/backer/; \
	done
	chroot $(ISO_ROOT_PATH) /usr/lib/NsCDE/palette_colorgen -p /usr/share/NsCDE/palettes/Solyaris.dp -n 4 -f > $(ISO_ROOT_PATH)/usr/share/NsCDE/fvwm/Colorset.fvwmconf
	sed -i \
	  -e 's/^InfoStoreAdd nscde_use_xscreensaver 1$$/InfoStoreAdd nscde_use_xscreensaver 0/' \
	  -e 's/^InfoStoreAdd nscde_use_stalonetray 1$$/InfoStoreAdd nscde_use_stalonetray 0/' \
	  -e 's/^InfoStoreAdd nscde_use_dunst 1$$/InfoStoreAdd nscde_use_dunst 0/' \
	  $(ISO_ROOT_PATH)/usr/share/NsCDE/fvwm/NsCDE.conf
	sed -i 's|^+ I Test (!f .*NsCDE[.]conf.*) f_FirstSetup$$|+ I Test (!EnvMatch NSCDE_SKIP_FIRST_RUN 1, !f "$$[FVWM_USERDIR]/NsCDE.conf") f_FirstSetup|' \
	  $(ISO_ROOT_PATH)/usr/share/NsCDE/fvwm/Main.fvwmconf
	test "$$(grep -Fc NSCDE_SKIP_FIRST_RUN $(ISO_ROOT_PATH)/usr/share/NsCDE/fvwm/Main.fvwmconf)" -eq 2
	sed -i 's|^Exec=.*[/]nscde$$|Exec=/usr/bin/arkana-nscde-session|' $(ISO_ROOT_PATH)/usr/share/xsessions/nscde.desktop
	sed -i -e 's/DejaVu Serif/Luxi Sans/g' -e 's/DejaVu Sans Mono/Luxi Mono/g' $(ISO_ROOT_PATH)/usr/share/NsCDE/fvwm/Font-*dpi.fvwmconf
	mkdir -p $(ISO_ROOT_PATH)/etc/systemd/system/serial-getty@ttyS0.service.d
	printf '[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin root --noclear --keep-baud 115200,38400,9600 %%I vt220\n' > $(ISO_ROOT_PATH)/etc/systemd/system/serial-getty@ttyS0.service.d/override.conf
	rm -rf $(ISO_ROOT_PATH)/root/GNUstep $(ISO_ROOT_PATH)/etc/skel/GNUstep \
	  $(ISO_ROOT_PATH)/etc/WindowMaker \
	  $(ISO_ROOT_PATH)/usr/share/WindowMaker $(ISO_ROOT_PATH)/usr/share/WINGs \
	  $(ISO_ROOT_PATH)/usr/share/WPrefs $(ISO_ROOT_PATH)/usr/include/WINGs \
	  $(ISO_ROOT_PATH)/usr/include/WUtil
	rm -f $(ISO_ROOT_PATH)/usr/bin/wmaker $(ISO_ROOT_PATH)/usr/bin/wmaker.inst \
	  $(ISO_ROOT_PATH)/usr/bin/WPrefs $(ISO_ROOT_PATH)/usr/bin/getstyle \
	  $(ISO_ROOT_PATH)/usr/bin/setstyle $(ISO_ROOT_PATH)/usr/bin/wdctl \
	  $(ISO_ROOT_PATH)/usr/bin/wdread $(ISO_ROOT_PATH)/usr/bin/wdwrite \
	  $(ISO_ROOT_PATH)/usr/bin/wm-oldmenu2new $(ISO_ROOT_PATH)/usr/bin/wmagnify \
	  $(ISO_ROOT_PATH)/usr/bin/wmgenmenu $(ISO_ROOT_PATH)/usr/bin/wmiv \
	  $(ISO_ROOT_PATH)/usr/bin/wmmenugen $(ISO_ROOT_PATH)/usr/bin/wmsetbg \
	  $(ISO_ROOT_PATH)/usr/bin/twm $(ISO_ROOT_PATH)/usr/include/WMaker.h \
	  $(ISO_ROOT_PATH)/usr/include/wraster.h $(ISO_ROOT_PATH)/usr/lib/libWMaker.* \
	  $(ISO_ROOT_PATH)/usr/lib/libWINGs.* $(ISO_ROOT_PATH)/usr/lib/libWUtil.a \
	  $(ISO_ROOT_PATH)/usr/lib/libWUtil.la $(ISO_ROOT_PATH)/usr/lib/libWUtil.so \
	  $(ISO_ROOT_PATH)/usr/lib/libwraster.* $(ISO_ROOT_PATH)/usr/lib/pkgconfig/WINGs.pc \
	  $(ISO_ROOT_PATH)/usr/lib/pkgconfig/WUtil.pc \
	  $(ISO_ROOT_PATH)/usr/share/bash-completion/completions/wdctl \
	  $(ISO_ROOT_PATH)/usr/share/applications/WPrefs.desktop \
	  $(ISO_ROOT_PATH)/usr/share/xsessions/wmaker.desktop \
	  $(ISO_ROOT_PATH)/usr/share/xsessions/twm.desktop \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/WindowMaker.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wmaker.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/WPrefs.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/getstyle.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/setstyle.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wdctl.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wdread.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wdwrite.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wm-oldmenu2new.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wmagnify.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wmgenmenu.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wmiv.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wmmenugen.1 \
	  $(ISO_ROOT_PATH)/usr/share/man/man8/wdctl.8 \
	  $(ISO_ROOT_PATH)/usr/share/man/man1/wmsetbg.1
	mkdir -p $(ISO_ROOT_PATH)/etc/X11/xorg.conf.d
	printf 'Section "Device"\n    Identifier "Card0"\n    Option "SWcursor" "true"\n    Option "HWCursor" "false"\nEndSection\n' > $(ISO_ROOT_PATH)/etc/X11/xorg.conf.d/99-swcursor.conf
	sed -i 's/arkanaOS Dev/arkanaOS nightly/g' $(ISO_ROOT_PATH)/etc/os-release 2>/dev/null || true
	sed -i 's/arkanaOS Dev/arkanaOS nightly/g' $(ISO_ROOT_PATH)/etc/issue 2>/dev/null || true
    
	ln -sf /usr/bin/bzdiff $(ISO_ROOT_PATH)/usr/bin/bzcmp
	ln -sf /usr/bin/bzgrep $(ISO_ROOT_PATH)/usr/bin/bzegrep
	ln -sf /usr/bin/bzgrep $(ISO_ROOT_PATH)/usr/bin/bzfgrep
	ln -sf /usr/bin/bzmore $(ISO_ROOT_PATH)/usr/bin/bzless
	ln -sf /usr/lib/p11-kit/trust-extract-compat $(ISO_ROOT_PATH)/usr/bin/update-ca-certificates
	printf '/usr/lib/x86_64-linux-gnu\n' > $(ISO_ROOT_PATH)/etc/ld.so.conf
	ln -sfn ../ca-bundle.crt $(ISO_ROOT_PATH)/etc/ssl/certs/ca-certificates.crt

	chroot $(ISO_ROOT_PATH) fc-cache -fv || true
	chroot $(ISO_ROOT_PATH) glib-compile-schemas /usr/share/glib-2.0/schemas || true
	rm -f $(ISO_ROOT_PATH)/etc/ld.so.cache
	chroot $(ISO_ROOT_PATH) /usr/bin/ldconfig
	rm -f $(ISO_ROOT_PATH)/etc/udev/hwdb.bin
	/usr/bin/systemd-hwdb --root=$(ISO_ROOT_PATH) --usr update
	rm -f $(ISO_ROOT_PATH)/etc/arkana-install-size
	set -euo pipefail; \
	INSTALL_ROOT_BYTES=$$(cd "$(ISO_ROOT_PATH)" && du -sx --apparent-size --block-size=1 --exclude='./boot/vmlinuz' --exclude='./boot/initramfs.img' . | awk '{print $$1}'); \
	BOOT_PAYLOAD_BYTES=$$(( $$(stat -c '%s' "$(LINUX_PATH)/arch/x86/boot/bzImage") + $$(stat -c '%s' "$(ISO_ROOT_PATH)/boot/initramfs.img") )); \
	printf '%s %s\n' "$$INSTALL_ROOT_BYTES" "$$BOOT_PAYLOAD_BYTES" > "$(ISO_ROOT_PATH)/etc/arkana-install-size"

	# Normalize privileged runtime ownership and modes after all package installs.
	chmod 4755 \
	  $(ISO_ROOT_PATH)/usr/bin/sudo $(ISO_ROOT_PATH)/usr/bin/passwd \
	  $(ISO_ROOT_PATH)/usr/bin/chfn $(ISO_ROOT_PATH)/usr/bin/chsh \
	  $(ISO_ROOT_PATH)/usr/bin/gpasswd $(ISO_ROOT_PATH)/usr/bin/newgrp \
	  $(ISO_ROOT_PATH)/usr/bin/su $(ISO_ROOT_PATH)/usr/bin/fusermount3 \
	  $(ISO_ROOT_PATH)/usr/sbin/unix_chkpwd
	DBUS_GID=$$(awk -F: '$$1 == "messagebus" { print $$3 }' $(ISO_ROOT_PATH)/etc/group); \
	  test -n "$$DBUS_GID" && \
	  chown 0:"$$DBUS_GID" $(ISO_ROOT_PATH)/usr/lib/dbus-daemon-launch-helper && \
	  chmod 4750 $(ISO_ROOT_PATH)/usr/lib/dbus-daemon-launch-helper

	mksquashfs $(ISO_ROOT_PATH) $(ISO_STAGING_PATH)/boot/rootfs.sfs -comp zstd -Xcompression-level 15 -b 1M -processors $(MKSQUASHFS_THREADS) -noappend -e boot/vmlinuz boot/initramfs.img
	cp $(LINUX_PATH)/arch/x86/boot/bzImage $(ISO_STAGING_PATH)/boot/vmlinuz
	cp $(ISO_ROOT_PATH)/boot/initramfs.img $(ISO_STAGING_PATH)/boot/boot-initramfs.img

	echo 'set timeout=5' > $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo 'set default=0' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo 'serial --unit=0 --speed=115200' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo 'terminal_input serial console' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo 'terminal_output serial console' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo 'menuentry "arkanaOS" {' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo '    linux /boot/vmlinuz console=tty0' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo '    initrd /boot/initramfs.img' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo '}' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg

	GRUB_INSTALL_VERSION=$$(chroot $(STAGING_PATH) /usr/sbin/grub-install --version); \
	GRUB_MKRESCUE_VERSION=$$(chroot $(STAGING_PATH) /usr/bin/grub-mkrescue --version); \
	for version in "$$GRUB_INSTALL_VERSION" "$$GRUB_MKRESCUE_VERSION"; do \
	  printf '%s\n' "$$version" | grep -Fq "(GRUB) $(GRUB_VER)" || { \
	    echo "GRUB version mismatch: expected $(GRUB_VER), got $$version" >&2; exit 1; \
	  }; \
	done; \
	set -euo pipefail; \
	GRUB_RESCUE_SOURCE=$$(mktemp -d $(STAGING_PATH)/tmp/arkana-grub-iso-source.XXXXXX); \
	GRUB_RESCUE_OUTPUT=$$(mktemp -d $(STAGING_PATH)/tmp/arkana-grub-iso-output.XXXXXX); \
	trap 'rm -rf "$$GRUB_RESCUE_SOURCE" "$$GRUB_RESCUE_OUTPUT"' EXIT; \
	cp -al $(ISO_STAGING_PATH)/. "$$GRUB_RESCUE_SOURCE"/; \
	chroot $(STAGING_PATH) /usr/bin/grub-mkrescue \
	  -o "/tmp/$$(basename "$$GRUB_RESCUE_OUTPUT")/arkana.iso" \
	  "/tmp/$$(basename "$$GRUB_RESCUE_SOURCE")" -- -volid "ARKANA"; \
	mv "$$GRUB_RESCUE_OUTPUT/arkana.iso" $(OUTPUT_PATH)/arkana.iso
