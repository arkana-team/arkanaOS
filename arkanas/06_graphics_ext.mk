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

# Wayland
# URL: 
WAYLAND_URL = https://gitlab.freedesktop.org/wayland/wayland/-/releases/1.24.0/downloads/wayland-1.24.0.tar.xz
WAYLAND_VER = 1.24.0
WAYLAND_PATH = $(SRC_PATH)/wayland-$(WAYLAND_VER)

# Wayland Protocols
WAYLAND_PROTOCOLS_URL = https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/1.45/downloads/wayland-protocols-1.45.tar.xz
WAYLAND_PROTOCOLS_VER = 1.45
WAYLAND_PROTOCOLS_PATH = $(SRC_PATH)/wayland-protocols-$(WAYLAND_PROTOCOLS_VER)

# Weston
# URL: 
WESTON_URL = https://gitlab.freedesktop.org/wayland/weston/-/releases/14.0.2/downloads/weston-14.0.2.tar.xz
WESTON_VER = 14.0.2
WESTON_PATH = $(SRC_PATH)/weston-$(WESTON_VER)

# Libxkbcommon
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libxkbcommon.html
LIBXKBCOMMON_URL = https://github.com/lfs-book/libxkbcommon/archive/v1.11.0/libxkbcommon-1.11.0.tar.gz
LIBXKBCOMMON_VER = 1.11.0
LIBXKBCOMMON_PATH = $(SRC_PATH)/libxkbcommon-$(LIBXKBCOMMON_VER)

# Libunwind
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libunwind.html
LIBUNWIND_URL = https://github.com/libunwind/libunwind/releases/download/v1.8.3/libunwind-1.8.3.tar.gz
LIBUNWIND_VER = 1.8.3
LIBUNWIND_PATH = $(SRC_PATH)/libunwind-$(LIBUNWIND_VER)

# Libwebp
# URL: www.linuxfromscratch.org/blfs/view/systemd/general/libwebp.html
LIBWEBP_URL = https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.6.0.tar.gz
LIBWEBP_VER = 1.6.0
LIBWEBP_PATH = $(SRC_PATH)/libwebp-$(LIBWEBP_VER)

# Giflib
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/giflib.html
GIFLIB_URL = https://sourceforge.net/projects/giflib/files/giflib-5.2.2.tar.gz
GIFLIB_VER = 5.2.2
GIFLIB_PATH = $(SRC_PATH)/giflib-$(GIFLIB_VER)

# Libtiff
# URL: 
LIBTIFF_URL = https://download.osgeo.org/libtiff/tiff-4.7.1.tar.gz
LIBTIFF_VER = 4.7.1
LIBTIFF_PATH = $(SRC_PATH)/tiff-$(LIBTIFF_VER)

# Libdeflate
# URL: 
LIBDEFLATE_URL = https://github.com/ebiggers/libdeflate/releases/download/v1.24/libdeflate-1.24.tar.gz
LIBDEFLATE_VER = 1.24
LIBDEFLATE_PATH = $(SRC_PATH)/libdeflate-$(LIBDEFLATE_VER)

# Jbig-kit
JBIG_KIT_URL = https://www.cl.cam.ac.uk/~mgk25/jbigkit/download/jbigkit-2.1.tar.gz
JBIG_KIT_PATCH_URL = https://gitlab.archlinux.org/archlinux/packaging/packages/jbigkit/-/raw/main/jbigkit-2.1-shared_lib.patch
JBIG_KIT_VER = 2.1
JBIG_KIT_PATH = $(SRC_PATH)/jbigkit-$(JBIG_KIT_VER)

# XWayland
XWAYLAND_URL = https://www.x.org/pub/individual/xserver/xwayland-24.1.9.tar.xz
XWAYLAND_VER = 24.1.9
XWAYLAND_PATH = $(SRC_PATH)/xwayland-$(XWAYLAND_VER)

# Libepoxy
# What epoxy? This is code.
LIBEPOXY_URL = https://download.gnome.org/sources/libepoxy/1.5/libepoxy-1.5.10.tar.xz
LIBEPOXY_VER = 1.5.10
LIBEPOXY_PATH = $(SRC_PATH)/libepoxy-$(LIBEPOXY_VER)

# Labwc
# This is Wayland's Openbox.
LABWC_URL = https://github.com/labwc/labwc/archive/refs/tags/0.9.3.tar.gz
LABWC_VER = 0.9.3
LABWC_PATH = $(SRC_PATH)/labwc-$(LABWC_VER)

WLROOTS_URL = https://gitlab.freedesktop.org/wlroots/wlroots/-/archive/0.19.0/wlroots-0.19.0.tar.gz
WLROOTS_VER = 0.19.0
WLROOTS_PATH = $(SRC_PATH)/wlroots-$(WLROOTS_VER)

LIBDISPLAY_INFO_URL = https://gitlab.freedesktop.org/emersion/libdisplay-info/-/archive/0.2.0/libdisplay-info-0.2.0.tar.gz
LIBDISPLAY_INFO_VER = 0.2.0
LIBDISPLAY_INFO_PATH = $(SRC_PATH)/libdisplay-info-$(LIBDISPLAY_INFO_VER)

XCB_UTIL_WM_URL = https://xcb.freedesktop.org/dist/xcb-util-wm-0.4.2.tar.xz
XCB_UTIL_WM_VER = 0.4.2
XCB_UTIL_WM_PATH = $(SRC_PATH)/xcb-util-wm-$(XCB_UTIL_WM_VER)

LIBSFDO_URL = https://gitlab.freedesktop.org/vyivel/libsfdo/-/archive/v0.1.3/libsfdo-v0.1.3.tar.gz
LIBSFDO_VER = v0.1.3
LIBSFDO_PATH = $(SRC_PATH)/libsfdo-$(LIBSFDO_VER)

# Seatd
SEATD_URL = https://git.sr.ht/~kennylevinsen/seatd/archive/0.9.2.tar.gz
SEATD_VER = 0.9.2
SEATD_PATH = $(SRC_PATH)/seatd-$(SEATD_VER)

all: wayland wayland-protocols libxkbcommon seatd weston libunwind libwebp giflib libtiff libdeflate libjbig xwayland libepoxy labwc

download-wayland: .wayland-obtained
.wayland-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O wayland-$(WAYLAND_VER).tar.xz $(WAYLAND_URL) && tar xf wayland-$(WAYLAND_VER).tar.xz
	touch .wayland-obtained

wayland: download-wayland .wayland-done
.wayland-done:
	mkdir -p $(WAYLAND_PATH)/build && cd $(WAYLAND_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release -D documentation=false && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .wayland-done

download-wayland-protocols: .wayland-protocols-obtained
.wayland-protocols-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O wayland-protocols-$(WAYLAND_PROTOCOLS_VER).tar.xz $(WAYLAND_PROTOCOLS_URL) && tar xf wayland-protocols-$(WAYLAND_PROTOCOLS_VER).tar.xz
	touch .wayland-protocols-obtained

wayland-protocols: download-wayland-protocols .wayland-protocols-done
.wayland-protocols-done:
	mkdir -p $(WAYLAND_PROTOCOLS_PATH)/build && cd $(WAYLAND_PROTOCOLS_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release -Dtests=false -Dc_args="-Wno-error" -Dcpp_args="-Wno-error" && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .wayland-protocols-done

download-weston: .weston-obtained
.weston-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O weston-$(WESTON_VER).tar.xz $(WESTON_URL) && tar xf weston-$(WESTON_VER).tar.xz
	touch .weston-obtained

weston: download-weston libxkbcommon seatd .weston-done
.weston-done:
    # Why are you using outdated FFmpeg syntax?
	mkdir -p $(WESTON_PATH)/build && cd $(WESTON_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release -Ddemo-clients=false -Dbackend-vnc=false -Dcolor-management-lcms=false -Dimage-webp=false -Dpipewire=false -Dbackend-pipewire=false -Dbackend-rdp=false -Dremoting=false -Dtests=false -Dshell-kiosk=false -Dshell-fullscreen=false -Dbackend-drm-screencast-vaapi=false -Dc_link_args="-Wl,-rpath-link=$(STAGING_PATH)/usr/lib -lglib-2.0 -lgobject-2.0" && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .weston-done

download-libxkbcommon: .libxkbcommon-obtained
.libxkbcommon-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libxkbcommon-$(LIBXKBCOMMON_VER).tar.gz $(LIBXKBCOMMON_URL) && tar xf libxkbcommon-$(LIBXKBCOMMON_VER).tar.gz
	touch .libxkbcommon-obtained

libxkbcommon: download-libxkbcommon .libxkbcommon-done
.libxkbcommon-done:
	mkdir -p $(LIBXKBCOMMON_PATH)/build && cd $(LIBXKBCOMMON_PATH)/build && meson setup --native-file $(SRC_PATH)/cross_file.txt .. --prefix=/usr --buildtype=release -D enable-docs=false && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .libxkbcommon-done

download-libunwind: .libunwind-obtained
.libunwind-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libunwind-$(LIBUNWIND_VER).tar.gz $(LIBUNWIND_URL) && tar xf libunwind-$(LIBUNWIND_VER).tar.gz
	touch .libunwind-obtained

libunwind: download-libunwind .libunwind-done
.libunwind-done:
	cd $(LIBUNWIND_PATH) && sed -i '/func.s/s/s//' tests/Gtest-nomalloc.c && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --disable-static && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libunwind-done

download-libwebp: .libwebp-obtained
.libwebp-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libwebp-$(LIBWEBP_VER).tar.gz $(LIBWEBP_URL) && tar xf libwebp-$(LIBWEBP_VER).tar.gz
	touch .libwebp-obtained

libwebp: download-libwebp .libwebp-done
.libwebp-done:
	cd $(LIBWEBP_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --enable-libwebpmux --enable-libwebpdemux --enable-libwebpdecoder \
	--enable-libwebpextras --enable-swap-16bit-csp --disable-static && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libwebp-done

download-giflib: .giflib-obtained
.giflib-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O giflib-$(GIFLIB_VER).tar.gz $(GIFLIB_URL) && tar xf giflib-$(GIFLIB_VER).tar.gz
	touch .giflib-obtained

giflib: download-giflib .giflib-done
.giflib-done:
	cd $(GIFLIB_PATH) && cp pic/gifgrid.gif doc/giflib-logo.gif && $(MAKE) -j$(THREADS) && $(MAKE) PREFIX=$(STAGING_PATH)/usr install
	touch .giflib-done

download-libtiff: .libtiff-obtained
.libtiff-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libtiff-$(LIBTIFF_VER).tar.gz $(LIBTIFF_URL) && tar xf libtiff-$(LIBTIFF_VER).tar.gz
	touch .libtiff-obtained

libtiff: download-libtiff .libtiff-done
.libtiff-done:
	mkdir -p $(LIBTIFF_PATH)/build && cd $(LIBTIFF_PATH)/build && cmake -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release \
	-W no-dev -G Ninja .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .libtiff-done

download-libdeflate: .libdeflate-obtained
.libdeflate-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libdeflate-$(LIBDEFLATE_VER).tar.gz $(LIBDEFLATE_URL) && tar xf libdeflate-$(LIBDEFLATE_VER).tar.gz
	touch .libdeflate-obtained

libdeflate: download-libdeflate .libdeflate-done
.libdeflate-done:
	cd $(LIBDEFLATE_PATH) && \
	sed -i 's/#  define EVEX512.*/#  define EVEX512 ""/' lib/x86/cpu_features.h && \
	sed -i 's/#  define NO_EVEX512.*/#  define NO_EVEX512 ""/' lib/x86/cpu_features.h && \
	mkdir -p build && cd build && cmake -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release .. && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libdeflate-done
	
download-libjbig: .libjbig-obtained
.libjbig-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O jbigkit-$(JBIG_KIT_VER).tar.gz $(JBIG_KIT_URL) && tar xf jbigkit-$(JBIG_KIT_VER).tar.gz
	touch .libjbig-obtained

# Hey Mr. Cambridge guy, care to update your build system? It's so UNIX.
libjbig: download-libjbig .libjbig-done
.libjbig-done:
	cd $(JBIG_KIT_PATH) && (curl -s -f $(JBIG_KIT_PATCH_URL) | patch -N -p1 || true) && find . -name Makefile -exec sed -i 's/^CFLAGS\s*=/CFLAGS += -g -O2 -std=gnu17 /' {} + && $(MAKE) -j$(THREADS) && cp -a libjbig/libjbig.so.2.1 $(STAGING_PATH)/usr/lib && \
	ln -sf libjbig.so.2.1 $(STAGING_PATH)/usr/lib/libjbig.so
	touch .libjbig-done

download-xwayland: .xwayland-obtained
.xwayland-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O xwayland-$(XWAYLAND_VER).tar.xz $(XWAYLAND_URL) && tar xf xwayland-$(XWAYLAND_VER).tar.xz
	touch .xwayland-obtained

xwayland: download-xwayland .xwayland-done
.xwayland-done:
	cd $(XWAYLAND_PATH) && sed -i '/install_man/,$$d' meson.build && mkdir -p build && cd build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release -Dxkb_output_dir=/var/lib/xkb .. && \
	ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .xwayland-done

download-libepoxy: .libepoxy-obtained
.libepoxy-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libepoxy-$(LIBEPOXY_VER).tar.xz $(LIBEPOXY_URL) && tar xf libepoxy-$(LIBEPOXY_VER).tar.xz
	touch .libepoxy-obtained

libepoxy: download-libepoxy .libepoxy-done
.libepoxy-done:
	cd $(LIBEPOXY_PATH) && mkdir -p build && cd build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .libepoxy-done

download-libdisplay-info: .libdisplay-info-obtained
.libdisplay-info-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libdisplay-info-$(LIBDISPLAY_INFO_VER).tar.gz $(LIBDISPLAY_INFO_URL) && tar xf libdisplay-info-$(LIBDISPLAY_INFO_VER).tar.gz
	touch .libdisplay-info-obtained

libdisplay-info: download-libdisplay-info .libdisplay-info-done
.libdisplay-info-done:
	cd $(LIBDISPLAY_INFO_PATH) && mkdir -p build && cd build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .libdisplay-info-done

HWDATA_URL = https://github.com/vcrhonek/hwdata/archive/refs/tags/v0.392.tar.gz
HWDATA_VER = 0.392
HWDATA_PATH = $(SRC_PATH)/hwdata-$(HWDATA_VER)

download-hwdata: .hwdata-obtained
.hwdata-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O hwdata-$(HWDATA_VER).tar.gz $(HWDATA_URL) && tar xf hwdata-$(HWDATA_VER).tar.gz
	touch .hwdata-obtained

hwdata: download-hwdata .hwdata-done
.hwdata-done:
	cd $(HWDATA_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .hwdata-done

download-wlroots: .wlroots-obtained
.wlroots-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O wlroots-$(WLROOTS_VER).tar.gz $(WLROOTS_URL) && tar xf wlroots-$(WLROOTS_VER).tar.gz
	touch .wlroots-obtained

wlroots: download-wlroots libdisplay-info seatd hwdata .wlroots-done
.wlroots-done:
	cd $(WLROOTS_PATH) && rm -rf build && mkdir -p build && cd build && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include" LDFLAGS="-L$(STAGING_PATH)/usr/lib" \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release -D backends=drm,libinput -D renderers=gles2 -D examples=false .. && ninja && DESTDIR=$(STAGING_PATH) ninja install && \
	sed -i 's|prefix=/usr|prefix=$(STAGING_PATH)/usr|g' $(STAGING_PATH)/usr/lib/pkgconfig/wlroots*.pc
	touch .wlroots-done

download-xcb-util-wm: .xcb-util-wm-obtained
.xcb-util-wm-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O xcb-util-wm-$(XCB_UTIL_WM_VER).tar.xz $(XCB_UTIL_WM_URL) && tar xf xcb-util-wm-$(XCB_UTIL_WM_VER).tar.xz
	touch .xcb-util-wm-obtained

xcb-util-wm: download-xcb-util-wm .xcb-util-wm-done
.xcb-util-wm-done:
	cd $(XCB_UTIL_WM_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && \
	sed -i 's|prefix=/usr|prefix=$(STAGING_PATH)/usr|g' $(STAGING_PATH)/usr/lib/pkgconfig/xcb-*.pc
	touch .xcb-util-wm-done

download-libsfdo: .libsfdo-obtained
.libsfdo-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libsfdo-$(LIBSFDO_VER).tar.gz $(LIBSFDO_URL) && tar xf libsfdo-$(LIBSFDO_VER).tar.gz
	touch .libsfdo-obtained

libsfdo: download-libsfdo .libsfdo-done
.libsfdo-done:
	cd $(LIBSFDO_PATH) && mkdir -p build && cd build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release .. && ninja && DESTDIR=$(STAGING_PATH) ninja install && \
	sed -i 's|prefix=/usr|prefix=$(STAGING_PATH)/usr|g' $(STAGING_PATH)/usr/lib/pkgconfig/libsfdo*.pc
	touch .libsfdo-done

download-labwc: .labwc-obtained
.labwc-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O labwc-$(LABWC_VER).tar.gz $(LABWC_URL) && tar xf labwc-$(LABWC_VER).tar.gz
	touch .labwc-obtained

LIBXML2_URL = https://download.gnome.org/sources/libxml2/2.14/libxml2-2.14.5.tar.xz
LIBXML2_VER = 2.14.5
LIBXML2_PATH = $(SRC_PATH)/libxml2-$(LIBXML2_VER)

download-libxml2: .libxml2-obtained
.libxml2-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libxml2-$(LIBXML2_VER).tar.gz $(LIBXML2_URL) && tar xf libxml2-$(LIBXML2_VER).tar.gz
	touch .libxml2-obtained

libxml2: download-libxml2 .libxml2-done
.libxml2-done:
	cd $(LIBXML2_PATH) && ./configure CFLAGS="-O2 -std=gnu17" --prefix=/usr --sysconfdir=/etc --without-python && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libxml2-done

labwc: download-labwc wlroots xcb-util-wm libsfdo libxml2 .labwc-done

.labwc-done:
	cd $(LABWC_PATH) && rm -rf build && mkdir -p build && cd build && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include/wlroots-0.19 -I$(STAGING_PATH)/usr/include -I$(STAGING_PATH)/usr/include/pixman-1" \
	LDFLAGS="-L$(STAGING_PATH)/usr/lib -lwacom" \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	meson setup --prefix=/usr --native-file $(SRC_PATH)/cross_file.txt -Dc_args="-Uunix" --buildtype=release --wrap-mode=nodownload .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	# Why is pam_systemd.so not doing this for us?
	echo >> $(STAGING_PATH)/etc/profile
	echo '# Set XDG_RUNTIME_DIR if not already set by the system' >> $(STAGING_PATH)/etc/profile
	echo 'if [ -z "$$XDG_RUNTIME_DIR" ]; then' >> $(STAGING_PATH)/etc/profile
	echo '    export XDG_RUNTIME_DIR="/run/user/$$(id -u)"' >> $(STAGING_PATH)/etc/profile
	echo '    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$$(id -u)/bus"' >> $(STAGING_PATH)/etc/profile
	echo 'fi' >> $(STAGING_PATH)/etc/profile

	# You will have to create this for every new user.
	mkdir -p $(STAGING_PATH)/usr/lib/tmpfiles.d
	echo '# Type  Path               Mode  UID   GID   Age  Argument' > $(STAGING_PATH)/usr/lib/tmpfiles.d/user-runtime.conf
	echo 'd       /run/user          0755  root  root  -' >> $(STAGING_PATH)/usr/lib/tmpfiles.d/user-runtime.conf
	echo 'd       /run/user/0        0700  root  root  -' >> $(STAGING_PATH)/usr/lib/tmpfiles.d/user-runtime.conf
	echo 'd       /run/user/1000     0700  1000  1000  -' >> $(STAGING_PATH)/usr/lib/tmpfiles.d/user-runtime.conf
	touch .labwc-done

download-seatd: .seatd-obtained
.seatd-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O seatd-$(SEATD_VER).tar.gz $(SEATD_URL) && tar xf seatd-$(SEATD_VER).tar.gz
	touch .seatd-obtained

seatd: download-seatd .seatd-done
.seatd-done:
	cd $(SEATD_PATH) && mkdir -p build && cd build && meson setup --native-file $(SRC_PATH)/cross_file.txt --prefix=/usr --buildtype=release -Dc_args="-Uunix" -Dserver=enabled -Dlibseat-logind=disabled .. && ninja && DESTDIR=$(STAGING_PATH) ninja install

	# Generate a systemd service so that apps can obtain user sessions via it
	echo '[Unit]' > $(STAGING_PATH)/usr/lib/systemd/system/seatd.service
	echo 'Description=Seat management daemon' >> $(STAGING_PATH)/usr/lib/systemd/system/seatd.service
	echo >> $(STAGING_PATH)/usr/lib/systemd/system/seatd.service
	echo '[Service]' >> $(STAGING_PATH)/usr/lib/systemd/system/seatd.service
	echo 'Type=simple' >> $(STAGING_PATH)/usr/lib/systemd/system/seatd.service
	echo 'ExecStart=/usr/bin/seatd -g video' >> $(STAGING_PATH)/usr/lib/systemd/system/seatd.service
	echo 'Restart=always' >> $(STAGING_PATH)/usr/lib/systemd/system/seatd.service
	echo >> $(STAGING_PATH)/usr/lib/systemd/system/seatd.service
	echo '[Install]' >> $(STAGING_PATH)/usr/lib/systemd/system/seatd.service
	echo 'WantedBy=multi-user.target' >> $(STAGING_PATH)/usr/lib/systemd/system/seatd.service

	ln -sf /usr/lib/systemd/system/seatd.service $(STAGING_PATH)/etc/systemd/system/multi-user.target.wants/seatd.service
	touch .seatd-done

# FLTK (Toolkit for Dillo)
FLTK_URL = https://www.fltk.org/pub/fltk/1.3.9/fltk-1.3.9-source.tar.gz
FLTK_VER = 1.3.9
FLTK_PATH = $(SRC_PATH)/fltk-$(FLTK_VER)

download-fltk: .fltk-obtained
.fltk-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O fltk-$(FLTK_VER)-source.tar.gz $(FLTK_URL) && tar xf fltk-$(FLTK_VER)-source.tar.gz
	touch .fltk-obtained

fltk: download-fltk .fltk-done
.fltk-done:
	cd $(FLTK_PATH) && rm -f config.cache && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="--sysroot=$(STAGING_PATH) -I$(STAGING_PATH)/usr/include -O2 -std=gnu17" \
	CXXFLAGS="--sysroot=$(STAGING_PATH) -I$(STAGING_PATH)/usr/include -O2 -std=gnu17" \
	LDFLAGS="--sysroot=$(STAGING_PATH) -L$(STAGING_PATH)/usr/lib -Wl,-rpath-link,$(STAGING_PATH)/usr/lib" \
	./configure --prefix=/usr --enable-shared --disable-gl && \
	sed -i '/^DSOFLAGS/s|=|= --sysroot=$(STAGING_PATH) -L$(STAGING_PATH)/usr/lib -Wl,-rpath-link,$(STAGING_PATH)/usr/lib|' makeinclude && \
	$(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install && \
	sed -i 's|-I/usr/include|-I$(STAGING_PATH)/usr/include|g' $(STAGING_PATH)/usr/bin/fltk-config && \
	sed -i 's|-L/usr/lib|-L$(STAGING_PATH)/usr/lib|g' $(STAGING_PATH)/usr/bin/fltk-config
	touch .fltk-done

# Dillo Web Browser
DILLO_URL = https://github.com/dillo-browser/dillo/releases/download/v3.1.1/dillo-3.1.1.tar.bz2
DILLO_VER = 3.1.1
DILLO_PATH = $(SRC_PATH)/dillo-$(DILLO_VER)

download-dillo: .dillo-obtained
.dillo-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O dillo-$(DILLO_VER).tar.bz2 $(DILLO_URL) && tar xf dillo-$(DILLO_VER).tar.bz2
	touch .dillo-obtained

dillo: download-dillo fltk .dillo-done
.dillo-done:
	cd $(DILLO_PATH) && rm -f config.cache && \
	sed -i 's/arrayExtra,/arrayExtra1,/g' lout/misc.hh 2>/dev/null || true ; \
	sed -i 's/this->arrayExtra =/this->arrayExtra1 =/g' lout/misc.hh 2>/dev/null || true ; \
	PATH="$(STAGING_PATH)/usr/bin:$$PATH" \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CC="gcc" CXX="g++" \
	CFLAGS="--sysroot=$(STAGING_PATH) -I$(STAGING_PATH)/usr/include -fpermissive -Wno-error=incompatible-pointer-types -O2 -std=gnu17" \
	CXXFLAGS="--sysroot=$(STAGING_PATH) -I$(STAGING_PATH)/usr/include -fpermissive -Wno-error=incompatible-pointer-types -O2 -std=gnu17" \
	LDFLAGS="--sysroot=$(STAGING_PATH) -L$(STAGING_PATH)/usr/lib -Wl,-rpath-link,$(STAGING_PATH)/usr/lib" \
	./configure --prefix=/usr --sysconfdir=/etc --disable-tls && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .dillo-done
