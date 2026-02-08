# Enable multi-threaded Bash operation
SHELL = bash
THREADS = $(shell nproc)

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

# Seatd
SEATD_URL = https://git.sr.ht/~kennylevinsen/seatd/archive/0.9.2.tar.gz
SEATD_VER = 0.9.2
SEATD_PATH = $(SRC_PATH)/seatd-$(SEATD_VER)

all: wayland wayland-protocols weston libxkbcommon libunwind libwebp giflib libtiff libdeflate libjbig xwayland libepoxy labwc seatd

download-wayland: .wayland-obtained
.wayland-obtained:
	cd $(SRC_PATH) && wget -O wayland-$(WAYLAND_VER).tar.xz $(WAYLAND_URL) && tar xf wayland-$(WAYLAND_VER).tar.xz
	touch .wayland-obtained

wayland: download-wayland .wayland-done
.wayland-done:
	mkdir -p $(WAYLAND_PATH)/build && cd $(WAYLAND_PATH)/build && meson setup .. --prefix=/usr --buildtype=release -D documentation=false && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .wayland-done

download-wayland-protocols: .wayland-protocols-obtained
.wayland-protocols-obtained:
	cd $(SRC_PATH) && wget -O wayland-protocols-$(WAYLAND_PROTOCOLS_VER).tar.xz $(WAYLAND_PROTOCOLS_URL) && tar xf wayland-protocols-$(WAYLAND_PROTOCOLS_VER).tar.xz
	touch .wayland-protocols-obtained

wayland-protocols: download-wayland-protocols .wayland-protocols-done
.wayland-protocols-done:
	mkdir -p $(WAYLAND_PROTOCOLS_PATH)/build && cd $(WAYLAND_PROTOCOLS_PATH)/build && meson setup .. --prefix=/usr --buildtype=release && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .wayland-protocols-done

download-weston: .weston-obtained
.weston-obtained:
	cd $(SRC_PATH) && wget -O weston-$(WESTON_VER).tar.xz $(WESTON_URL) && tar xf weston-$(WESTON_VER).tar.xz
	touch .weston-obtained

weston: download-weston .weston-done
.weston-done:
    # Why are you using outdated FFmpeg syntax?
	mkdir -p $(WESTON_PATH)/build && cd $(WESTON_PATH)/build && meson setup .. --prefix=/usr --buildtype=release -Ddemo-clients=false -Dbackend-vnc=false && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .weston-done

download-libxkbcommon: .libxkbcommon-obtained
.libxkbcommon-obtained:
	cd $(SRC_PATH) && wget -O libxkbcommon-$(LIBXKBCOMMON_VER).tar.gz $(LIBXKBCOMMON_URL) && tar xf libxkbcommon-$(LIBXKBCOMMON_VER).tar.gz
	touch .libxkbcommon-obtained

libxkbcommon: download-libxkbcommon .libxkbcommon-done
.libxkbcommon-done:
	mkdir -p $(LIBXKBCOMMON_PATH)/build && cd $(LIBXKBCOMMON_PATH)/build && meson setup .. --prefix=/usr --buildtype=release -D enable-docs=false && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .libxkbcommon-done

download-libunwind: .libunwind-obtained
.libunwind-obtained:
	cd $(SRC_PATH) && wget -O libunwind-$(LIBUNWIND_VER).tar.gz $(LIBUNWIND_URL) && tar xf libunwind-$(LIBUNWIND_VER).tar.gz
	touch .libunwind-obtained

libunwind: download-libunwind .libunwind-done
.libunwind-done:
	cd $(LIBUNWIND_PATH) && sed -i '/func.s/s/s//' tests/Gtest-nomalloc.c && ./configure --prefix=/usr --disable-static && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libunwind-done

download-libwebp: .libwebp-obtained
.libwebp-obtained:
	cd $(SRC_PATH) && wget -O libwebp-$(LIBWEBP_VER).tar.gz $(LIBWEBP_URL) && tar xf libwebp-$(LIBWEBP_VER).tar.gz
	touch .libwebp-obtained

libwebp: download-libwebp .libwebp-done
.libwebp-done:
	cd $(LIBWEBP_PATH) && ./configure --prefix=/usr --enable-libwebpmux --enable-libwebpdemux --enable-libwebpdecoder \
	--enable-libwebpextras --enable-swap-16bit-csp --disable-static && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libwebp-done

download-giflib: .giflib-obtained
.giflib-obtained:
	cd $(SRC_PATH) && wget -O giflib-$(GIFLIB_VER).tar.gz $(GIFLIB_URL) && tar xf giflib-$(GIFLIB_VER).tar.gz
	touch .giflib-obtained

giflib: download-giflib .giflib-done
.giflib-done:
	cd $(GIFLIB_PATH) && cp pic/gifgrid.gif doc/giflib-logo.gif && $(MAKE) -j$(THREADS) && $(MAKE) PREFIX=$(STAGING_PATH)/usr install
	touch .giflib-done

download-libtiff: .libtiff-obtained
.libtiff-obtained:
	cd $(SRC_PATH) && wget -O libtiff-$(LIBTIFF_VER).tar.gz $(LIBTIFF_URL) && tar xf libtiff-$(LIBTIFF_VER).tar.gz
	touch .libtiff-obtained

libtiff: download-libtiff .libtiff-done
.libtiff-done:
	mkdir -p $(LIBTIFF_PATH)/build && cd $(LIBTIFF_PATH)/build && cmake -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release \
	-W no-dev -G Ninja .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .libtiff-done

download-libdeflate: .libdeflate-obtained
.libdeflate-obtained:
	cd $(SRC_PATH) && wget -O libdeflate-$(LIBDEFLATE_VER).tar.gz $(LIBDEFLATE_URL) && tar xf libdeflate-$(LIBDEFLATE_VER).tar.gz
	touch .libdeflate-obtained

libdeflate: download-libdeflate .libdeflate-done
.libdeflate-done:
	mkdir -p $(LIBDEFLATE_PATH)/build && cd $(LIBDEFLATE_PATH)/build && cmake -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release .. && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libdeflate-done
	
download-libjbig: .libjbig-obtained
.libjbig-obtained:
	cd $(SRC_PATH) && wget -O jbigkit-$(JBIG_KIT_VER).tar.gz $(JBIG_KIT_URL) && tar xf jbigkit-$(JBIG_KIT_VER).tar.gz
	touch .libjbig-obtained

# Hey Mr. Cambridge guy, care to update your build system? It's so UNIX.
libjbig: download-libjbig .libjbig-done
.libjbig-done:
	cd $(JBIG_KIT_PATH) && curl -s -f $(JBIG_KIT_PATCH_URL) | patch -Np1 && $(MAKE) -j$(THREADS) && cp -a libjbig/libjbig.so.2.1 $(STAGING_PATH)/usr/lib && \
	ln -sf libjbig.so.2.1 $(STAGING_PATH)/usr/lib/libjbig.so
	touch .libjbig-done

download-xwayland: .xwayland-obtained
.xwayland-obtained:
	cd $(SRC_PATH) && wget -O xwayland-$(XWAYLAND_VER).tar.xz $(XWAYLAND_URL) && tar xf xwayland-$(XWAYLAND_VER).tar.xz
	touch .xwayland-obtained

xwayland: download-xwayland .xwayland-done
.xwayland-done:
	cd $(XWAYLAND_PATH) && sed -i '/install_man/,$$d' meson.build && mkdir -p build && cd build && meson setup --prefix=/usr --buildtype=release -Dxkb_output_dir=/var/lib/xkb .. && \
	ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .xwayland-done

download-libepoxy: .libepoxy-obtained
.libepoxy-obtained:
	cd $(SRC_PATH) && wget -O libepoxy-$(LIBEPOXY_VER).tar.xz $(LIBEPOXY_URL) && tar xf libepoxy-$(LIBEPOXY_VER).tar.xz
	touch .libepoxy-obtained

libepoxy: download-libepoxy .libepoxy-done
.libepoxy-done:
	cd $(LIBEPOXY_PATH) && mkdir -p build && cd build && meson setup --prefix=/usr --buildtype=release .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .libepoxy-done

download-labwc: .labwc-obtained
.labwc-obtained:
	cd $(SRC_PATH) && wget -O labwc-$(LABWC_VER).tar.gz $(LABWC_URL) && tar xf labwc-$(LABWC_VER).tar.gz
	touch .labwc-obtained

labwc: download-labwc .labwc-done

.labwc-done:
	cd $(LABWC_PATH) && mkdir -p build && cd build && meson setup --prefix=/usr -Dc_args="-Uunix" --buildtype=release --wrap-mode=nodownload .. && ninja && DESTDIR=$(STAGING_PATH) ninja install
	# Why is pam_systemd.so not doing this for us?
	echo >> $(STAGING_PATH)/etc/profile
	echo '# Set XDG_RUNTIME_DIR if not already set by the system' >> $(STAGING_PATH)/etc/profile
	echo 'if [ -z "$$XDG_RUNTIME_DIR" ]; then' >> $(STAGING_PATH)/etc/profile
	echo '    export XDG_RUNTIME_DIR="/run/user/$$(id -u)"' >> $(STAGING_PATH)/etc/profile
    echo '    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$$(id -u)/bus"' >> $(STAGING_PATH)/etc/profile
	echo 'fi' >> $(STAGING_PATH)/etc/profile

	# You will have to create this for every new user.
	echo '# Type  Path               Mode  UID   GID   Age  Argument' > $(STAGING_PATH)/usr/lib/tmpfiles.d/user-runtime.conf
	echo 'd       /run/user          0755  root  root  -' >> $(STAGING_PATH)/usr/lib/tmpfiles.d/user-runtime.conf
	echo 'd       /run/user/0        0700  root  root  -' >> $(STAGING_PATH)/usr/lib/tmpfiles.d/user-runtime.conf
	echo 'd       /run/user/1000     0700  1000  1000  -' >> $(STAGING_PATH)/usr/lib/tmpfiles.d/user-runtime.conf
	touch .labwc-done

download-seatd: .seatd-obtained
.seatd-obtained:
	cd $(SRC_PATH) && wget -O seatd-$(SEATD_VER).tar.gz $(SEATD_URL) && tar xf seatd-$(SEATD_VER).tar.gz
	touch .seatd-obtained

seatd: download-seatd .seatd-done
.seatd-done:
	cd $(SEATD_PATH) && mkdir -p build && cd build && meson setup --prefix=/usr --buildtype=release -Dc_args="-Uunix" -Dserver=enabled -Dlibseat-logind=disabled .. && ninja && DESTDIR=$(STAGING_PATH) ninja install

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
