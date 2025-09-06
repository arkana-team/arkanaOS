# Enable multi-threaded Bash operation
SHELL = bash
THREADS = $(shell nproc)

# Paths used in the build
SRC_PATH = $(shell realpath ./src)
STAGING_PATH = $(shell realpath ./staging)
OUTPUT_PATH = $(shell realpath ./output)

# Less
# URL: https://ftpmirror.gnu.org/gnu/less/ (w/o instructions)
LESS_URL = https://ftpmirror.gnu.org/gnu/less/less-679.tar.gz
LESS_VER = 679
LESS_PATH = $(SRC_PATH)/less-$(LESS_VER)

# Procps-NG (free, ps, etc.)
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/procps-ng.html
PROCPS_NG_URL = https://gitlab.com/procps-ng/procps/-/archive/v4.0.5/procps-v4.0.5.tar.gz
PROCPS_NG_VER = 4.0.5
PROCPS_NG_PATH = $(SRC_PATH)/procps-v$(PROCPS_NG_VER)

# Iproute2
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/iproute2.html
IPROUTE2_URL = https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-6.16.0.tar.gz
IPROUTE2_VER = 6.16.0
IPROUTE2_PATH = $(SRC_PATH)/iproute2-$(IPROUTE2_VER)

# Iputils (to contact the internet, technically Curl exists at this point too, but this is simpler)
# URL: https://github.com/iputils/iputils (w/o instructions)
IPUTILS_URL = https://github.com/iputils/iputils/releases/download/20250605/iputils-20250605.tar.gz
IPUTILS_VER = 20250605
IPUTILS_PATH = $(SRC_PATH)/iputils-$(IPUTILS_VER)

# Iptables (libxtables only, not using the firewall part yet.)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/iptables.html
IPTABLES_URL = https://www.netfilter.org/projects/iptables/files/iptables-1.8.11.tar.xz
IPTABLES_VER = 1.8.11
IPTABLES_PATH = $(SRC_PATH)/iptables-$(IPTABLES_VER)

# NetworkManager (you have to connect to the internet somehow, do you?)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/basicnet/networkmanager.html
NETWORKMANAGER_URL = https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/releases/1.54.0/downloads/NetworkManager-1.54.0.tar.xz
NETWORKMANAGER_VER = 1.54.0
NETWORKMANAGER_PATH = $(SRC_PATH)/NetworkManager-$(NETWORKMANAGER_VER)

# Libbpf
# URL: https://github.com/libbpf/libbpf (w/o instructions)
# Referred to by https://www.linuxfromscratch.org/lfs/view/systemd/appendices/dependencies.html
LIBBPF_URL = https://github.com/libbpf/libbpf/archive/refs/tags/v1.6.2.tar.gz
LIBBPF_VER = 1.6.2
LIBBPF_PATH = $(SRC_PATH)/libbpf-$(LIBBPF_VER)

# Libmnl
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/basicnet/libmnl.html
LIBMNL_URL = https://netfilter.org/projects/libmnl/files/libmnl-1.0.5.tar.bz2
LIBMNL_VER = 1.0.5
LIBMNL_PATH = $(SRC_PATH)/libmnl-$(LIBMNL_VER)

# Libidn2
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libidn2.html
LIBIDN2_URL = https://ftpmirror.gnu.org/gnu/libidn/libidn2-2.3.8.tar.gz
LIBIDN2_VER = 2.3.8
LIBIDN2_PATH = $(SRC_PATH)/libidn2-$(LIBIDN2_VER)

# Libunistring
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libunistring.html
LIBUNISTRING_URL = https://ftpmirror.gnu.org/gnu/libunistring/libunistring-1.3.tar.gz
LIBUNISTRING_VER = 1.3
LIBUNISTRING_PATH = $(SRC_PATH)/libunistring-$(LIBUNISTRING_VER)

# Libnfnetlink
# URL: https://www.netfilter.org/pub/libnfnetlink/ (w/o instructions)
LIBNFNETLINK_URL = https://www.netfilter.org/pub/libnfnetlink/libnfnetlink-1.0.2.tar.bz2
LIBNFNETLINK_VER = 1.0.2
LIBNFNETLINK_PATH = $(SRC_PATH)/libnfnetlink-$(LIBNFNETLINK_VER)

# Libpsl5.0.
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/basicnet/libpsl.html
LIBPSL_URL = https://github.com/rockdaboot/libpsl/releases/download/0.21.5/libpsl-0.21.5.tar.gz
LIBPSL_VER = 0.21.5
LIBPSL_PATH = $(SRC_PATH)/libpsl-$(LIBPSL_VER)

# Newt
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/newt.html
NEWT_URL = https://releases.pagure.org/newt/newt-0.52.25.tar.gz
NEWT_VER = 0.52.25
NEWT_PATH = $(SRC_PATH)/newt-$(NEWT_VER)

# Libndp
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/basicnet/libndp.html
LIBNDP_URL = http://libndp.org/files/libndp-1.9.tar.gz
LIBNDP_VER = 1.9
LIBNDP_PATH = $(SRC_PATH)/libndp-$(LIBNDP_VER)

# Gnutls
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/gnutls.html
GNUTLS_URL = https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.10.tar.xz
GNUTLS_VER = 3.8.10
GNUTLS_PATH = $(SRC_PATH)/gnutls-$(GNUTLS_VER)

# Nettle
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/nettle.html
NETTLE_URL = https://ftpmirror.gnu.org/gnu/nettle/nettle-3.10.2.tar.gz
NETTLE_VER = 3.10.2
NETTLE_PATH = $(SRC_PATH)/nettle-$(NETTLE_VER)

# Libtasn1
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libtasn1.html
LIBTASN1_URL = https://ftpmirror.gnu.org/gnu/libtasn1/libtasn1-4.20.0.tar.gz
LIBTASN1_VER = 4.20.0
LIBTASN1_PATH = $(SRC_PATH)/libtasn1-$(LIBTASN1_VER)

# Libslang
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/slang.html
SLANG_URL = https://www.jedsoft.org/releases/slang/slang-2.3.3.tar.bz2
SLANG_VER = 2.3.3
SLANG_PATH = $(SRC_PATH)/slang-$(SLANG_VER)

# P11-kit
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/p11-kit.html
P11_KIT_URL = https://github.com/p11-glue/p11-kit/releases/download/0.25.5/p11-kit-0.25.5.tar.xz
P11_KIT_VER = 0.25.5
P11_KIT_PATH = $(SRC_PATH)/p11-kit-$(P11_KIT_VER)

# Curl (because we needed libcurl but it also extends Arkana)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/basicnet/curl.html
CURL_URL = https://curl.se/download/curl-8.15.0.tar.xz
CURL_VER = 8.15.0
CURL_PATH = $(SRC_PATH)/curl-$(CURL_VER)

# Nghttp2
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/basicnet/nghttp2.html
NGHTTP2_URL = https://github.com/nghttp2/nghttp2/releases/download/v1.66.0/nghttp2-1.66.0.tar.xz
NGHTTP2_VER = 1.66.0
NGHTTP2_PATH = $(SRC_PATH)/nghttp2-$(NGHTTP2_VER)

# Jansson
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/jansson.html
JANSSON_URL = https://github.com/akheron/jansson/releases/download/v2.14.1/jansson-2.14.1.tar.bz2
JANSSON_VER = 2.14.1
JANSSON_PATH = $(SRC_PATH)/jansson-$(JANSSON_VER)

# Flex
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/flex.html
FLEX_URL = https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz
FLEX_VER = 2.6.4
FLEX_PATH = $(SRC_PATH)/flex-$(FLEX_VER)

# Libnvme (this may not be needed on all machines)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libnvme.html
LIBNVME_URL = https://github.com/linux-nvme/libnvme/archive/v1.15/libnvme-1.15.tar.gz
LIBNVME_VER = 1.15
LIBNVME_PATH = $(SRC_PATH)/libnvme-$(LIBNVME_VER)

# Findutils
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter06/findutils.html
FINDUTILS_URL = https://ftpmirror.gnu.org/gnu/findutils/findutils-4.10.0.tar.xz
FINDUTILS_VER = 4.10.0
FINDUTILS_PATH = $(SRC_PATH)/findutils-$(FINDUTILS_VER)

# Diffutils
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/diffutils.html
DIFFUTILS_URL = https://ftpmirror.gnu.org/gnu/diffutils/diffutils-3.12.tar.gz
DIFFUTILS_VER = 3.12
DIFFUTILS_PATH = $(SRC_PATH)/diffutils-$(DIFFUTILS_VER)

# Sed
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter06/sed.html
SED_URL = https://ftpmirror.gnu.org/gnu/sed/sed-4.9.tar.gz
SED_VER = 4.9
SED_PATH = $(SRC_PATH)/sed-$(SED_VER)

# Grep
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter06/grep.html
GREP_URL = https://ftpmirror.gnu.org/gnu/grep/grep-3.12.tar.gz
GREP_VER = 3.12
GREP_PATH = $(SRC_PATH)/grep-$(GREP_VER)

# Gawk
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter06/gawk.html
GAWK_URL = https://ftpmirror.gnu.org/gnu/gawk/gawk-5.3.2.tar.gz
GAWK_VER = 5.3.2
GAWK_PATH = $(SRC_PATH)/gawk-$(GAWK_VER)

# MPFR
# URL: https://www.linuxfromscratch.org/~thomas/multilib/chapter08/mpfr.html (ignore multilib instructions)
MPFR_URL = https://ftpmirror.gnu.org/gnu/mpfr/mpfr-4.2.2.tar.gz
MPFR_VER = 4.2.2
MPFR_PATH = $(SRC_PATH)/mpfr-$(MPFR_VER)

# Nano
# Why is this in BLFS?
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/nano.html
NANO_URL = https://www.nano-editor.org/dist/v8/nano-8.6.tar.xz
NANO_VER = 8.6
NANO_PATH = $(SRC_PATH)/nano-$(NANO_VER)

# The ironic tool
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter06/tar.html
TAR_URL = https://ftpmirror.gnu.org/gnu/tar/tar-1.35.tar.gz
TAR_VER = 1.35
TAR_PATH = $(SRC_PATH)/tar-$(TAR_VER)

# The Arch user tool
# URL: https://github.com/fastfetch-cli/fastfetch (w/o instructions)
FASTFETCH_URL = https://github.com/fastfetch-cli/fastfetch/archive/refs/tags/2.50.2.tar.gz
FASTFETCH_VER = 2.50.2
FASTFETCH_PATH = $(SRC_PATH)/fastfetch-$(FASTFETCH_VER)

# Sudo
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/sudo.html
SUDO_URL = https://www.sudo.ws/dist/sudo-1.9.17p2.tar.gz
SUDO_VER = 1.9.17p2
SUDO_PATH = $(SRC_PATH)/sudo-$(SUDO_VER)

# Vim (rolling release)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/vim.html
VIM_URL = https://github.com/vim/vim/archive/v9.1.1629/vim-9.1.1629.tar.gz
VIM_VER = 9.1.1629
VIM_PATH = $(SRC_PATH)/vim-$(VIM_VER)

# Rsync
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/basicnet/rsync.html
RSYNC_URL = https://www.samba.org/ftp/rsync/src/rsync-3.4.1.tar.gz
RSYNC_VER = 3.4.1
RSYNC_PATH = $(SRC_PATH)/rsync-$(RSYNC_VER)

# Dosfstools
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/dosfstools.html
DOSFSTOOLS_URL = https://github.com/dosfstools/dosfstools/releases/download/v4.2/dosfstools-4.2.tar.gz
DOSFSTOOLS_VER = 4.2
DOSFSTOOLS_PATH = $(SRC_PATH)/dosfstools-$(DOSFSTOOLS_VER)

# TZDB
# URL: https://data.iana.org/time-zones/ (w/o instructions)
TZDB_URL = https://data.iana.org/time-zones/tzdb-latest.tar.lz
TZDB_VER = 2025b
TZDB_PATH = $(SRC_PATH)/tzdb-$(TZDB_VER)

# Parted
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/parted.html
PARTED_URL = https://ftpmirror.gnu.org/gnu/parted/parted-3.6.tar.xz
PARTED_VER = 3.6
PARTED_PATH = $(SRC_PATH)/parted-$(PARTED_VER)

# Make-CA (SSL support)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/make-ca.html
MAKE_CA_URL = https://github.com/lfs-book/make-ca/archive/v1.16.1/make-ca-1.16.1.tar.gz
MAKE_CA_VER = 1.16.1
MAKE_CA_PATH = $(SRC_PATH)/make-ca-$(MAKE_CA_VER)

# Targets
all: less procps-ng iproute2 iputils iptables networkmanager libbpf libmnl libidn2 libunistring libnfnetlink libpsl newt libndp gnutls nettle libtasn1 p11-kit slang curl nghttp2 jansson flex libnvme fastfetch findutils sed grep diffutils gawk mpfr nano tar sudo vim rsync dosfstools tzdb parted make-ca

# Download less
download-less: .less-obtained
.less-obtained:
	cd $(SRC_PATH) && wget -O less-$(LESS_VER).tar.gz $(LESS_URL) && tar xf less-$(LESS_VER).tar.gz
	touch .less-obtained

# Compile less
less: download-less .less-done
.less-done:
	cd $(LESS_PATH) && ./configure --prefix=/usr --sysconfdir=/etc && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .less-done

# Download procps-ng
download-procps-ng: .procps-ng-obtained
.procps-ng-obtained:
	cd $(SRC_PATH) && wget -O procps-ng-$(PROCPS_NG_VER).tar.gz $(PROCPS_NG_URL) && tar xf procps-ng-$(PROCPS_NG_VER).tar.gz
	touch .procps-ng-obtained

# Compile procps-ng
procps-ng: download-procps-ng .procps-ng-done
.procps-ng-done:
	cd $(PROCPS_NG_PATH) && ./autogen.sh && ./configure --prefix=/usr --docdir=/usr/share/doc/procps-ng-$(PROCPS_NG_VER) --disable-kill \
	--enable-watch8bit && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .procps-ng-done

# Download iproute2
download-iproute2: .iproute2-obtained
.iproute2-obtained:
	cd $(SRC_PATH) && wget -O iproute2-$(IPROUTE2_VER).tar.gz $(IPROUTE2_URL) && tar xf iproute2-$(IPROUTE2_VER).tar.gz
	touch .iproute2-obtained

# Compile iproute2
iproute2: download-iproute2 .iproute2-done
.iproute2-done:
	cd $(IPROUTE2_PATH) && sed -i /ARPD/d Makefile && rm -f man/man8/arpd.8 && $(MAKE) NETNS_RUN_DIR=/run/netns && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .iproute2-done

# Download iputils
download-iputils: .iputils-obtained
.iputils-obtained:
	cd $(SRC_PATH) && wget -O iputils-$(IPUTILS_VER).tar.gz $(IPUTILS_URL) && tar xf iputils-$(IPUTILS_VER).tar.gz
	touch .iputils-obtained

# Compile iputils
iputils: download-iputils .iputils-done
.iputils-done:
	mkdir -p $(IPUTILS_PATH)/build && cd $(IPUTILS_PATH)/build && meson setup --prefix=/usr --buildtype=release .. && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .iputils-done

# Download NetworkManager
download-networkmanager: .networkmanager-obtained
.networkmanager-obtained:
	cd $(SRC_PATH) && wget -O networkmanager-$(NETWORKMANAGER_VER).tar.xz $(NETWORKMANAGER_URL) && tar xf networkmanager-$(NETWORKMANAGER_VER).tar.xz
	touch .networkmanager-obtained

# Compile NetworkManager
networkmanager: download-networkmanager .networkmanager-done
.networkmanager-done:
	mkdir -p $(NETWORKMANAGER_PATH)/build && cd $(NETWORKMANAGER_PATH)/build && meson setup .. --prefix=/usr --buildtype=release -D nmtui=true -D ovs=false -D ppp=false -D selinux=false \
	-D qt=false -D session_tracking=systemd -D modem_manager=false -D introspection=false -D crypto=gnutls && ninja && DESTDIR=$(STAGING_PATH) ninja install
	echo "[main]" > $(STAGING_PATH)/etc/NetworkManager/NetworkManager.conf
	echo "plugins=keyfile" >> $(STAGING_PATH)/etc/NetworkManager/NetworkManager.conf && mkdir -p $(STAGING_PATH)/etc/systemd/system/multi-user.target.wants
	ln -sf /usr/lib/systemd/system/NetworkManager.service $(STAGING_PATH)/etc/systemd/system/multi-user.target.wants/NetworkManager.service
	touch .networkmanager-done

# Download libbpf
download-libbpf: .libbpf-obtained
.libbpf-obtained:
	cd $(SRC_PATH) && wget -O libbpf-$(LIBBPF_VER).tar.gz $(LIBBPF_URL) && tar xf libbpf-$(LIBBPF_VER).tar.gz
	touch .libbpf-obtained

# Compile libbpf
libbpf: download-libbpf .libbpf-done
.libbpf-done:
	cd $(LIBBPF_PATH)/src && $(MAKE) -j$(THREADS) && $(MAKE) PREFIX=$(STAGING_PATH)/usr install
	touch .libbpf-done

# Download libmnl
download-libmnl: .libmnl-obtained
.libmnl-obtained:
	cd $(SRC_PATH) && wget -O libmnl-$(LIBMNL_VER).tar.gz $(LIBMNL_URL) && tar xf libmnl-$(LIBMNL_VER).tar.gz
	touch .libmnl-obtained

# Compile libmnl
libmnl: download-libmnl .libmnl-done
.libmnl-done:
	cd $(LIBMNL_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libmnl-done

# Download libidn2
download-libidn2: .libidn2-obtained
.libidn2-obtained:
	cd $(SRC_PATH) && wget -O libidn2-$(LIBIDN2_VER).tar.gz $(LIBIDN2_URL) && tar xf libidn2-$(LIBIDN2_VER).tar.gz
	touch .libidn2-obtained

# Compile libidn2
libidn2: download-libidn2 .libidn2-done
.libidn2-done:
	cd $(LIBIDN2_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libidn2-done

# Download libunistring
download-libunistring: .libunistring-obtained
.libunistring-obtained:
	cd $(SRC_PATH) && wget -O libunistring-$(LIBUNISTRING_VER).tar.gz $(LIBUNISTRING_URL) && tar xf libunistring-$(LIBUNISTRING_VER).tar.gz
	touch .libunistring-obtained

# Compile libunistring
libunistring: download-libunistring .libunistring-done
.libunistring-done:
	cd $(LIBUNISTRING_PATH) && ./configure --prefix=/usr --docdir=/usr/share/doc/libunistring-$(LIBUNISTRING_VER) && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libunistring-done

# Download libnfnetlink
download-libnfnetlink: .libnfnetlink-obtained
.libnfnetlink-obtained:
	cd $(SRC_PATH) && wget -O libnfnetlink-$(LIBNFNETLINK_VER).tar.bz2 $(LIBNFNETLINK_URL) && tar xf libnfnetlink-$(LIBNFNETLINK_VER).tar.bz2
	touch .libnfnetlink-obtained

# Compile libnfnetlink
libnfnetlink: download-libnfnetlink .libnfnetlink-done
.libnfnetlink-done:
	cd $(LIBNFNETLINK_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libnfnetlink-done

# Download libpsl
download-libpsl: .libpsl-obtained
.libpsl-obtained:
	cd $(SRC_PATH) && wget -O libpsl-$(LIBPSL_VER).tar.gz $(LIBPSL_URL) && tar xf libpsl-$(LIBPSL_VER).tar.gz
	touch .libpsl-obtained

# Compile libpsl
libpsl: download-libpsl .libpsl-done
.libpsl-done:
	mkdir -p $(LIBPSL_PATH)/build && cd $(LIBPSL_PATH)/build && meson setup --prefix=/usr --buildtype=release && ninja && DESTDIR=$(STAGING_PATH) ninja install
	touch .libpsl-done

# Download newt
download-newt: .newt-obtained
.newt-obtained:
	cd $(SRC_PATH) && wget -O newt-$(NEWT_VER).tar.gz $(NEWT_URL) && tar xf newt-$(NEWT_VER).tar.gz
	touch .newt-obtained

# Compile newt
newt: download-newt .newt-done
.newt-done:
	cd $(NEWT_PATH) && ./configure --prefix=/usr --with-gpm-support --with-python=python3.13 && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .newt-done

# Download libndp
download-libndp: .libndp-obtained
.libndp-obtained:
	cd $(SRC_PATH) && wget -O libndp-$(LIBNDP_VER).tar.gz $(LIBNDP_URL) && tar xf libndp-$(LIBNDP_VER).tar.gz
	touch .libndp-obtained

# Compile libndp
libndp: download-libndp .libndp-done
.libndp-done:
	cd $(LIBNDP_PATH) && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libndp-done

# Download GnuTLS
download-gnutls: .gnutls-obtained
.gnutls-obtained:
	cd $(SRC_PATH) && wget -O gnutls-$(GNUTLS_VER).tar.xz $(GNUTLS_URL) && tar xf gnutls-$(GNUTLS_VER).tar.xz
	touch .gnutls-obtained

# Compile GnuTLS
gnutls: download-gnutls .gnutls-done
.gnutls-done:
	cd $(GNUTLS_PATH) && ./configure --prefix=/usr --docdir=/usr/share/doc/gnutls-$(GNUTLS_VER) --with-default-trust-store-pkcs11="pkcs11:" && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .gnutls-done

# Download nettle
download-nettle: .nettle-obtained
.nettle-obtained:
	cd $(SRC_PATH) && wget -O nettle-$(NETTLE_VER).tar.gz $(NETTLE_URL) && tar xf nettle-$(NETTLE_VER).tar.gz
	touch .nettle-obtained

# Compile nettle
nettle: download-nettle .nettle-done
.nettle-done:
	cd $(NETTLE_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && chmod -v 755 $(STAGING_PATH)/usr/lib/lib{hogweed,nettle}.so
	touch .nettle-done

# Download libtasn1
download-libtasn1: .libtasn1-obtained
.libtasn1-obtained:
	cd $(SRC_PATH) && wget -O libtasn1-$(LIBTASN1_VER).tar.gz $(LIBTASN1_URL) && tar xf libtasn1-$(LIBTASN1_VER).tar.gz
	touch .libtasn1-obtained

# Compile libtasn1
libtasn1: download-libtasn1 .libtasn1-done
.libtasn1-done:
	cd $(LIBTASN1_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libtasn1-done

# Download P11-kit
download-p11-kit: .p11-kit-obtained
.p11-kit-obtained:
	cd $(SRC_PATH) && wget -O p11-kit-$(P11_KIT_VER).tar.xz $(P11_KIT_URL) && tar xf p11-kit-$(P11_KIT_VER).tar.xz
	touch .p11-kit-obtained

# Compile P11-kit
p11-kit: download-p11-kit .p11-kit-done
.p11-kit-done:
	cd $(P11_KIT_PATH) && sed '20,$$ d' -i trust/trust-extract-compat && echo "/usr/lib/make-ca/copy-trust-modifications" >> trust/trust-extract-compat && \
	echo "/usr/sbin/make-ca -r" >> trust/trust-extract-compat && mkdir -p $(P11_KIT_PATH)/build && cd $(P11_KIT_PATH)/build && meson setup .. --prefix=/usr --buildtype=release -D trust_paths=/etc/pki/anchors && \
	ninja && DESTDIR=$(STAGING_PATH) ninja install && ln -sf /usr/lib/p11-kit/trust-extract-compat $(STAGING_PATH)/usr/bin/update-ca-certificates && ln -sf /usr/lib/pkcs11/p11-kit-trust.so \
	$(STAGING_PATH)/usr/lib/libnssckbi.so
	touch .p11-kit-done

# Download slang
download-slang: .slang-obtained
.slang-obtained:
	cd $(SRC_PATH) && wget -O slang-$(SLANG_VER).tar.bz2 $(SLANG_URL) && tar xf slang-$(SLANG_VER).tar.bz2
	touch .slang-obtained

# Compile slang
slang: download-slang .slang-done
.slang-done:
	cd $(SLANG_PATH) && ./configure --prefix=/usr --sysconfdir=/etc --with-readline=gnu && $(MAKE) RPATH= && $(MAKE) DESTDIR=$(STAGING_PATH) RPATH= install
	touch .slang-done

# Download curl
download-curl: .curl-obtained
.curl-obtained:
	cd $(SRC_PATH) && wget -O curl-$(CURL_VER).tar.xz $(CURL_URL) && tar xf curl-$(CURL_VER).tar.xz
	touch .curl-obtained

# Compile curl
curl: download-curl .curl-done
.curl-done:
	cd $(CURL_PATH) && ./configure --prefix=/usr --enable-versioned-symbols --with-gssapi --with-openssl --with-ca-path=/etc/ssl/certs && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .curl-done

# Download nghttp2
download-nghttp2: .nghttp2-obtained
.nghttp2-obtained:
	cd $(SRC_PATH) && wget -O nghttp2-$(NGHTTP2_VER).tar.xz $(NGHTTP2_URL) && tar xf nghttp2-$(NGHTTP2_VER).tar.xz
	touch .nghttp2-obtained

# Compile nghttp2
nghttp2: download-nghttp2 .nghttp2-done
.nghttp2-done:
	cd $(NGHTTP2_PATH) && ./configure --prefix=/usr --enable-lib-only --docdir=/usr/share/doc/nghttp2-$(NGHTTP_VER) && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .nghttp2-done

# Download jansson
download-jansson: .jansson-obtained
.jansson-obtained:
	cd $(SRC_PATH) && wget -O jansson-$(JANSSON_VER).tar.bz2 $(JANSSON_URL) && tar xf jansson-$(JANSSON_VER).tar.bz2
	touch .jansson-obtained

# Compile jansson
jansson: download-jansson .jansson-done
.jansson-done:
	cd $(JANSSON_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .jansson-done

# Download iptables
download-iptables: .iptables-obtained
.iptables-obtained:
	cd $(SRC_PATH) && wget -O iptables-$(IPTABLES_VER).tar.xz $(IPTABLES_URL) && tar xf iptables-$(IPTABLES_VER).tar.xz
	touch .iptables-obtained

# Compile iptables
iptables: download-iptables .iptables-done
.iptables-done:
	cd $(IPTABLES_PATH) && ./configure --prefix=/usr --disable-nftables --enable-libipq && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .iptables-done

# Download flex
download-flex: .flex-obtained
.flex-obtained:
	cd $(SRC_PATH) && wget -O flex-$(FLEX_VER).tar.gz $(FLEX_URL) && tar xf flex-$(FLEX_VER).tar.gz
	touch .flex-obtained

# Compile flex
flex: download-flex .flex-done
.flex-done:
	cd $(FLEX_PATH) && ./configure --prefix=/usr --docdir=/usr/share/doc/flex-$(FLEX_VER) && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install && ln -sf flex $(STAGING_PATH)/usr/bin/lex && \
	ln -sf flex.1 $(STAGING_PATH)/usr/share/man/man1/lex.1
	touch .flex-done

# Download the Arch user tool
download-fastfetch: .fastfetch-obtained
.fastfetch-obtained:
	cd $(SRC_PATH) && wget -O fastfetch-$(FASTFETCH_VER).tar.gz $(FASTFETCH_URL) && tar xf fastfetch-$(FASTFETCH_VER).tar.gz
	touch .fastfetch-obtained

# Compile the Arch user tool
fastfetch: download-fastfetch .fastfetch-done
.fastfetch-done:
	mkdir -p $(FASTFETCH_PATH)/build && cd $(FASTFETCH_PATH)/build && cmake .. && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .fastfetch-done

# Download libnvme
download-libnvme: .libnvme-obtained
.libnvme-obtained:
	cd $(SRC_PATH) && wget -O libnvme-$(LIBNVME_VER).tar.gz $(LIBNVME_URL) && tar xf libnvme-$(LIBNVME_VER).tar.gz
	touch .libnvme-obtained

# Compile libnvme
libnvme: download-libnvme .libnvme-done
.libnvme-done:
	mkdir -p $(LIBNVME_PATH)/build && cd $(LIBNVME_PATH)/build && meson setup --prefix=/usr --buildtype=release -D libdbus=auto .. && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install
	touch .libnvme-done

# Download findutils
download-findutils: .findutils-obtained
.findutils-obtained:
	cd $(SRC_PATH) && wget -O findutils-$(FINDUTILS_VER).tar.xz $(FINDUTILS_URL) && tar xf findutils-$(FINDUTILS_VER).tar.xz
	touch .findutils-obtained

# Compile findutils
findutils: download-findutils .findutils-done
.findutils-done:
	cd $(FINDUTILS_PATH) && ./configure --prefix=/usr --localstatedir=/var/lib/locate && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .findutils-done

# Download diffutils
download-diffutils: .diffutils-obtained
.diffutils-obtained:
	cd $(SRC_PATH) && wget -O diffutils-$(DIFFUTILS_VER).tar.gz $(DIFFUTILS_URL) && tar xf diffutils-$(DIFFUTILS_VER).tar.gz
	touch .diffutils-obtained

# Compile diffutils
diffutils: download-diffutils .diffutils-done
.diffutils-done:
	cd $(DIFFUTILS_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .diffutils-done

# Download sed
download-sed: .sed-obtained
.sed-obtained:
	cd $(SRC_PATH) && wget -O sed-$(SED_VER).tar.gz $(SED_URL) && tar xf sed-$(SED_VER).tar.gz
	touch .sed-obtained

# Compile sed
sed: download-sed .sed-done
.sed-done:
	cd $(SED_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .sed-done

# Download grep
download-grep: .grep-obtained
.grep-obtained:
	cd $(SRC_PATH) && wget -O grep-$(GREP_VER).tar.gz $(GREP_URL) && tar xf grep-$(GREP_VER).tar.gz
	touch .grep-obtained

# Compile grep
grep: download-grep .grep-done
.grep-done:
	cd $(GREP_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .grep-done

# Download gawk
download-gawk: .gawk-obtained
.gawk-obtained:
	cd $(SRC_PATH) && wget -O gawk-$(GAWK_VER).tar.gz $(GAWK_URL) && tar xf gawk-$(GAWK_VER).tar.gz
	touch .gawk-obtained

# Compile gawk
gawk: download-gawk .gawk-done
.gawk-done:
	cd $(GAWK_PATH) && sed -i 's/extras//' Makefile.in && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .gawk-done

# Download mpfr
download-mpfr: .mpfr-obtained
.mpfr-obtained:
	cd $(SRC_PATH) && wget -O mpfr-$(MPFR_VER).tar.gz $(MPFR_URL) && tar xf mpfr-$(MPFR_VER).tar.gz
	touch .mpfr-obtained

# Compile mpfr
mpfr: download-mpfr .mpfr-done
.mpfr-done:
	cd $(MPFR_PATH) && ./configure --prefix=/usr --enable-thread-safe --docdir=/usr/share/doc/mpfr-$(MPFR_VER) && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .mpfr-done

# Download nano
download-nano: .nano-obtained
.nano-obtained:
	cd $(SRC_PATH) && wget -O nano-$(NANO_VER).tar.xz $(NANO_URL) && tar xf nano-$(NANO_VER).tar.xz
	touch .nano-obtained

# Compile nano
nano: download-nano .nano-done
.nano-done:
	cd $(NANO_PATH) && ./configure --prefix=/usr --sysconfdir=/etc --enable-utf8 --docdir=/usr/share/doc/nano-$(NANO_VER) && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .nano-done

# Download the ironic tool
download-tar: .tar-obtained
.tar-obtained:
	# Ironic, untarring tar using tar.
	cd $(SRC_PATH) && wget -O tar-$(TAR_VER).tar.gz $(TAR_URL) && tar xf tar-$(TAR_VER).tar.gz
	touch .tar-obtained

# Compile the ironic tool
tar: download-tar .tar-done
.tar-done:
	cd $(TAR_PATH) && FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .tar-done

# Download sudo
download-sudo: .sudo-obtained
.sudo-obtained:
	cd $(SRC_PATH) && wget -O sudo-$(SUDO_VER).tar.gz $(SUDO_URL) && tar xf sudo-$(SUDO_VER).tar.gz
	touch .sudo-obtained

# Compile sudo
sudo: download-sudo .sudo-done
.sudo-done:
	cd $(SUDO_PATH) && ./configure --prefix=/usr --libexecdir=/usr/lib --with-secure-path --with-env-editor --docdir=/usr/share/doc/sudo-$(SUDO_VER) \
	--with-all-insults --with-passprompt="[sudo] password for %p: " && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .sudo-done

# Download vim
download-vim: .vim-obtained
.vim-obtained:
	cd $(SRC_PATH) && wget -O vim-$(VIM_VER).tar.gz $(VIM_URL) && tar xf vim-$(VIM_VER).tar.gz
	touch .vim-obtained

# Compile vim
vim: download-vim .vim-done
.vim-done:
	cd $(VIM_PATH) && echo '#define SYS_VIMRC_FILE  "/etc/vimrc"' >> src/feature.h && ./configure --prefix=/usr --with-features=huge --enable-gui=no --without-x --without-wayland --disable-libsodium --disable-gpm --with-tlib=ncursesw && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && ln -snf ../vim/vim91/doc $(STAGING_PATH)/usr/share/doc/vim-$(VIM_VER)
	touch .vim-done

# Download rsync
download-rsync: .rsync-obtained
.rsync-obtained:
	cd $(SRC_PATH) && wget -O rsync-$(RSYNC_VER).tar.gz $(RSYNC_URL) && tar xf rsync-$(RSYNC_VER).tar.gz
	touch .rsync-obtained

# Compile rsync
rsync: download-rsync .rsync-done
.rsync-done:
	cd $(RSYNC_PATH) && ./configure --prefix=/usr --disable-xxhash --without-included-zlib && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .rsync-done

# Download dosfstools
download-dosfstools: .dosfstools-obtained
.dosfstools-obtained:
	cd $(SRC_PATH) && wget -O dosfstools-$(DOSFSTOOLS_VER).tar.gz $(DOSFSTOOLS_URL) && tar xf dosfstools-$(DOSFSTOOLS_VER).tar.gz
	touch .dosfstools-obtained

# Compile dosfstools
dosfstools: download-dosfstools .dosfstools-done
.dosfstools-done:
	cd $(DOSFSTOOLS_PATH) && ./configure --prefix=/usr --enable-compat-symlinks --mandir=/usr/share/man -docdir=/usr/share/doc/dosfstools-$(DOSFSTOOLS_VER) && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .dosfstools-done

# Download tzdb
download-tzdb: .tzdb-obtained
.tzdb-obtained:
	cd $(SRC_PATH) && wget -O tzdb-$(TZDB_VER).tar.lz $(TZDB_URL) && tar xf tzdb-$(TZDB_VER).tar.lz
	touch .tzdb-obtained

# Compile tzdb
tzdb: download-tzdb .tzdb-done
.tzdb-done:
	cd $(TZDB_PATH) && $(MAKE) CFLAGS="-std=c99" -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .tzdb-done

# Download parted
download-parted: .parted-obtained
.parted-obtained:
	cd $(SRC_PATH) && wget -O parted-$(PARTED_VER).tar.xz $(PARTED_URL) && tar xf parted-$(PARTED_VER).tar.xz
	touch .parted-obtained

# Compile parted
parted: download-parted .parted-done
.parted-done:
	cd $(PARTED_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .parted-done

# Download make-ca
download-make-ca: .make-ca-obtained
.make-ca-obtained:
	cd $(SRC_PATH) && wget -O make-ca-$(MAKE_CA_VER).tar.gz $(MAKE_CA_URL) && tar xf make-ca-$(MAKE_CA_VER).tar.gz
	touch .make-ca-obtained

make-ca: download-make-ca .make-ca-done
.make-ca-done:
	cd $(MAKE_CA_PATH) && $(MAKE) DESTDIR=$(STAGING_PATH) install && install -dm755 /etc/ssl/local && \
	mkdir -p $(STAGING_PATH)/etc/systemd/system/timers.target.wants && ln -sf $(STAGING_PATH)/etc/systemd/system/timers.target.wants/update-pki.timer $(STAGING_PATH)/etc/systemd/system/update-pki.timer && \
	curl -k -o $(STAGING_PATH)/etc/ssl/ca-bundle.crt https://curl.se/ca/cacert.pem && chmod 644 $(STAGING_PATH)/etc/ssl/ca-bundle.crt && \
	echo 'export CURL_CA_BUNDLE=/etc/ssl/ca-bundle.crt' >> $(STAGING_PATH)/etc/profile
	touch .make-ca-done
