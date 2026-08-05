# Enable multi-threaded Bash operation
SHELL = bash
THREADS = $(shell nproc)

# Paths used in the build
SRC_PATH = $(shell realpath ./src)
STAGING_PATH = $(shell realpath ./staging)

# Alsa-lib (sound library; required by spice-vdagent)
# URL: https://www.alsa-project.org/files/pub/lib/
ALSA_LIB_URL = https://www.alsa-project.org/files/pub/lib/alsa-lib-1.2.14.tar.bz2
ALSA_LIB_VER = 1.2.14
ALSA_LIB_PATH = $(SRC_PATH)/alsa-lib-$(ALSA_LIB_VER)

# Open VM Tools (VMware guest integration: vmtoolsd, hgfs, clipboard, time sync)
# URL: https://github.com/vmware/open-vm-tools
OPEN_VM_TOOLS_URL = https://github.com/vmware/open-vm-tools/archive/refs/tags/stable-13.1.0.tar.gz
OPEN_VM_TOOLS_VER = 13.1.0
OPEN_VM_TOOLS_PATH = $(SRC_PATH)/open-vm-tools-stable-$(OPEN_VM_TOOLS_VER)

# Spice Protocol (headers for SPICE guest agent)
# URL: https://www.spice-space.org/download/releases/spice-protocol
SPICE_PROTOCOL_URL = https://www.spice-space.org/download/releases/spice-protocol-0.14.5.tar.xz
SPICE_PROTOCOL_VER = 0.14.5
SPICE_PROTOCOL_PATH = $(SRC_PATH)/spice-protocol-$(SPICE_PROTOCOL_VER)

# Spice VD Agent (QEMU SPICE display agent: clipboard sharing, file transfer)
# URL: https://gitlab.com/spice/linux/vd_agent/-/tags
SPICE_VDAGENT_URL = https://gitlab.com/spice/linux/vd_agent/-/archive/spice-vdagent-0.22.1/vd_agent-spice-vdagent-0.22.1.tar.gz
SPICE_VDAGENT_VER = 0.22.1
SPICE_VDAGENT_PATH = $(SRC_PATH)/vd_agent-spice-vdagent-$(SPICE_VDAGENT_VER)

# Targets
all: alsa-lib open-vm-tools spice-vdagent

# ---------------------------------------------------------------------------
# ALSA-lib
# Required by spice-vdagent for audio passthrough support.
# ---------------------------------------------------------------------------
download-alsa-lib: .alsa-lib-obtained
.alsa-lib-obtained:
	cd $(SRC_PATH) && wget -O alsa-lib-$(ALSA_LIB_VER).tar.bz2 $(ALSA_LIB_URL) && tar xf alsa-lib-$(ALSA_LIB_VER).tar.bz2
	touch .alsa-lib-obtained

alsa-lib: download-alsa-lib .alsa-lib-done
.alsa-lib-done:
	cd $(ALSA_LIB_PATH) && ./configure --prefix=/usr --disable-static && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .alsa-lib-done

# ---------------------------------------------------------------------------
# Open VM Tools
# Provides vmtoolsd (daemon), vmware-hgfs-fuse (host-guest file sharing),
# and plugins for clipboard, time sync, and memory balloon on VMware hosts.
# Built without DRM/GTK/VGAuth for minimal headless live-ISO footprint.
# ---------------------------------------------------------------------------
download-open-vm-tools: .open-vm-tools-obtained
.open-vm-tools-obtained:
	cd $(SRC_PATH) && wget -O open-vm-tools-stable-$(OPEN_VM_TOOLS_VER).tar.gz $(OPEN_VM_TOOLS_URL) && tar xf open-vm-tools-stable-$(OPEN_VM_TOOLS_VER).tar.gz
	touch .open-vm-tools-obtained

open-vm-tools: download-open-vm-tools .open-vm-tools-done
.open-vm-tools-done:
	cd $(OPEN_VM_TOOLS_PATH)/open-vm-tools && \
	autoreconf -fi && \
	PATH="$(STAGING_PATH)/usr/bin:$$PATH" \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include" \
	LDFLAGS="-L$(STAGING_PATH)/usr/lib" \
	./configure --prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--without-kernel-modules \
		--without-xml-security \
		--without-xmlsec1 \
		--without-gtk3 \
		--without-gtk4 \
		--without-dnet \
		--without-drm \
		--without-icu \
		--disable-vgauth \
		--disable-deploypkg && \
	$(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	mkdir -p $(STAGING_PATH)/etc/vmware-tools
	echo '[guestinfo]' > $(STAGING_PATH)/etc/vmware-tools/tools.conf
	echo 'poll-interrupt-sec = 10' >> $(STAGING_PATH)/etc/vmware-tools/tools.conf
	echo '[guestCopy]' >> $(STAGING_PATH)/etc/vmware-tools/tools.conf
	echo 'enabled = true' >> $(STAGING_PATH)/etc/vmware-tools/tools.conf
	mkdir -p $(STAGING_PATH)/etc/systemd/system/multi-user.target.wants
	ln -sf /usr/lib/systemd/system/vmtoolsd.service $(STAGING_PATH)/etc/systemd/system/multi-user.target.wants/vmtoolsd.service || true
	touch .open-vm-tools-done

# ---------------------------------------------------------------------------
# Spice Protocol (headers needed by spice-vdagent)
# ---------------------------------------------------------------------------
download-spice-protocol: .spice-protocol-obtained
.spice-protocol-obtained:
	cd $(SRC_PATH) && wget -O spice-protocol-$(SPICE_PROTOCOL_VER).tar.xz $(SPICE_PROTOCOL_URL) && tar xf spice-protocol-$(SPICE_PROTOCOL_VER).tar.xz
	touch .spice-protocol-obtained

spice-protocol: download-spice-protocol .spice-protocol-done
.spice-protocol-done:
	mkdir -p $(SPICE_PROTOCOL_PATH)/build && cd $(SPICE_PROTOCOL_PATH)/build && \
	meson setup --prefix=/usr --buildtype=release .. && \
	ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .spice-protocol-done

# ---------------------------------------------------------------------------
# Spice VD Agent
# Provides spice-vdagentd (daemon) for clipboard sharing and file transfer
# between QEMU/KVM host and guest via the SPICE virtio-serial channel.
# Requires: spice-protocol, alsa-lib, glib, libdrm, dbus, systemd, X11
# ---------------------------------------------------------------------------
download-spice-vdagent: .spice-vdagent-obtained
.spice-vdagent-obtained:
	cd $(SRC_PATH) && wget -O vd_agent-spice-vdagent-$(SPICE_VDAGENT_VER).tar.gz $(SPICE_VDAGENT_URL) && tar xf vd_agent-spice-vdagent-$(SPICE_VDAGENT_VER).tar.gz
	touch .spice-vdagent-obtained

spice-vdagent: download-spice-vdagent spice-protocol alsa-lib .spice-vdagent-done
.spice-vdagent-done:
	cd $(SPICE_VDAGENT_PATH) && \
	PATH="$(STAGING_PATH)/usr/bin:$$PATH" \
	PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
	CFLAGS="-I$(STAGING_PATH)/usr/include" \
	LDFLAGS="-L$(STAGING_PATH)/usr/lib" \
	./autogen.sh && \
	./configure --prefix=/usr \
		--sysconfdir=/etc \
		PKG_CONFIG_PATH="$(STAGING_PATH)/usr/lib/pkgconfig:$(STAGING_PATH)/usr/share/pkgconfig" \
		CFLAGS="-I$(STAGING_PATH)/usr/include" \
		LDFLAGS="-L$(STAGING_PATH)/usr/lib" && \
	$(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	mkdir -p $(STAGING_PATH)/etc/systemd/system/multi-user.target.wants
	ln -sf /usr/lib/systemd/system/spice-vdagentd.service $(STAGING_PATH)/etc/systemd/system/multi-user.target.wants/spice-vdagentd.service || true
	touch .spice-vdagent-done
