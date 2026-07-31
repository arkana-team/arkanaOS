# Enable multi-threaded Bash operation
SHELL = bash
THREADS = $(shell nproc)

# Paths used to build the ISO components
SRC_PATH = $(shell realpath ./src)
STAGING_PATH = $(shell realpath ./staging)
ISO_STAGING_PATH = $(shell realpath ./iso-staging)
OUTPUT_PATH = $(shell realpath ./output)

# MATE Common
MATE_COMMON_URL = https://pub.mate-desktop.org/releases/1.28/mate-common-1.28.0.tar.xz
MATE_COMMON_VER = 1.28.0
MATE_COMMON_PATH = $(SRC_PATH)/mate-common-$(MATE_COMMON_VER)

# MATE Desktop
MATE_DESKTOP_URL = https://pub.mate-desktop.org/releases/1.28/mate-desktop-1.28.2.tar.xz
MATE_DESKTOP_VER = 1.28.2
MATE_DESKTOP_PATH = $(SRC_PATH)/mate-desktop-$(MATE_DESKTOP_VER)

# Libmatekbd
LIBMATEKBD_URL = https://pub.mate-desktop.org/releases/1.28/libmatekbd-1.28.0.tar.xz
LIBMATEKBD_VER = 1.28.0
LIBMATEKBD_PATH = $(SRC_PATH)/libmatekbd-$(LIBMATEKBD_VER)

# MATE Menus
MATE_MENUS_URL = https://pub.mate-desktop.org/releases/1.28/mate-menus-1.28.0.tar.xz
MATE_MENUS_VER = 1.28.0
MATE_MENUS_PATH = $(SRC_PATH)/mate-menus-$(MATE_MENUS_VER)

# MATE Panel
MATE_PANEL_URL = https://pub.mate-desktop.org/releases/1.28/mate-panel-1.28.4.tar.xz
MATE_PANEL_VER = 1.28.4
MATE_PANEL_PATH = $(SRC_PATH)/mate-panel-$(MATE_PANEL_VER)

# MATE Session Manager
MATE_SESSION_URL = https://pub.mate-desktop.org/releases/1.28/mate-session-manager-1.28.0.tar.xz
MATE_SESSION_VER = 1.28.0
MATE_SESSION_PATH = $(SRC_PATH)/mate-session-manager-$(MATE_SESSION_VER)

# MATE Terminal
MATE_TERMINAL_URL = https://pub.mate-desktop.org/releases/1.28/mate-terminal-1.28.1.tar.xz
MATE_TERMINAL_VER = 1.28.1
MATE_TERMINAL_PATH = $(SRC_PATH)/mate-terminal-$(MATE_TERMINAL_VER)

.PHONY: all
all: mate-common mate-desktop libmatekbd mate-menus mate-panel mate-session mate-terminal mate-iso

download-mate-common: .mate-common-obtained
.mate-common-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O mate-common-$(MATE_COMMON_VER).tar.xz $(MATE_COMMON_URL) && tar xf mate-common-$(MATE_COMMON_VER).tar.xz
	touch .mate-common-obtained

mate-common: download-mate-common .mate-common-done
.mate-common-done:
	cd $(MATE_COMMON_PATH) && ./configure --prefix=/usr --disable-dependency-tracking && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .mate-common-done

download-mate-desktop: .mate-desktop-obtained
.mate-desktop-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O mate-desktop-$(MATE_DESKTOP_VER).tar.xz $(MATE_DESKTOP_URL) && tar xf mate-desktop-$(MATE_DESKTOP_VER).tar.xz
	touch .mate-desktop-obtained

mate-desktop: download-mate-desktop mate-common .mate-desktop-done
.mate-desktop-done:
	cd $(MATE_DESKTOP_PATH) && \
	sed -i 's/noinst_PROGRAMS =.*/noinst_PROGRAMS =/' libmate-desktop/Makefile.in && \
	sed -i 's/test-languages.*//' libmate-desktop/Makefile.in && \
	sed -i 's/^SUBDIRS =.*/SUBDIRS = libmate-desktop schemas icons xdg-portal po/' Makefile.in && \
	sed -i 's/\$$(am__append_1)//' Makefile.in && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include" LDFLAGS="-L$(STAGING_PATH)/usr/lib" \
	./configure --prefix=/usr --disable-dependency-tracking --disable-schemes-compiler --disable-user-guide --disable-introspection && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .mate-desktop-done

# Libxklavier
LIBXKLAVIER_URL = https://people.freedesktop.org/~svu/libxklavier-5.4.tar.bz2
LIBXKLAVIER_VER = 5.4
LIBXKLAVIER_PATH = $(SRC_PATH)/libxklavier-$(LIBXKLAVIER_VER)

download-libxklavier: .libxklavier-obtained
.libxklavier-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libxklavier-$(LIBXKLAVIER_VER).tar.bz2 $(LIBXKLAVIER_URL) && tar xf libxklavier-$(LIBXKLAVIER_VER).tar.bz2
	touch .libxklavier-obtained

libxklavier: download-libxklavier .libxklavier-done
.libxklavier-done:
	cd $(LIBXKLAVIER_PATH) && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include" LDFLAGS="-L$(STAGING_PATH)/usr/lib" \
	./configure --prefix=/usr --disable-dependency-tracking && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libxklavier-done

download-libmatekbd: .libmatekbd-obtained
.libmatekbd-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libmatekbd-$(LIBMATEKBD_VER).tar.xz $(LIBMATEKBD_URL) && tar xf libmatekbd-$(LIBMATEKBD_VER).tar.xz
	touch .libmatekbd-obtained

libmatekbd: download-libmatekbd libxklavier mate-desktop .libmatekbd-done
.libmatekbd-done:
	cd $(LIBMATEKBD_PATH) && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include" LDFLAGS="-L$(STAGING_PATH)/usr/lib" \
	./configure --prefix=/usr --disable-dependency-tracking --disable-introspection && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libmatekbd-done

download-mate-menus: .mate-menus-obtained
.mate-menus-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O mate-menus-$(MATE_MENUS_VER).tar.xz $(MATE_MENUS_URL) && tar xf mate-menus-$(MATE_MENUS_VER).tar.xz
	touch .mate-menus-obtained

mate-menus: download-mate-menus mate-common .mate-menus-done
.mate-menus-done:
	cd $(MATE_MENUS_PATH) && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include" LDFLAGS="-L$(STAGING_PATH)/usr/lib" \
	./configure --prefix=/usr --disable-dependency-tracking --disable-python --disable-introspection && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .mate-menus-done

# Libwnck
LIBWNCK_URL = https://download.gnome.org/sources/libwnck/43/libwnck-43.2.tar.xz
LIBWNCK_VER = 43.2
LIBWNCK_PATH = $(SRC_PATH)/libwnck-$(LIBWNCK_VER)

download-libwnck: .libwnck-obtained
.libwnck-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O libwnck-$(LIBWNCK_VER).tar.xz $(LIBWNCK_URL) && tar xf libwnck-$(LIBWNCK_VER).tar.xz
	touch .libwnck-obtained

libwnck: download-libwnck .libwnck-done
.libwnck-done:
	mkdir -p $(LIBWNCK_PATH)/build && cd $(LIBWNCK_PATH)/build && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include" LDFLAGS="-L$(STAGING_PATH)/usr/lib" \
	meson setup .. --prefix=/usr --native-file $(SRC_PATH)/cross_file.txt --buildtype=release -Dintrospection=disabled -Dgtk_doc=false && \
	ninja && DESTDIR=$(STAGING_PATH) ninja install && \
	sed -i 's|prefix=/usr|prefix=$(STAGING_PATH)/usr|g' $(STAGING_PATH)/usr/lib/pkgconfig/libwnck-3.0.pc
	touch .libwnck-done

download-mate-panel: .mate-panel-obtained
.mate-panel-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O mate-panel-$(MATE_PANEL_VER).tar.xz $(MATE_PANEL_URL) && tar xf mate-panel-$(MATE_PANEL_VER).tar.xz
	touch .mate-panel-obtained

mate-panel: download-mate-panel libwnck libmatekbd mate-menus .mate-panel-done
.mate-panel-done:
	cd $(MATE_PANEL_PATH) && \
	sed -i 's/noinst_PROGRAMS =.*/noinst_PROGRAMS =/' libmate-panel-applet/Makefile.in && \
	sed -i 's/SUBDIRS =.*/SUBDIRS = fish notification_area wncklet/' applets/Makefile.in && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include -I$(STAGING_PATH)/usr/include/mate-desktop-2.0 -I$(STAGING_PATH)/usr/include/mate-menus -I$(STAGING_PATH)/usr/include/libmate-menu" LDFLAGS="-L$(STAGING_PATH)/usr/lib" \
	CLOCK_CFLAGS="-I$(STAGING_PATH)/usr/include" CLOCK_LIBS="-L$(STAGING_PATH)/usr/lib -lgtk-3 -lgdk-3 -lglib-2.0 -lgio-2.0 -lpango-1.0" \
	ITSTOOL=true ./configure --prefix=/usr --disable-dependency-tracking --disable-introspection && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .mate-panel-done

# DBus GLib
DBUS_GLIB_URL = https://dbus.freedesktop.org/releases/dbus-glib/dbus-glib-0.112.tar.gz
DBUS_GLIB_VER = 0.112
DBUS_GLIB_PATH = $(SRC_PATH)/dbus-glib-$(DBUS_GLIB_VER)

download-dbus-glib: .dbus-glib-obtained
.dbus-glib-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O dbus-glib-$(DBUS_GLIB_VER).tar.gz $(DBUS_GLIB_URL) && tar xf dbus-glib-$(DBUS_GLIB_VER).tar.gz
	touch .dbus-glib-obtained

dbus-glib: download-dbus-glib .dbus-glib-done
.dbus-glib-done:
	sudo pacman -Sy --noconfirm dbus-glib || true
	cd $(DBUS_GLIB_PATH) && \
	sed -i 's/-Werror//g' dbus/Makefile.in && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-std=gnu17 -I$(STAGING_PATH)/usr/include -Wno-error -Wno-deprecated-declarations" LDFLAGS="-L$(STAGING_PATH)/usr/lib" \
	./configure --prefix=/usr --disable-dependency-tracking --disable-bash-completion --disable-checks --disable-werror && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .dbus-glib-done

download-mate-session: .mate-session-obtained
.mate-session-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O mate-session-manager-$(MATE_SESSION_VER).tar.xz $(MATE_SESSION_URL) && tar xf mate-session-manager-$(MATE_SESSION_VER).tar.xz
	touch .mate-session-obtained

mate-session: download-mate-session dbus-glib mate-desktop .mate-session-done
.mate-session-done:
	sudo pacman -Sy --noconfirm dbus-glib || true
	cd $(MATE_SESSION_PATH) && \
	sed -i 's/noinst_PROGRAMS =.*/noinst_PROGRAMS =/' mate-session/Makefile.in && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include" LDFLAGS="-L$(STAGING_PATH)/usr/lib -lpango-1.0 -lpangoft2-1.0" \
	./configure --prefix=/usr --disable-dependency-tracking --disable-upower --disable-systemd && \
	sed -i 's/SUBDIRS =.*/SUBDIRS = po mate-submodules mate-session capplet data/' Makefile && \
	sed -i '407,415s/^/#/' Makefile && \
	$(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .mate-session-done

# VTE
VTE_URL = https://github.com/GNOME/vte/archive/refs/tags/0.68.0.tar.gz
VTE_VER = 0.68.0
VTE_PATH = $(SRC_PATH)/vte-$(VTE_VER)

download-vte: .vte-obtained
.vte-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O vte-$(VTE_VER).tar.gz $(VTE_URL) && tar xf vte-$(VTE_VER).tar.gz
	touch .vte-obtained

vte: download-vte .vte-done
.vte-done:
	cd $(VTE_PATH) && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include" LDFLAGS="-L$(STAGING_PATH)/usr/lib" \
	meson setup build --prefix=/usr --native-file $(SRC_PATH)/cross_file.txt --buildtype=release -Dgir=false -Dgnutls=false -Dicu=false -D_systemd=false -Dvapi=false -Dglade=false -Dgtk3=true -Dgtk4=false && \
	ninja -C build && DESTDIR=$(STAGING_PATH) ninja -C build install
	touch .vte-done

download-mate-terminal: .mate-terminal-obtained
.mate-terminal-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O mate-terminal-$(MATE_TERMINAL_VER).tar.xz $(MATE_TERMINAL_URL) && tar xf mate-terminal-$(MATE_TERMINAL_VER).tar.xz
	touch .mate-terminal-obtained

mate-terminal: download-mate-terminal vte mate-desktop .mate-terminal-done
.mate-terminal-done:
	cd $(MATE_TERMINAL_PATH) && \
	sed -i 's/noinst_PROGRAMS =.*/noinst_PROGRAMS =/' src/Makefile.in 2>/dev/null || true && \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include -I$(STAGING_PATH)/usr/include/vte-2.91" LDFLAGS="-L$(STAGING_PATH)/usr/lib -lpango-1.0 -lpangoft2-1.0" \
	ITSTOOL=true ./configure --prefix=/usr --disable-dependency-tracking && \
	$(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .mate-terminal-done

.PHONY: mate-iso
mate-iso: mate-common mate-desktop libmatekbd mate-menus mate-panel mate-session mate-terminal vte dbus-glib
	mkdir -p $(ISO_STAGING_PATH)/boot/grub
	mkdir -p $(STAGING_PATH)/etc/labwc
	echo 'nm-applet &' > $(STAGING_PATH)/etc/labwc/autostart
	echo 'mate-panel &' >> $(STAGING_PATH)/etc/labwc/autostart
	make -f arkanas/07_iso.mk initramfs || true
	cp src/linux-6.17.6/arch/x86/boot/bzImage $(ISO_STAGING_PATH)/boot/vmlinuz 2>/dev/null || true
	mksquashfs $(STAGING_PATH) $(ISO_STAGING_PATH)/boot/rootfs.sfs -comp zstd -Xcompression-level 15 -b 1M -noappend || true
	echo 'set timeout=5' > $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo 'set default=0' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo 'menuentry "arkanaOS" {' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo '    linux /boot/vmlinuz' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo '    initrd /boot/initramfs.img' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	echo '}' >> $(ISO_STAGING_PATH)/boot/grub/grub.cfg
	grub-mkrescue -o $(OUTPUT_PATH)/arkana-mate.iso $(ISO_STAGING_PATH) -- -volid "ARKANA_MATE"
