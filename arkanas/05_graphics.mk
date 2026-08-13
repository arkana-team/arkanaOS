# Enable multi-threaded Bash operation
SHELL = bash
THREADS = $(shell nproc)
.NOTPARALLEL:

# Paths used to build the ISO components
SRC_PATH = $(shell realpath ./src)
STAGING_PATH = $(shell realpath ./staging)
CPIO_STAGING_PATH = $(shell realpath ./cpio-staging)
ISO_STAGING_PATH = $(shell realpath ./iso-staging)
OUTPUT_PATH = $(shell realpath ./output)

# Xorg Server
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/xorg-server.html
XORG_SERVER_URL = https://www.x.org/pub/individual/xserver/xorg-server-21.1.18.tar.xz
XORG_SERVER_VER = 21.1.18
XORG_SERVER_PATH = $(SRC_PATH)/xorg-server-$(XORG_SERVER_VER)

# Libbsd
# URL: https://libbsd.freedesktop.org/releases/ (w/o instructions)
LIBBSD_URL = https://libbsd.freedesktop.org/releases/libbsd-0.12.2.tar.xz
LIBBSD_VER = 0.12.2
LIBBSD_PATH = $(SRC_PATH)/libbsd-$(LIBBSD_VER)

# Libmd
# URL: https://libbsd.freedesktop.org/releases/ (at the same page)
LIBMD_URL = https://libbsd.freedesktop.org/releases/libmd-1.1.0.tar.xz
LIBMD_VER = 1.1.0
LIBMD_PATH = $(SRC_PATH)/libmd-$(LIBMD_VER)

# Libdrm
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/libdrm.html
LIBDRM_URL = https://dri.freedesktop.org/libdrm/libdrm-2.4.125.tar.xz
LIBDRM_VER = 2.4.125
LIBDRM_PATH = $(SRC_PATH)/libdrm-$(LIBDRM_VER)

# Mesa
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/mesa.html
MESA_URL = https://mesa.freedesktop.org/archive/mesa-25.3.1.tar.xz
MESA_VER = 25.3.1
MESA_PATH = $(SRC_PATH)/mesa-$(MESA_VER)

# Lm-sensors
# URL: https://github.com/lm-sensors/lm-sensors (w/o instructions)
LM_SENSORS_URL = https://github.com/lm-sensors/lm-sensors/archive/V3-6-0/lm-sensors-3-6-0.tar.gz
LM_SENSORS_VER = 3-6-0
LM_SENSORS_PATH = $(SRC_PATH)/lm-sensors-$(LM_SENSORS_VER)

# LLVM (libraries only)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/llvm.html
LLVM_URL = https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.8/llvm-project-21.1.8.src.tar.xz
LLVM_VER = 21.1.8
LLVM_PATH = $(SRC_PATH)/llvm-project-$(LLVM_VER).src/llvm

# Libedit
# URL: https://www.thrysoee.dk/editline/ (w/o instructions)
LIBEDIT_URL = https://www.thrysoee.dk/editline/libedit-20250104-3.1.tar.gz
LIBEDIT_VER = 20250104-3.1
LIBEDIT_PATH = $(SRC_PATH)/libedit-$(LIBEDIT_VER)

# SPIRV-Tools
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/spirv-tools.html
SPIRV_TOOLS_URL = https://github.com/KhronosGroup/SPIRV-Tools/archive/vulkan-sdk-1.4.321.0/SPIRV-Tools-vulkan-sdk-1.4.321.0.tar.gz
SPIRV_HEADERS_URL = https://github.com/KhronosGroup/SPIRV-Headers/archive/vulkan-sdk-1.4.321.0/SPIRV-Headers-vulkan-sdk-1.4.321.0.tar.gz
SPIRV_TOOLS_VER = 1.4.321.0
SPIRV_TOOLS_PATH = $(SRC_PATH)/SPIRV-Tools-vulkan-sdk-$(SPIRV_TOOLS_VER)

# Xinit
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/xinit.html
XORG_XINIT_URL = https://www.x.org/pub/individual/app/xinit-1.4.4.tar.xz
XORG_XINIT_VER = 1.4.4
XORG_XINIT_PATH = $(SRC_PATH)/xinit-$(XORG_XINIT_VER)

# XKeyboardConfig 
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/xkeyboard-config.html
XORG_XKEYBOARD_CONFIG_URL = https://www.x.org/pub/individual/data/xkeyboard-config/xkeyboard-config-2.45.tar.xz
XORG_XKEYBOARD_CONFIG_VER = 2.45
XORG_XKEYBOARD_CONFIG_PATH = $(SRC_PATH)/xkeyboard-config-$(XORG_XKEYBOARD_CONFIG_VER)

# Xorg Input Drivers
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/x7driver.html
XF86_INPUT_EVDEV_URL = https://www.x.org/pub/individual/driver/xf86-input-evdev-2.11.0.tar.xz
XF86_INPUT_EVDEV_VER = 2.11.0
XF86_INPUT_EVDEV_PATH = $(SRC_PATH)/xf86-input-evdev-$(XF86_INPUT_EVDEV_VER)

# Openbox
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/openbox.html
OPENBOX_URL = http://openbox.org/dist/openbox/openbox-3.6.1.tar.gz
OPENBOX_VER = 3.6.1
OPENBOX_PATH = $(SRC_PATH)/openbox-$(OPENBOX_VER)

# Fribidi
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/fribidi.html
FRIBIDI_URL = https://github.com/fribidi/fribidi/releases/download/v1.0.16/fribidi-1.0.16.tar.xz
FRIBIDI_VER = 1.0.16
FRIBIDI_PATH = $(SRC_PATH)/fribidi-$(FRIBIDI_VER)

# Xterm
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/xterm.html
XTERM_URL = https://invisible-mirror.net/archives/xterm/xterm-401.tgz
XTERM_VER = 401
XTERM_PATH = $(SRC_PATH)/xterm-$(XTERM_VER)

# Luit
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/luit.html
LUIT_URL = https://invisible-mirror.net/archives/luit/luit-20240910.tgz
LUIT_VER = 20240910
LUIT_PATH = $(SRC_PATH)/luit-$(LUIT_VER)

# Libinput
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/x7driver.html
LIBINPUT_URL = https://gitlab.freedesktop.org/libinput/libinput/-/archive/1.29.0/libinput-1.29.0.tar.gz
LIBINPUT_VER = 1.29.0
LIBINPUT_PATH = $(SRC_PATH)/libinput-$(LIBINPUT_VER)

# Libevdev
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/x7driver.html (at the same page)
LIBEVDEV_URL = https://www.freedesktop.org/software/libevdev/libevdev-1.13.4.tar.xz
LIBEVDEV_VER = 1.13.4
LIBEVDEV_PATH = $(SRC_PATH)/libevdev-$(LIBEVDEV_VER)

# Mtdev
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/mtdev.html
MTDEV_URL = https://bitmath.org/code/mtdev/mtdev-1.1.7.tar.bz2
MTDEV_VER = 1.1.7
MTDEV_PATH = $(SRC_PATH)/mtdev-$(MTDEV_VER)

# Libwacom
# URL: https://github.com/linuxwacom/libwacom
LIBWACOM_URL = https://github.com/linuxwacom/libwacom/releases/download/libwacom-2.19.0/libwacom-2.19.0.tar.xz
LIBWACOM_VER = 2.19.0
LIBWACOM_PATH = $(SRC_PATH)/libwacom-$(LIBWACOM_VER)

# Libgudev
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libgudev.html
LIBGUDEV_URL = https://download.gnome.org/sources/libgudev/238/libgudev-238.tar.xz
LIBGUDEV_VER = 238
LIBGUDEV_PATH = $(SRC_PATH)/libgudev-$(LIBGUDEV_VER)

# Feh
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/xsoft/feh.html
FEH_URL = https://feh.finalrewind.org/feh-3.10.3.tar.bz2
FEH_VER = 3.10.3
FEH_PATH = $(SRC_PATH)/feh-$(FEH_VER)

# Imlib2
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/imlib2.html
IMLIB2_URL = https://downloads.sourceforge.net/enlightenment/imlib2-1.12.5.tar.xz
IMLIB2_VER = 1.12.5
IMLIB2_PATH = $(SRC_PATH)/imlib2-$(IMLIB2_VER)

# Pango
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/pango.html
PANGO_URL = https://download.gnome.org/sources/pango/1.52/pango-1.52.2.tar.xz
PANGO_VER = 1.52.2
PANGO_PATH = $(SRC_PATH)/pango-$(PANGO_VER)

# Libthai
# URL: https://linux.thai.net/pub/thailinux/software/libthai/ (w/o instructions)
LIBTHAI_URL = https://linux.thai.net/pub/thailinux/software/libthai/libthai-0.1.29.tar.xz
LIBTHAI_VER = 0.1.29
LIBTHAI_PATH = $(SRC_PATH)/libthai-$(LIBTHAI_VER)

# Libdatrie
# URL: https://linux.thai.net/pub/thailinux/software/libthai/ (at the same page)
LIBDATRIE_URL = https://linux.thai.net/pub/thailinux/software/libthai/libdatrie-0.2.13.tar.xz
LIBDATRIE_VER = 0.2.13
LIBDATRIE_PATH = $(SRC_PATH)/libdatrie-$(LIBDATRIE_VER)

# Librsvg
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/librsvg.html
LIBRSVG_URL = https://download.gnome.org/sources/librsvg/2.61/librsvg-2.61.0.tar.xz
LIBRSVG_VER = 2.61.0
LIBRSVG_PATH = $(SRC_PATH)/librsvg-$(LIBRSVG_VER)

# Libdav1d
LIBDAV1D_URL = https://sources.buildroot.net/dav1d/dav1d-1.5.1.tar.xz
LIBDAV1D_VER = 1.5.1
LIBDAV1D_PATH = $(SRC_PATH)/dav1d-$(LIBDAV1D_VER)

# Cairo
CAIRO_URL = https://www.cairographics.org/releases/cairo-1.18.2.tar.xz
CAIRO_VER = 1.18.2
CAIRO_PATH = $(SRC_PATH)/cairo-$(CAIRO_VER)

# GDK-Pixbuf
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/x/gdk-pixbuf.html
GDK_PIXBUF_URL = https://download.gnome.org/sources/gdk-pixbuf/2.42/gdk-pixbuf-2.42.12.tar.xz
GDK_PIXBUF_VER = 2.42.12
GDK_PIXBUF_PATH = $(SRC_PATH)/gdk-pixbuf-$(GDK_PIXBUF_VER)

# Libjpeg-turbo
# URL: https://www.linuxfromscratch.org/blfs/view/svn/general/libjpeg.html
LIBJPEG_TURBO_URL = https://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-3.0.1.tar.gz
LIBJPEG_TURBO_VER = 3.0.1
LIBJPEG_TURBO_PATH = $(SRC_PATH)/libjpeg-turbo-$(LIBJPEG_TURBO_VER)

X11_LIBS = X11 Xau xcvt Xdmcp Xext Xfont2 xshmfence xcb fontenc Xxf86vm pciaccess Xmu xkbfile Xrender Xft Xinerama Xrandr Xaw Xpm Xt ICE SM Xcursor Xfixes Xi Xcomposite Xtst
X11_LIB_VERS = 1.8.12 1.0.12 0.1.3 1.1.5 1.3.6 2.0.7 1.3.3 1.17.0 1.1.8 1.1.6 0.18.1 1.2.1 1.1.3 0.9.12 2.3.9 1.1.5 1.5.4 1.0.16 3.5.17 1.3.1 1.1.2 1.2.6 1.2.3 6.0.1 1.8.1 0.4.6 1.2.4

X11_PARSED_LIBS := $(foreach i, $(shell seq 1 $(words $(X11_LIBS))), \
  $(word $(i), $(X11_LIBS))/$(word $(i), $(X11_LIB_VERS)))

X11_APPS = xauth xkbcomp xsetroot xrandr
X11_APP_VERS = 1.1.4 1.4.7 1.1.3 1.5.2

X11_PARSED_APPS := $(foreach i, $(shell seq 1 $(words $(X11_APPS))), \
  $(word $(i), $(X11_APPS))/$(word $(i), $(X11_APP_VERS)))

X11_FONTS = font-util encodings font-alias font-adobe-utopia-type1 font-bh-ttf font-bh-type1 font-ibm-type1 font-misc-ethiopic font-xfree86-type1 font-cursor-misc
X11_FONT_VERS = 1.4.1 1.1.0 1.0.5 1.0.5 1.0.4 1.0.4 1.0.4 1.0.5 1.0.5 1.0.4

X11_PARSED_FONTS := $(foreach i, $(shell seq 1 $(words $(X11_FONTS))), \
  $(word $(i), $(X11_FONTS))/$(word $(i), $(X11_FONT_VERS)))

# Targets
all: xorgproto xtrans pixman freetype font-util fontconfig xbitmaps xorg-libs libdrm mesa xorg-server libbsd libmd lm-sensors llvm libedit spirv-tools xinit xorg-apps xorg-fonts xorg-xkeyboard-config xf86-input-evdev openbox fribidi xterm luit libevdev mtdev libgudev libwacom libinput feh imlib2 libdatrie libthai cairo pango libdav1d gdk-pixbuf librsvg libjpeg-turbo wmaker

XORGPROTO_URL = https://www.x.org/pub/individual/proto/xorgproto-2024.1.tar.xz
XORGPROTO_VER = 2024.1
XORGPROTO_PATH = $(SRC_PATH)/xorgproto-$(XORGPROTO_VER)

download-xorgproto: .xorgproto-obtained
.xorgproto-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O xorgproto-$(XORGPROTO_VER).tar.xz $(XORGPROTO_URL) && tar xf xorgproto-$(XORGPROTO_VER).tar.xz
	touch .xorgproto-obtained

xorgproto: download-xorgproto .xorgproto-done
.xorgproto-done:
	mkdir -p $(XORGPROTO_PATH)/build && cd $(XORGPROTO_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .xorgproto-done

XTRANS_URL = https://www.x.org/pub/individual/lib/xtrans-1.5.1.tar.xz
XTRANS_VER = 1.5.1
XTRANS_PATH = $(SRC_PATH)/xtrans-$(XTRANS_VER)

download-xtrans: .xtrans-obtained
.xtrans-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O xtrans-$(XTRANS_VER).tar.xz $(XTRANS_URL) && tar xf xtrans-$(XTRANS_VER).tar.xz
	touch .xtrans-obtained

xtrans: download-xtrans .xtrans-done
.xtrans-done:
	cd $(XTRANS_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .xtrans-done

PIXMAN_URL = https://www.cairographics.org/releases/pixman-0.46.4.tar.gz
PIXMAN_VER = 0.46.4
PIXMAN_PATH = $(SRC_PATH)/pixman-$(PIXMAN_VER)

download-pixman: .pixman-obtained
.pixman-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O pixman-$(PIXMAN_VER).tar.gz $(PIXMAN_URL) && tar xf pixman-$(PIXMAN_VER).tar.gz
	touch .pixman-obtained

pixman: download-pixman .pixman-done
.pixman-done:
	mkdir -p $(PIXMAN_PATH)/build && cd $(PIXMAN_PATH)/build && meson setup --prefix=/usr --native-file $(SRC_PATH)/cross_file.txt --buildtype=release .. && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .pixman-done

FREETYPE_URL = https://downloads.sourceforge.net/freetype/freetype-2.13.3.tar.xz
FREETYPE_VER = 2.13.3
FREETYPE_PATH = $(SRC_PATH)/freetype-$(FREETYPE_VER)

download-freetype: .freetype-obtained
.freetype-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O freetype-$(FREETYPE_VER).tar.xz $(FREETYPE_URL) && tar xf freetype-$(FREETYPE_VER).tar.xz
	touch .freetype-obtained

freetype: download-freetype .freetype-done
.freetype-done:
	cd $(FREETYPE_PATH) && sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg && \
	sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" -i include/freetype/config/ftoption.h && \
	CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr --enable-freetype-config --disable-static --without-harfbuzz --without-png --without-brotli --without-zlib && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .freetype-done
FONTCONFIG_URL = https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/fontconfig/2.17.1/fontconfig-2.17.1.tar.xz
FONTCONFIG_VER = 2.17.1
FONTCONFIG_PATH = $(SRC_PATH)/fontconfig-$(FONTCONFIG_VER)
download-fontconfig: .fontconfig-obtained
.fontconfig-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O fontconfig-$(FONTCONFIG_VER).tar.xz $(FONTCONFIG_URL) && tar xf fontconfig-$(FONTCONFIG_VER).tar.xz
	touch .fontconfig-obtained
fontconfig: download-fontconfig .fontconfig-done
.fontconfig-done:
	cd $(FONTCONFIG_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-docs --docdir=/usr/share/doc/fontconfig-$(FONTCONFIG_VER) && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .fontconfig-done
XBITMAPS_URL = https://www.x.org/pub/individual/data/xbitmaps-1.1.3.tar.gz
XBITMAPS_VER = 1.1.3
XBITMAPS_PATH = $(SRC_PATH)/xbitmaps-$(XBITMAPS_VER)
download-xbitmaps: .xbitmaps-obtained
.xbitmaps-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O xbitmaps-$(XBITMAPS_VER).tar.gz $(XBITMAPS_URL) && tar xf xbitmaps-$(XBITMAPS_VER).tar.gz
	touch .xbitmaps-obtained
xbitmaps: download-xbitmaps .xbitmaps-done
.xbitmaps-done:
	cd $(XBITMAPS_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && mkdir -p $(STAGING_PATH)/usr/lib/pkgconfig && cp -a $(STAGING_PATH)/usr/share/pkgconfig/xbitmaps.pc $(STAGING_PATH)/usr/lib/pkgconfig/
	touch .xbitmaps-done
FONT_UTIL_URL = https://gitlab.freedesktop.org/xorg/font/util/-/archive/XORG-STABLE/util-XORG-STABLE.tar.gz
FONT_UTIL_VER = XORG-STABLE
FONT_UTIL_PATH = $(SRC_PATH)/util-XORG-STABLE

download-font-util: .font-util-obtained
.font-util-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O util-$(FONT_UTIL_VER).tar.gz $(FONT_UTIL_URL) && tar xf util-$(FONT_UTIL_VER).tar.gz
	touch .font-util-obtained

font-util: .font-util-done
.font-util-done:
	mkdir -p $(STAGING_PATH)/usr/lib/pkgconfig
	echo 'prefix=/usr' > $(STAGING_PATH)/usr/lib/pkgconfig/fontutil.pc
	echo 'exec_prefix=$${prefix}' >> $(STAGING_PATH)/usr/lib/pkgconfig/fontutil.pc
	echo 'libdir=$${exec_prefix}/lib' >> $(STAGING_PATH)/usr/lib/pkgconfig/fontutil.pc
	echo 'datarootdir=$${prefix}/share' >> $(STAGING_PATH)/usr/lib/pkgconfig/fontutil.pc
	echo 'fontrootdir=$${datarootdir}/fonts' >> $(STAGING_PATH)/usr/lib/pkgconfig/fontutil.pc
	echo '' >> $(STAGING_PATH)/usr/lib/pkgconfig/fontutil.pc
	echo 'Name: font-util' >> $(STAGING_PATH)/usr/lib/pkgconfig/fontutil.pc
	echo 'Description: X.Org font utilities' >> $(STAGING_PATH)/usr/lib/pkgconfig/fontutil.pc
	echo 'Version: 1.4.2' >> $(STAGING_PATH)/usr/lib/pkgconfig/fontutil.pc
	touch .font-util-done

# Download Xorg server
download-xorg-server: .xorg-server-obtained
.xorg-server-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O xorg-server-$(XORG_SERVER_VER).tar.xz $(XORG_SERVER_URL) && tar xf xorg-server-$(XORG_SERVER_VER).tar.xz
	touch .xorg-server-obtained
# Libepoxy
LIBEPOXY_URL = https://download.gnome.org/sources/libepoxy/1.5/libepoxy-1.5.10.tar.xz
LIBEPOXY_VER = 1.5.10
LIBEPOXY_PATH = $(SRC_PATH)/libepoxy-$(LIBEPOXY_VER)

download-libepoxy: .libepoxy-obtained
.libepoxy-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libepoxy-$(LIBEPOXY_VER).tar.xz $(LIBEPOXY_URL) && tar xf libepoxy-$(LIBEPOXY_VER).tar.xz
	touch .libepoxy-obtained

libepoxy: download-libepoxy .libepoxy-done
.libepoxy-done:
	cd $(LIBEPOXY_PATH) && mkdir -p build && cd build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .libepoxy-done

# Compile Xorg server
xorg-server: download-xorg-server libepoxy mesa .xorg-server-done
.xorg-server-done:
	mkdir -p $(XORG_SERVER_PATH)/build && cd $(XORG_SERVER_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --localstatedir=/var -D glamor=true -D \
	xkb_output_dir=/var/lib/xkb && ninja && DESTDIR=$(STAGING_PATH) ninja install && mkdir -p $(STAGING_PATH)/etc/X11/xorg.conf.d
	touch .xorg-server-done

# Download Xorg libraries
download-xorg-libs: .xorg-libs-obtained
.xorg-libs-obtained:
	for pair in $(X11_PARSED_LIBS); do \
	  lib=$${pair%%/*}; \
	  ver=$${pair##*/}; \
	  cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O "lib$$lib-$$ver.tar.xz" "https://www.x.org/pub/individual/lib/lib$$lib-$$ver.tar.xz" && \
	  tar xf "lib$$lib-$$ver.tar.xz" || exit 1; \
	done
	touch .xorg-libs-obtained

# Compile Xorg libraries
xorg-libs: download-xorg-libs fontconfig .xorg-libs-done
.xorg-libs-done:
	for pair in $(X11_PARSED_LIBS); do \
	  lib=$${pair%%/*}; \
	  ver=$${pair##*/}; \
	  if [ -f $(SRC_PATH)/lib$$lib-$$ver/meson.build ]; then \
	    LIBDIR=$(SRC_PATH)/lib$$lib-$$ver; [ -d "$$LIBDIR" ] || LIBDIR=$(SRC_PATH)/$$lib-$$ver; mkdir -p "$$LIBDIR/build" && cd "$$LIBDIR/build" && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release && \
	    ninja && DESTDIR=$(STAGING_PATH) ninja install || exit 1; \
	  else \
	    LIBDIR=$(SRC_PATH)/lib$$lib-$$ver; [ -d "$$LIBDIR" ] || LIBDIR=$(SRC_PATH)/$$lib-$$ver; cd "$$LIBDIR" && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install || exit 1; \
	  fi; \
	done
	touch .xorg-libs-done

# Download Xorg applications
download-xorg-apps: .xorg-apps-obtained
.xorg-apps-obtained:
	for pair in $(X11_PARSED_APPS); do \
	  app=$${pair%%/*}; \
	  ver=$${pair##*/}; \
	  cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O "$$app-$$ver.tar.xz" "http://xorg.freedesktop.org/releases/individual/app/$$app-$$ver.tar.xz" && \
	  tar xf "$$app-$$ver.tar.xz" || exit 1; \
	done
	touch .xorg-apps-obtained

# Compile Xorg applications
xorg-apps: download-xorg-apps xbitmaps .xorg-apps-done
.xorg-apps-done:
	for pair in $(X11_PARSED_APPS); do \
	  app=$${pair%%/*}; \
	  ver=$${pair##*/}; \
	  cd $(SRC_PATH)/$$app-$$ver/ && PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" CFLAGS="-O2 -std=gnu17 -I$(STAGING_PATH)/usr/include" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install || exit 1; \
	done
	touch .xorg-apps-done

# Download Xorg fonts
download-xorg-fonts: .xorg-fonts-obtained
.xorg-fonts-obtained:
	for pair in $(X11_PARSED_FONTS); do \
	  font=$${pair%%/*}; \
	  ver=$${pair##*/}; \
	  cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O "$$font-$$ver.tar.xz" "http://xorg.freedesktop.org/releases/individual/font/$$font-$$ver.tar.xz" && \
	  tar xf "$$font-$$ver.tar.xz" || exit 1; \
	done
	touch .xorg-fonts-obtained

# Compile Xorg fonts
xorg-fonts: download-xorg-fonts xorg-apps .xorg-fonts-done
.xorg-fonts-done:
	mkdir -p $(STAGING_PATH)/usr/bin
	if ! [ -x $(STAGING_PATH)/usr/bin/bdftopcf ]; then \
	  printf '#!/bin/sh\nexit 0\n' > $(STAGING_PATH)/usr/bin/bdftopcf && chmod +x $(STAGING_PATH)/usr/bin/bdftopcf; \
	fi
	for pair in $(X11_PARSED_FONTS); do \
	  font=$${pair%%/*}; \
	  ver=$${pair##*/}; \
	  cd $(SRC_PATH)/$$font-$$ver/ && PATH="$(STAGING_PATH)/usr/bin:$$PATH" BDFTOPCF="$(STAGING_PATH)/usr/bin/bdftopcf" CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install || exit 1; \
	done
	touch .xorg-fonts-done

# Download libbsd
download-libbsd: .libbsd-obtained
.libbsd-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libbsd-$(LIBBSD_VER).tar.xz $(LIBBSD_URL) && tar xf libbsd-$(LIBBSD_VER).tar.xz
	touch .libbsd-obtained

# Compile libbsd
libbsd: download-libbsd .libbsd-done
.libbsd-done:
	cd $(LIBBSD_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libbsd-done

# Download libmd
download-libmd: .libmd-obtained
.libmd-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libmd-$(LIBMD_VER).tar.xz $(LIBMD_URL) && tar xf libmd-$(LIBMD_VER).tar.xz
	touch .libmd-obtained

# Compile libmd
libmd: download-libmd .libmd-done
.libmd-done:
	cd $(LIBMD_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libmd-done

# Download libdrm
download-libdrm: .libdrm-obtained
.libdrm-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libdrm-$(LIBDRM_VER).tar.xz $(LIBDRM_URL) && tar xf libdrm-$(LIBDRM_VER).tar.xz
	touch .libdrm-obtained

# Compile libdrm
libdrm: download-libdrm .libdrm-done
.libdrm-done:
	mkdir -p $(LIBDRM_PATH)/build && cd $(LIBDRM_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release -D udev=true -D valgrind=disabled .. && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .libdrm-done

# Download Mesa
download-mesa: .mesa-obtained
.mesa-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O mesa-$(MESA_VER).tar.xz $(MESA_URL) && tar xf mesa-$(MESA_VER).tar.xz
	touch .mesa-obtained

# Compile Mesa
mesa: download-mesa .mesa-done
.mesa-done:
	cd $(MESA_PATH) && \
	sed -i '/#include <clang\/Config\/config.h>/i #undef UNUSED' src/compiler/clc/clc_helpers.cpp && \
	sed -i '/#include "clc_helpers.h"/a #undef UNUSED\n#define UNUSED __attribute__((unused))' src/compiler/clc/clc_helpers.cpp && \
	mkdir -p build && cd build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release -D platforms=x11 -D gallium-drivers=softpipe,virgl,nouveau,radeonsi \
	-D valgrind=disabled -D video-codecs=all -D libunwind=disabled -D glvnd=disabled -D llvm=disabled -D werror=false -D vulkan-drivers="" && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .mesa-done

# Download lm-sensors
download-lm-sensors: .lm-sensors-obtained
.lm-sensors-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O lm-sensors-$(LM_SENSORS_VER).tar.gz $(LM_SENSORS_URL) && tar xf lm-sensors-$(LM_SENSORS_VER).tar.gz
	touch .lm-sensors-obtained

# Compile lm-sensors
lm-sensors: download-lm-sensors .lm-sensors-done
.lm-sensors-done:
	cd $(LM_SENSORS_PATH) && $(MAKE) -j$(THREADS) DESTDIR=$(STAGING_PATH) PREFIX=/usr MANDIR=/usr/share/man install
	touch .lm-sensors-done

# Download LLVM
download-llvm: .llvm-obtained
.llvm-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O llvm-$(LLVM_VER).tar.xz $(LLVM_URL) && tar xf llvm-$(LLVM_VER).tar.xz
	touch .llvm-obtained

# Compile LLVM
llvm: download-llvm .llvm-done
.llvm-done:
	mkdir -p $(LLVM_PATH)/build && cd $(LLVM_PATH)/build && cmake -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_SKIP_INSTALL_RPATH=ON -D CMAKE_ASM_COMPILER=/usr/bin/gcc \
	-D LLVM_ENABLE_FFI=ON -D CMAKE_BUILD_TYPE=Release -D LLVM_BUILD_LLVM_DYLIB=ON -D LLVM_LINK_LLVM_DYLIB=ON -D LLVM_ENABLE_RTTI=ON \
	-D LLVM_TARGETS_TO_BUILD="host;AMDGPU" -D LLVM_BINUTILS_INCDIR=/usr/include -D LLVM_INCLUDE_BENCHMARKS=OFF -D CLANG_DEFAULT_PIE_ON_LINUX=ON \
	-D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang -W no-dev -G Ninja .. && ninja LLVM && cp lib/libLLVM.so $(STAGING_PATH)/usr/lib/libLLVM.so && \
	ln -sf libLLVM.so $(STAGING_PATH)/usr/lib/libLLVM.so.21.1
	touch .llvm-done

# Download libedit
download-libedit: .libedit-obtained
.libedit-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libedit-$(LIBEDIT_VER).tar.gz $(LIBEDIT_URL) && tar xf libedit-$(LIBEDIT_VER).tar.gz
	touch .libedit-obtained

# Compile libedit
libedit: download-libedit .libedit-done
.libedit-done:
	cd $(LIBEDIT_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libedit-done

# Download SPIRV-Tools
download-spirv-tools: .spirv-tools-obtained
.spirv-tools-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O spirv-tools-$(SPIRV_TOOLS_VER).tar.gz $(SPIRV_TOOLS_URL) && tar xf spirv-tools-$(SPIRV_TOOLS_VER).tar.gz
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O spirv-headers-$(SPIRV_TOOLS_VER).tar.gz $(SPIRV_HEADERS_URL) && tar xf spirv-headers-$(SPIRV_TOOLS_VER).tar.gz
	cp -a $(SRC_PATH)/SPIRV-Headers-vulkan-sdk-$(SPIRV_TOOLS_VER) $(SPIRV_TOOLS_PATH)/external/spirv-headers
	touch .spirv-tools-obtained

# Compile SPIRV-Tools
spirv-tools: download-spirv-tools .spirv-tools-done
.spirv-tools-done:
	mkdir -p $(SPIRV_TOOLS_PATH)/build && cd $(SPIRV_TOOLS_PATH)/build && cmake -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D SPIRV_WERROR=OFF \
	-D BUILD_SHARED_LIBS=ON -G Ninja .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	ln -sf /usr/lib/libSPIRV-Tools-shared.so $(STAGING_PATH)/usr/lib/libSPIRV-Tools.so
	touch .spirv-tools-done

# Download xinit
download-xinit: .xinit-obtained
.xinit-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O xinit-$(XORG_XINIT_VER).tar.xz $(XORG_XINIT_URL) && tar xf xinit-$(XORG_XINIT_VER).tar.xz
	touch .xinit-obtained

# Compile xinit
xinit: download-xinit .xinit-done
.xinit-done:
	cd $(XORG_XINIT_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr --with-xinitdir=/etc/X11/app-defaults && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .xinit-done

# Download xorg-xkeyboard-config
download-xorg-xkeyboard-config: .xorg-xkeyboard-config-obtained
.xorg-xkeyboard-config-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O xkeyboard-config-$(XORG_XKEYBOARD_CONFIG_VER).tar.xz $(XORG_XKEYBOARD_CONFIG_URL) && tar xf xkeyboard-config-$(XORG_XKEYBOARD_CONFIG_VER).tar.xz
	touch .xorg-xkeyboard-config-obtained

# Compile xorg-xkeyboard-config
xorg-xkeyboard-config: download-xorg-xkeyboard-config .xorg-xkeyboard-config-done
.xorg-xkeyboard-config-done:
	mkdir -p $(XORG_XKEYBOARD_CONFIG_PATH)/build && cd $(XORG_XKEYBOARD_CONFIG_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .xorg-xkeyboard-config-done

# Download xf86-input-evdev
download-xf86-input-evdev: .xf86-input-evdev-obtained
.xf86-input-evdev-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O xf86-input-evdev-$(XF86_INPUT_EVDEV_VER).tar.xz $(XF86_INPUT_EVDEV_URL) && tar xf xf86-input-evdev-$(XF86_INPUT_EVDEV_VER).tar.xz
	touch .xf86-input-evdev-obtained

# Compile xf86-input-evdev
xf86-input-evdev: download-xf86-input-evdev .xf86-input-evdev-done
.xf86-input-evdev-done:
	cd $(XF86_INPUT_EVDEV_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .xf86-input-evdev-done

# Download openbox
download-openbox: .openbox-obtained
.openbox-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O openbox-$(OPENBOX_VER).tar.gz $(OPENBOX_URL) && tar xf openbox-$(OPENBOX_VER).tar.gz
	touch .openbox-obtained

# Compile openbox
openbox: download-openbox .openbox-done
.openbox-done:
	cd $(OPENBOX_PATH) && autoreconf -fi && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/openbox-$(OPENBOX_VER) && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	cp -a xinitrc $(STAGING_PATH)/root/.xinitrc
	touch .openbox-done

# Download fribidi
download-fribidi: .fribidi-obtained
.fribidi-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O fribidi-$(FRIBIDI_VER).tar.xz $(FRIBIDI_URL) && tar xf fribidi-$(FRIBIDI_VER).tar.xz
	touch .fribidi-obtained

# Compile fribidi
fribidi: download-fribidi .fribidi-done
.fribidi-done:
	mkdir -p $(FRIBIDI_PATH)/build && cd $(FRIBIDI_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release -Dc_args="-Wno-error" .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .fribidi-done

# Download xterm
download-xterm: .xterm-obtained
.xterm-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O xterm-$(XTERM_VER).tar.xz $(XTERM_URL) && tar xf xterm-$(XTERM_VER).tar.xz
	touch .xterm-obtained

# Compile xterm
xterm: download-xterm .xterm-done
.xterm-done:
	cd $(XTERM_PATH) && sed -i '/v0/{n;s/new:/new:kb=^?:/}' termcap && printf '\tkbs=\\177,\n' >> terminfo && CFLAGS="-O2 -std=gnu17" TERMINFO=/usr/share/terminfo ./configure --prefix=/usr --with-app-defaults=/etc/X11/app-defaults && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install && mkdir -p $(STAGING_PATH)/usr/share/applications && cp *.desktop $(STAGING_PATH)/usr/share/applications/
	touch .xterm-done

# Download luit
download-luit: .luit-obtained
.luit-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O luit-$(LUIT_VER).tar.xz $(LUIT_URL) && tar xf luit-$(LUIT_VER).tar.xz
	touch .luit-obtained

# Compile luit
luit: download-luit .luit-done
.luit-done:
	cd $(LUIT_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .luit-done

# Download libinput
download-libinput: .libinput-obtained
.libinput-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libinput-$(LIBINPUT_VER).tar.gz $(LIBINPUT_URL) && tar xf libinput-$(LIBINPUT_VER).tar.gz
	touch .libinput-obtained

# Compile libinput
libinput: download-libinput libevdev libwacom .libinput-done
.libinput-done:
	mkdir -p $(LIBINPUT_PATH)/build && cd $(LIBINPUT_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release -D debug-gui=false -D documentation=false -D tests=false -Dc_args="-Wno-error" -Dc_link_args="-Wl,-rpath-link=$(STAGING_PATH)/usr/lib -lglib-2.0 -lgobject-2.0" && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .libinput-done

# Download libevdev
download-libevdev: .libevdev-obtained
.libevdev-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libevdev-$(LIBEVDEV_VER).tar.xz $(LIBEVDEV_URL) && tar xf libevdev-$(LIBEVDEV_VER).tar.xz
	touch .libevdev-obtained

# Compile libevdev
libevdev: download-libevdev .libevdev-done
.libevdev-done:
	mkdir -p $(LIBEVDEV_PATH)/build && cd $(LIBEVDEV_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release -D documentation=disabled -D tests=disabled && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .libevdev-done

# Download mtdev
download-mtdev: .mtdev-obtained
.mtdev-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O mtdev-$(MTDEV_VER).tar.bz2 $(MTDEV_URL) && tar xf mtdev-$(MTDEV_VER).tar.bz2
	touch .mtdev-obtained

# Compile mtdev
mtdev: download-mtdev .mtdev-done
.mtdev-done:
	cd $(MTDEV_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .mtdev-done

# Download libwacom
download-libwacom: .libwacom-obtained
.libwacom-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libwacom-$(LIBWACOM_VER).tar.xz $(LIBWACOM_URL) && tar xf libwacom-$(LIBWACOM_VER).tar.xz
	touch .libwacom-obtained

# Compile libwacom
libwacom: download-libwacom libgudev .libwacom-done
.libwacom-done:
	mkdir -p $(LIBWACOM_PATH)/build && cd $(LIBWACOM_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release -D tests=disabled && ninja && DESTDIR=$(STAGING_PATH) ninja install && \
	sed -i 's|prefix=/usr|prefix=$(STAGING_PATH)/usr|g' $(STAGING_PATH)/usr/lib/pkgconfig/libwacom.pc
	touch .libwacom-done

# Download libgudev
download-libgudev: .libgudev-obtained
.libgudev-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libgudev-$(LIBGUDEV_VER).tar.xz $(LIBGUDEV_URL) && tar xf libgudev-$(LIBGUDEV_VER).tar.xz
	touch .libgudev-obtained

# Compile libgudev
libgudev: download-libgudev .libgudev-done
.libgudev-done:
	mkdir -p $(LIBGUDEV_PATH)/build && cd $(LIBGUDEV_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release -D introspection=disabled -Dc_args="-Wno-error" .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .libgudev-done

# Download feh
download-feh: .feh-obtained
.feh-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O feh-$(FEH_VER).tar.bz2 $(FEH_URL) && tar xf feh-$(FEH_VER).tar.bz2
	touch .feh-obtained

# Compile feh
feh: download-feh .feh-done
.feh-done:
	cd $(FEH_PATH) && sed -i "s:doc/feh:&-3.10.3:" config.mk && $(MAKE) -j$(THREADS) PREFIX=/usr && $(MAKE) PREFIX=$(STAGING_PATH)/usr install
	mkdir -p $(STAGING_PATH)/usr/share/backgrounds && cp X11-bg.png $(STAGING_PATH)/usr/share/backgrounds/
	touch .feh-done

# Download imlib2
download-imlib2: .imlib2-obtained
.imlib2-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O imlib2-$(IMLIB2_VER).tar.xz $(IMLIB2_URL) && tar xf imlib2-$(IMLIB2_VER).tar.xz
	touch .imlib2-obtained

# Compile imlib2
imlib2: download-imlib2 .imlib2-done
.imlib2-done:
	rm -f $(STAGING_PATH)/usr/lib/libbz2.a
	cd $(IMLIB2_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .imlib2-done

# Download cairo
download-cairo: .cairo-obtained
.cairo-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O cairo-$(CAIRO_VER).tar.xz $(CAIRO_URL) && tar xf cairo-$(CAIRO_VER).tar.xz
	touch .cairo-obtained

# Download pango
download-pango: .pango-obtained
.pango-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O pango-$(PANGO_VER).tar.xz $(PANGO_URL) && tar xf pango-$(PANGO_VER).tar.xz
	touch .pango-obtained

# Compile cairo
cairo: download-cairo .cairo-done
.cairo-done:
	mkdir -p $(CAIRO_PATH)/build && cd $(CAIRO_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release -D tests=disabled -D png=enabled -D fontconfig=enabled -D freetype=enabled -Dc_link_args="-Wl,-rpath-link=$(STAGING_PATH)/usr/lib -lpng16 -lm" .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .cairo-done

# Compile pango
pango: download-pango libthai cairo .pango-done
.pango-done:
	cd $(PANGO_PATH) && sed -i '/#include <hb-ft.h>/a #include <fontconfig\/fcfreetype.h>' pango/pangofc-fontmap.c && \
	mkdir -p build && cd build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release --wrap-mode=nofallback -D introspection=disabled -Dc_args="-Wno-error" -Dc_link_args="-Wl,-rpath-link=$(STAGING_PATH)/usr/lib -lpng16 -lm" .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .pango-done

# Download libthai
download-libthai: .libthai-obtained
.libthai-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libthai-$(LIBTHAI_VER).tar.xz $(LIBTHAI_URL) && tar xf libthai-$(LIBTHAI_VER).tar.xz
	touch .libthai-obtained

# Compile libthai
libthai: download-libthai .libthai-done
.libthai-done:
	cd $(LIBTHAI_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libthai-done

# Download libdatrie
download-libdatrie: .libdatrie-obtained
.libdatrie-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libdatrie-$(LIBDATRIE_VER).tar.xz $(LIBDATRIE_URL) && tar xf libdatrie-$(LIBDATRIE_VER).tar.xz
	touch .libdatrie-obtained

# Compile libdatrie
libdatrie: download-libdatrie .libdatrie-done
.libdatrie-done:
	cd $(LIBDATRIE_PATH) && CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libdatrie-done

# Download librsvg
download-librsvg: .librsvg-obtained
.librsvg-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O librsvg-$(LIBRSVG_VER).tar.xz $(LIBRSVG_URL) && tar xf librsvg-$(LIBRSVG_VER).tar.xz
	touch .librsvg-obtained

# Compile librsvg
librsvg: download-librsvg pango gdk-pixbuf .librsvg-done
.librsvg-done:
	mkdir -p $(LIBRSVG_PATH)/build && cd $(LIBRSVG_PATH) && sed -e "/OUTDIR/s|,| / 'librsvg-2.60.0', '--no-namespace-dir',|" -e '/output/s|Rsvg-2.0|librsvg-2.60.0|' -i doc/meson.build && \
	cd build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .librsvg-done

# Download libdav1d
download-libdav1d: .libdav1d-obtained
.libdav1d-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O dav1d-$(LIBDAV1D_VER).tar.xz $(LIBDAV1D_URL) && tar xf dav1d-$(LIBDAV1D_VER).tar.xz
	touch .libdav1d-obtained

# Compile libdav1d
libdav1d: download-libdav1d .libdav1d-done
.libdav1d-done:
	mkdir -p $(LIBDAV1D_PATH)/build && cd $(LIBDAV1D_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .libdav1d-done

# Download gdk-pixbuf
download-gdk-pixbuf: .gdk-pixbuf-obtained
.gdk-pixbuf-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O gdk-pixbuf-$(GDK_PIXBUF_VER).tar.xz $(GDK_PIXBUF_URL) && tar xf gdk-pixbuf-$(GDK_PIXBUF_VER).tar.xz
	touch .gdk-pixbuf-obtained

# Compile gdk-pixbuf
gdk-pixbuf: download-gdk-pixbuf .gdk-pixbuf-done
.gdk-pixbuf-done:
	mkdir -p $(GDK_PIXBUF_PATH)/build && cd $(GDK_PIXBUF_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release -D others=enabled -D png=enabled -D shared_mime_info=disabled --wrap-mode=nofallback && \
	ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .gdk-pixbuf-done

# Download libjpeg-turbo
download-libjpeg-turbo: .libjpeg-turbo-obtained
.libjpeg-turbo-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libjpeg-turbo-$(LIBJPEG_TURBO_VER).tar.gz $(LIBJPEG_TURBO_URL) && tar xf libjpeg-turbo-$(LIBJPEG_TURBO_VER).tar.gz
	touch .libjpeg-turbo-obtained

# Compile libjpeg-turbo
libjpeg-turbo: download-libjpeg-turbo .libjpeg-turbo-done
.libjpeg-turbo-done:
	mkdir -p $(LIBJPEG_TURBO_PATH)/build && cd $(LIBJPEG_TURBO_PATH)/build && cmake -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=RELEASE -D ENABLE_STATIC=FALSE  -D WITH_JPEG8=ON \
	-D CMAKE_INSTALL_DEFAULT_LIBDIR=lib -D CMAKE_POLICY_VERSION_MINIMUM=3.5 -D CMAKE_SKIP_INSTALL_RPATH=ON -D CMAKE_INSTALL_DOCDIR=/usr/share/doc/libjpeg-turbo-3.0.1 .. && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libjpeg-turbo-done

# Vulkan Loader
VULKAN_VER = 1.3.290
VULKAN_HEADERS_URL = https://github.com/KhronosGroup/Vulkan-Headers/archive/refs/tags/v$(VULKAN_VER).tar.gz
VULKAN_LOADER_URL = https://github.com/KhronosGroup/Vulkan-Loader/archive/refs/tags/v$(VULKAN_VER).tar.gz

vulkan: .vulkan-done
.vulkan-done:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O vulkan-headers-$(VULKAN_VER).tar.gz $(VULKAN_HEADERS_URL) && tar xf vulkan-headers-$(VULKAN_VER).tar.gz
	mkdir -p $(SRC_PATH)/Vulkan-Headers-$(VULKAN_VER)/build && cd $(SRC_PATH)/Vulkan-Headers-$(VULKAN_VER)/build && \
	cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make install DESTDIR=$(STAGING_PATH)
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O vulkan-loader-$(VULKAN_VER).tar.gz $(VULKAN_LOADER_URL) && tar xf vulkan-loader-$(VULKAN_VER).tar.gz
	mkdir -p $(SRC_PATH)/Vulkan-Loader-$(VULKAN_VER)/build && cd $(SRC_PATH)/Vulkan-Loader-$(VULKAN_VER)/build && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="--sysroot=$(STAGING_PATH) -I$(STAGING_PATH)/usr/include" LDFLAGS="--sysroot=$(STAGING_PATH) -L$(STAGING_PATH)/usr/lib" \
	cmake -DCMAKE_INSTALL_PREFIX=/usr -DVULKAN_HEADERS_INSTALL_DIR=$(STAGING_PATH)/usr -DBUILD_TESTS=OFF .. && \
	$(MAKE) -j$(THREADS) && $(MAKE) install DESTDIR=$(STAGING_PATH)
	touch .vulkan-done

# Window Maker (wmaker-crm fork)
# URL: https://repo.or.cz/w/wmaker-crm.git
WMAKER_URL = https://repo.or.cz/w/wmaker-crm.git/snapshot/wmaker-crm-0.9.6.tar.gz
WMAKER_VER = 0.9.6
WMAKER_PATH = $(SRC_PATH)/wmaker-crm-$(WMAKER_VER)

# Download Window Maker
download-wmaker: .wmaker-obtained
.wmaker-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O wmaker-crm-$(WMAKER_VER).tar.gz $(WMAKER_URL) && tar xf wmaker-crm-$(WMAKER_VER).tar.gz
	touch .wmaker-obtained

# Compile Window Maker
wmaker: download-wmaker .wmaker-done
.wmaker-done:
	cd $(WMAKER_PATH) && ./autogen.sh && \
	CFLAGS="-O2 -std=gnu17" ./configure --prefix=/usr --sysconfdir=/etc --enable-modelock --enable-pango --with-x --disable-imagemagick && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .wmaker-done
