# Enable multi-threaded Bash operation
SHELL = bash
THREADS = $(shell nproc)

# Paths used to build the ISO components
SRC_PATH = $(shell realpath ./src)
STAGING_PATH = $(shell realpath ./staging)
CPIO_STAGING_PATH = $(shell realpath ./cpio-staging)
ISO_STAGING_PATH = $(shell realpath ./iso-staging)
OUTPUT_PATH = $(shell realpath ./output)

# Cpio
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/cpio.html
CPIO_URL = https://mirrors.ocf.berkeley.edu/gnu/cpio/cpio-2.15.tar.gz
CPIO_FALLBACK_URL = https://ftp.gnu.org/gnu/cpio/cpio-2.15.tar.gz
CPIO_VER = 2.15
CPIO_PATH = $(SRC_PATH)/cpio-$(CPIO_VER)

# libisoburn (provides xorriso required by grub-mkrescue)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/multimedia/libisoburn.html
LIBISOBURN_URL = http://files.libburnia-project.org/releases/libisoburn-1.5.6.tar.gz
LIBISOBURN_VER = 1.5.6
LIBISOBURN_PATH = $(SRC_PATH)/libisoburn-$(LIBISOBURN_VER)

# Libburn
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/multimedia/libburn.html
LIBBURN_URL = http://files.libburnia-project.org/releases/libburn-1.5.6.tar.gz
LIBBURN_VER = 1.5.6
LIBBURN_PATH = $(SRC_PATH)/libburn-$(LIBBURN_VER)

# Libisofs
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/multimedia/libisofs.html
LIBISOFS_URL = http://files.libburnia-project.org/releases/libisofs-1.5.6.tar.gz
LIBISOFS_VER = 1.5.6
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
LINUX_URL = https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.17.6.tar.gz
LINUX_VER = 6.17.6
LINUX_PATH = $(SRC_PATH)/linux-$(LINUX_VER)

# GRUB (bootloader)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/grub-efi.html
GRUB_URL = https://mirrors.ocf.berkeley.edu/gnu/grub/grub-2.12.tar.gz
GRUB_FALLBACK_URL = https://ftp.gnu.org/gnu/grub/grub-2.12.tar.gz
GRUB_FONT_URL = https://unifoundry.com/pub/unifont/unifont-16.0.01/font-builds/unifont-16.0.01.pcf.gz
GRUB_VER = 2.12
GRUB_PATH = $(SRC_PATH)/grub-$(GRUB_VER)

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
GLIB_URL = https://download.gnome.org/sources/glib/2.84/glib-2.84.4.tar.xz
GLIB_VER = 2.84.4
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
# URL: https://ftp.debian.org/debian/pool/main/s/squashfs-tools/ (has source code)
SQUASHFS_TOOLS_URL = http://ftp.debian.org/debian/pool/main/s/squashfs-tools/squashfs-tools_4.7.4.orig.tar.gz
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

# Targets
all: build initramfs boot-initramfs iso

build: cpio busybox linux grub freetype harfbuzz glib libffi elfutils brotli pcre2 cairo fontconfig expat graphite2 pixman libpng libisoburn libburn libisofs mtools squashfs-tools lzo efibootmgr efivar

# Download cpio
download-cpio: .cpio-obtained

.cpio-obtained:
	cd $(SRC_PATH) && ( wget -O cpio-$(CPIO_VER).tar.gz $(CPIO_URL) || wget -O cpio-$(CPIO_VER).tar.gz $(CPIO_FALLBACK_URL) ) && tar xf cpio-$(CPIO_VER).tar.gz
	touch .cpio-obtained

# Compile cpio
cpio: download-cpio .cpio-done

.cpio-done:
	cd $(CPIO_PATH) && sed -e "/^extern int (\*xstat)/s/()/(const char * restrict,  struct stat * restrict)/" -i src/extern.h && \
	sed -e "/^int (\*xstat)/s/()/(const char * restrict,  struct stat * restrict)/" -i src/global.c && \
	./configure --prefix=/usr --enable-mt --with-rmt=/usr/lib/rmt && $(MAKE) -j$(THREADS) && \
	makeinfo --html -o doc/html doc/cpio.texi && \
	makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi && \
	makeinfo --plaintext -o doc/cpio.txt doc/cpio.texi && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install && install -v -m755 -d $(STAGING_PATH)/usr/share/doc/cpio-$(CPIO_VER)/html && \
	install -v -m644 doc/html/* $(STAGING_PATH)/usr/share/doc/cpio-$(CPIO_VER)/html && \
	install -v -m644 doc/cpio.{html,txt} $(STAGING_PATH)/usr/share/doc/cpio-$(CPIO_VER)
	touch .cpio-done

# Download libisoburn
download-libisoburn: .libisoburn-obtained

.libisoburn-obtained:
	cd $(SRC_PATH) && wget -O libisoburn-$(LIBISOBURN_VER).tar.gz $(LIBISOBURN_URL) && tar xf libisoburn-$(LIBISOBURN_VER).tar.gz
	touch .libisoburn-obtained

# Compile libisoburn
libisoburn: download-libisoburn .libisoburn-done

.libisoburn-done:
	cd $(LIBISOBURN_PATH) && ./configure --prefix=/usr --enable-pkg-check-modules && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libisoburn-done

# Download libburn
download-libburn: .libburn-obtained

.libburn-obtained:
	cd $(SRC_PATH) && wget -O libburn-$(LIBBURN_VER).tar.gz $(LIBBURN_URL) && tar xf libburn-$(LIBBURN_VER).tar.gz
	touch .libburn-obtained

# Compile libburn
libburn: download-libburn .libburn-done

.libburn-done:
	cd $(LIBBURN_PATH) && sed -i 's/catch_int ()/catch_int (int signum)/' test/poll.c && ./configure --prefix=/usr --disable-static && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libburn-done

# Download libisofs
download-libisofs: .libisofs-obtained

.libisofs-obtained:
	cd $(SRC_PATH) && wget -O libisofs-$(LIBBURN_VER).tar.gz $(LIBISOFS_URL) && tar xf libisofs-$(LIBBURN_VER).tar.gz
	touch .libisofs-obtained

# Compile libisofs
libisofs: download-libisofs .libisofs-done

.libisofs-done:
	cd $(LIBISOFS_PATH) && ./configure --prefix=/usr --disable-static && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libisofs-done

# Download mtools
download-mtools: .mtools-obtained

.mtools-obtained:
	cd $(SRC_PATH) && ( wget -O mtools-$(MTOOLS_VER).tar.gz $(MTOOLS_URL) || wget -O mtools-$(MTOOLS_VER).tar.gz $(MTOOLS_FALLBACK_URL) ) && tar xf mtools-$(MTOOLS_VER).tar.gz
	touch .mtools-obtained

# Compile mtools
mtools: download-mtools .mtools-done

.mtools-done:
	cd $(MTOOLS_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .mtools-done

# Download Busybox
download-busybox: .busybox-obtained

.busybox-obtained:
	cd $(SRC_PATH) && wget -O busybox-$(BUSYBOX_VER).tar.bz2 $(BUSYBOX_URL) && tar xf busybox-$(BUSYBOX_VER).tar.bz2
	touch .busybox-obtained

# Compile BusyBox
busybox: download-busybox .busybox-done

.busybox-done:
	mkdir -p $(CPIO_STAGING_PATH)/{boot,dev,etc,home,mnt,opt,proc,root,run,sys,tmp,var}
	cp busybox.config $(BUSYBOX_PATH)/.config && cd $(BUSYBOX_PATH) && expect ../../oldconfig.exp && \
	$(MAKE) -j$(THREADS) && $(MAKE) install && cp -a _install/* $(CPIO_STAGING_PATH)
	touch .busybox-done

# Download Linux kernel
download-linux: .linux-obtained

.linux-obtained:
	cd $(SRC_PATH) && wget -O linux-$(LINUX_VER).tar.gz $(LINUX_URL) && tar xf linux-$(LINUX_VER).tar.gz
	touch .linux-obtained

# Compile Linux kernel
linux: download-linux .linux-done

.linux-done:
	# Linus, you've fucked with the SBAT file config and my builder broke!
	$(MAKE) -C $(LINUX_PATH) mrproper && cp linux.config $(LINUX_PATH)/.config && cd $(LINUX_PATH) && $(MAKE) olddefconfig && \
	$(MAKE) -j$(THREADS) KBUILD_BUILD_HOST="arkana" KBUILD_BUILD_USER="arkana" all && cp arch/x86/boot/bzImage $(STAGING_PATH)/boot/vmlinuz
	touch .linux-done

# Download GRUB
download-grub: .grub-obtained

.grub-obtained:
	cd $(SRC_PATH) && ( wget -O grub-$(GRUB_VER).tar.gz $(GRUB_URL) || wget -O grub-$(GRUB_VER).tar.gz $(GRUB_FALLBACK_URL) ) && tar xf grub-$(GRUB_VER).tar.gz && \
	wget -O unifont-16.0.01.pcf.gz $(GRUB_FONT_URL)
	touch .grub-obtained

# Compile GRUB
grub: download-grub .grub-done

.grub-done:
	cd $(GRUB_PATH) && echo depends bli part_gpt > grub-core/extra_deps.lst && \
	./configure --prefix=/usr --sysconfdir=/etc --disable-efiemu --with-platform=efi \
	--target=x86_64 --disable-werror && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install

	cd $(GRUB_PATH) && $(MAKE) clean && ./configure --prefix=/usr --sysconfdir=/etc --disable-efiemu --with-platform=pc \
	--target=i386 --disable-werror && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && \
	mv $(STAGING_PATH)/etc/bash_completion.d/grub $(STAGING_PATH)/usr/share/bash-completion/completions

	# Font data here
	mkdir -p $(STAGING_PATH)/usr/share/fonts/unifont && gunzip -c $(SRC_PATH)/unifont-16.0.01.pcf.gz > $(STAGING_PATH)/usr/share/fonts/unifont/unifont.pcf

	touch .grub-done

# Download freetype
download-freetype: .freetype-obtained

.freetype-obtained:
	cd $(SRC_PATH) && wget -O freetype-$(FREETYPE_VER).tar.xz $(FREETYPE_URL) && tar xf freetype-$(FREETYPE_VER).tar.xz
	touch .freetype-obtained

# Compile freetype
freetype: download-freetype .freetype-done

.freetype-done:
	cd $(FREETYPE_PATH) && sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg && \
	sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" -i include/freetype/config/ftoption.h && \
	./configure --prefix=/usr --enable-freetype-config --disable-static && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .freetype-done

# Download harfbuzz
download-harfbuzz: .harfbuzz-obtained

.harfbuzz-obtained:
	cd $(SRC_PATH) && wget -O harfbuzz-$(HARFBUZZ_VER).tar.xz $(HARFBUZZ_URL) && tar xf harfbuzz-$(HARFBUZZ_VER).tar.xz
	touch .harfbuzz-obtained

# Compile harfbuzz
harfbuzz: download-harfbuzz .harfbuzz-done

.harfbuzz-done:
	mkdir -p $(HARFBUZZ_PATH)/build	&& cd $(HARFBUZZ_PATH)/build && meson setup .. --prefix=/usr --buildtype=release \
	-D graphite2=enabled && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .harfbuzz-done

# Download glib
download-glib: .glib-obtained

.glib-obtained:
	cd $(SRC_PATH) && wget -O glib-$(GLIB_VER).tar.xz $(GLIB_URL) && tar xf glib-$(GLIB_VER).tar.xz
	touch .glib-obtained

# Compile glib
glib: download-glib .glib-done

.glib-done:
	mkdir -p $(GLIB_PATH)/build && cd $(GLIB_PATH)/build && meson setup .. --prefix=/usr --buildtype=release \
	-D introspection=disabled -D glib_debug=disabled -D man-pages=enabled -D sysprof=disabled && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .glib-done

# Download libffi
download-libffi: .libffi-obtained

.libffi-obtained:
	cd $(SRC_PATH) && wget -O libffi-$(LIBFFI_VER).tar.gz $(LIBFFI_URL) && tar xf libffi-$(LIBFFI_VER).tar.gz
	touch .libffi-obtained

# Compile libffi
libffi: download-libffi .libffi-done

.libffi-done:
	cd $(LIBFFI_PATH) && ./configure --prefix=/usr --disable-static && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libffi-done

# Download elfutils
download-elfutils: .elfutils-obtained

.elfutils-obtained:
	cd $(SRC_PATH) && wget -O elfutils-$(ELFUTILS_VER).tar.bz2 $(ELFUTILS_URL) && tar xf elfutils-$(ELFUTILS_VER).tar.bz2
	touch .elfutils-obtained

# Compile elfutils
elfutils: download-elfutils .elfutils-done

.elfutils-done:
	cd $(ELFUTILS_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && install -m644 config/libelf.pc $(STAGING_PATH)/usr/lib/pkgconfig
	for lib in libelf debuginfod libdw; do \
		$(MAKE) -C $(SRC_PATH)/elfutils-$(ELFUTILS_VER)/$$lib DESTDIR=$(STAGING_PATH) install; \
	done
	touch .elfutils-done

# Download brotli
download-brotli: .brotli-obtained

.brotli-obtained:
	cd $(SRC_PATH) && wget -O brotli-$(BROTLI_VER).tar.gz $(BROTLI_URL) && tar xf brotli-$(BROTLI_VER).tar.gz
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
	cd $(SRC_PATH) && wget -O pcre2-$(PCRE2_VER).tar.bz2 $(PCRE2_URL) && tar xf pcre2-$(PCRE2_VER).tar.bz2
	touch .pcre2-obtained

# Compile PCRE2
pcre2: download-pcre2 .pcre2-done

.pcre2-done:
	cd $(PCRE2_PATH) && ./configure --prefix=/usr --docdir=/usr/share/doc/pcre2-$(PCRE2_VER) --enable-unicode --enable-jit --enable-pcre2-16 \
	--enable-pcre2-32 --enable-pcre2grep-libz --enable-pcre2grep-libbz2 --enable-pcre2test-libreadline --disable-static && $(MAKE) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .pcre2-done

# Download cairo
download-cairo: .cairo-obtained

.cairo-obtained:
	cd $(SRC_PATH) && wget -O cairo-$(CAIRO_VER).tar.xz $(CAIRO_URL) && tar xf cairo-$(CAIRO_VER).tar.xz
	touch .cairo-obtained

# Compile cairo
cairo: download-cairo .cairo-done

.cairo-done:
	mkdir -p $(CAIRO_PATH)/build && cd $(CAIRO_PATH)/build && meson setup --prefix=/usr --buildtype=release .. && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .cairo-done

# Download fontconfig
download-fontconfig: .fontconfig-obtained

.fontconfig-obtained:
	cd $(SRC_PATH) && wget -O fontconfig-$(FONTCONFIG_VER).tar.xz $(FONTCONFIG_URL) && tar xf fontconfig-$(FONTCONFIG_VER).tar.xz
	touch .fontconfig-obtained

# Compile fontconfig
fontconfig: download-fontconfig .fontconfig-done

.fontconfig-done:
	cd $(FONTCONFIG_PATH) && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-docs \
	--docdir=/usr/share/doc/fontconfig-$(FONTCONFIG_VER) && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .fontconfig-done

# Download expat
download-expat: .expat-obtained

.expat-obtained:
	cd $(SRC_PATH) && wget -O expat-$(EXPAT_VER).tar.gz $(EXPAT_URL) && tar xf expat-$(EXPAT_VER).tar.gz
	touch .expat-obtained

# Compile expat
expat: download-expat .expat-done

.expat-done:
	cd $(EXPAT_PATH) && ./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/expat-$(EXPAT_VER) && $(MAKE) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .expat-done

# Download graphite2
download-graphite2: .graphite2-obtained

.graphite2-obtained:
	cd $(SRC_PATH) && wget -O graphite2-$(GRAPHITE2_VER).tgz $(GRAPHITE2_URL) && tar xf graphite2-$(GRAPHITE2_VER).tgz
	touch .graphite2-obtained

# Compile graphite2
graphite2: download-graphite2 .graphite2-done

.graphite2-done:
    # Outdated build system, cool.
	mkdir -p $(GRAPHITE2_PATH)/build && cd $(GRAPHITE2_PATH)/build && sed -i '/Font.h/i #include <cstdint>' ../tests/featuremap/featuremaptest.cpp && \
	cmake -D CMAKE_POLICY_VERSION_MINIMUM=3.5 -D CMAKE_INSTALL_PREFIX=/usr .. && $(MAKE) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .graphite2-done

# Download pixman
download-pixman: .pixman-obtained

.pixman-obtained:
	cd $(SRC_PATH) && wget -O pixman-$(PIXMAN_VER).tar.gz $(PIXMAN_URL) && tar xf pixman-$(PIXMAN_VER).tar.gz
	touch .pixman-obtained

# Compile pixman
pixman: download-pixman .pixman-done

.pixman-done:
	mkdir -p $(PIXMAN_PATH)/build && cd $(PIXMAN_PATH)/build && meson setup --prefix=/usr --buildtype=release .. && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .pixman-done

# Download libpng
download-libpng: .libpng-obtained

.libpng-obtained:
	cd $(SRC_PATH) && wget -O libpng-$(LIBPNG_VER).tar.xz $(LIBPNG_URL) && tar xf libpng-$(LIBPNG_VER).tar.xz && \
	cd $(LIBPNG_PATH) && curl -s -L $(LIBPNG_PATCH_URL) | gzip -d | patch -p1
	touch .libpng-obtained

# Compile libpng
libpng: download-libpng .libpng-done

.libpng-done:
	cd $(LIBPNG_PATH) && ./configure --prefix=/usr --disable-static && $(MAKE) && $(MAKE) DESTDIR=$(STAGING_PATH) install && \
	mkdir $(STAGING_PATH)/usr/share/doc/libpng-$(LIBPNG_VER) && cp README libpng-manual.txt $(STAGING_PATH)/usr/share/doc/libpng-$(LIBPNG_VER)
	touch .libpng-done

# Download squashfs-tools
download-squashfs-tools: .squashfs-tools-obtained
.squashfs-tools-obtained:
	cd $(SRC_PATH) && wget -O squashfs-tools-$(SQUASHFS_TOOLS_VER).tar.gz $(SQUASHFS_TOOLS_URL) && tar xf squashfs-tools-$(SQUASHFS_TOOLS_VER).tar.gz
	touch .squashfs-tools-obtained

# Compile squashfs-tools
squashfs-tools: download-squashfs-tools .squashfs-tools-done
.squashfs-tools-done:
	cd $(SQUASHFS_TOOLS_PATH)/squashfs-tools && $(MAKE) -j$(THREADS) && $(MAKE) INSTALL_PREFIX=$(STAGING_PATH)/usr install
	touch .squashfs-tools-done

# Download LZO
download-lzo: .lzo-obtained
.lzo-obtained:
	cd $(SRC_PATH) && wget -O lzo-$(LZO_VER).tar.gz $(LZO_URL) && tar xf lzo-$(LZO_VER).tar.gz
	touch .lzo-obtained

# Compile LZO
lzo: download-lzo .lzo-done
.lzo-done:
	cd $(LZO_PATH) && ./configure --prefix=/usr --enable-shared --disable-static --docdir=/usr/share/doc/lzo-$(LZO_VER) && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .lzo-done

# Download efibootmgr
download-efibootmgr: .efibootmgr-obtained
.efibootmgr-obtained:
	cd $(SRC_PATH) && wget -O efibootmgr-$(EFIBOOTMGR_VER).tar.gz $(EFIBOOTMGR_URL) && tar xf efibootmgr-$(EFIBOOTMGR_VER).tar.gz
	touch .efibootmgr-obtained

# Compile efibootmgr
efibootmgr: download-efibootmgr .efibootmgr-done
.efibootmgr-done:
	cd $(EFIBOOTMGR_PATH) && $(MAKE) -j$(THREADS) EFIDIR=arkana EFI_LOADER=grubx64.efi && $(MAKE) install EFIDIR=arkana DESTDIR=$(STAGING_PATH)
	touch .efibootmgr-done

# Download efivar
download-efivar: .efivar-obtained
.efivar-obtained:
	cd $(SRC_PATH) && wget -O efivar-$(EFIVAR_VER).tar.gz $(EFIVAR_URL) && tar xf efivar-$(EFIVAR_VER).tar.gz
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
	$(MAKE) -C $(LINUX_PATH) INSTALL_MOD_PATH=$(CPIO_STAGING_PATH) modules_install
	cd $(CPIO_STAGING_PATH) && find . | cpio -oH newc | gzip > $(ISO_STAGING_PATH)/boot/initramfs.img

.PHONY: boot-initramfs
boot-initramfs:
	cp bootinit $(CPIO_STAGING_PATH)/init
	cd $(CPIO_STAGING_PATH) && find . | cpio -oH newc | gzip > $(STAGING_PATH)/boot/initramfs.img

# Create ISO file for booting
.PHONY: iso
iso:
	cp -a arkana-install $(STAGING_PATH)/usr/bin/arkana-install
	cp -a genfstab $(STAGING_PATH)/usr/bin/genfstab
    
	ln -sf /usr/bin/bzdiff $(STAGING_PATH)/usr/bin/bzcmp
	ln -sf /usr/bin/bzgrep $(STAGING_PATH)/usr/bin/bzegrep
	ln -sf /usr/bin/bzgrep $(STAGING_PATH)/usr/bin/bzfgrep
	ln -sf /usr/bin/bzmore $(STAGING_PATH)/usr/bin/bzless
	ln -sf /usr/lib/p11-kit/trust-extract-compat $(STAGING_PATH)/usr/bin/update-ca-certificates

	chroot $(STAGING_PATH) fc-cache -fv || true
	rm -f $(STAGING_PATH)/etc/ld.so.cache || true
	ln -sf /dev/null $(STAGING_PATH)/etc/ld.so.cache || true
	ldconfig || true

	find $(STAGING_PATH) \( -name "*.a" -o -name "*.la" \) -delete
	mksquashfs $(STAGING_PATH) $(ISO_STAGING_PATH)/boot/rootfs.sfs -comp zstd -Xcompression-level 15 -b 1M -noappend || true
	cp $(LINUX_PATH)/arch/x86/boot/bzImage $(ISO_STAGING_PATH)/boot/vmlinuz

	echo 'set timeout=5' > $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo 'set default=0' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo 'menuentry "arkanaOS" {' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo '    linux /boot/vmlinuz' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo '    initrd /boot/initramfs.img' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo '}' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg

	grub-mkrescue -o $(OUTPUT_PATH)/arkana.iso $(ISO_STAGING_PATH) -- -volid "ARKANA"
