# Enable multi-threaded Bash operation
SHELL = bash
THREADS = $(shell nproc)

# Set working paths
SRC_PATH = $(shell realpath ./src)
STAGING_PATH = $(shell realpath ./staging)
OUTPUT_PATH = $(shell realpath ./output)

# Build number
BUILDNUM_FILE := $(shell realpath .buildnum)

# Package variables
# Glibc
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter05/glibc.html
GLIBC_URL = https://mirrors.ocf.berkeley.edu/gnu/glibc/glibc-2.42.tar.gz
GLIBC_VER = 2.42
GLIBC_PATH = $(SRC_PATH)/glibc-$(GLIBC_VER)

# Systemd
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/systemd.html
SYSTEMD_URL = https://github.com/systemd/systemd/archive/v257.8/systemd-257.8.tar.gz
SYSTEMD_VER = 257.8
SYSTEMD_PATH = $(SRC_PATH)/systemd-$(SYSTEMD_VER)

# Coreutils
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter06/coreutils.html
COREUTILS_URL = https://mirrors.ocf.berkeley.edu/gnu/coreutils/coreutils-9.7.tar.gz
COREUTILS_VER = 9.7
COREUTILS_PATH = $(SRC_PATH)/coreutils-$(COREUTILS_VER)

# Util-linux
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/util-linux.html
UTIL_LINUX_URL = https://www.kernel.org/pub/linux/utils/util-linux/v2.41/util-linux-2.41.1.tar.gz
UTIL_LINUX_VER = 2.41.1
UTIL_LINUX_PATH = $(SRC_PATH)/util-linux-$(UTIL_LINUX_VER)

# Bash
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter06/bash.html
BASH_URL = https://mirrors.ocf.berkeley.edu/gnu/bash/bash-5.3.tar.gz
BASH_VER = 5.3
BASH_PATH = $(SRC_PATH)/bash-$(BASH_VER)

# File (also provides libmagic, however it's a userland utility too)
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/file.html
FILE_URL = https://astron.com/pub/file/file-5.46.tar.gz
FILE_VER = 5.46
FILE_PATH = $(SRC_PATH)/file-$(FILE_VER)

# LVM2 (provides libdevmapper, but we don't need the LVM2 utilities)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/lvm2.html
LVM2_URL = https://sourceware.org/ftp/lvm2/LVM2.2.03.34.tgz
LVM2_VER = 2.03.34
LVM2_PATH = $(SRC_PATH)/LVM2.$(LVM2_VER)

# e2fsprogs (provides libcom_err)
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/e2fsprogs.html
E2FSPROGS_URL = https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v1.47.3/e2fsprogs-1.47.3.tar.gz/download
E2FSPROGS_VER = 1.47.3
E2FSPROGS_PATH = $(SRC_PATH)/e2fsprogs-$(E2FSPROGS_VER)

# Library variables
# GCC (libstdc++ and libgcc_s)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/gcc.html
GCC_URL = https://mirrors.ocf.berkeley.edu/gnu/gcc/gcc-15.2.0/gcc-15.2.0.tar.gz
GCC_VER = 15.2.0
GCC_PATH = $(SRC_PATH)/gcc-$(GCC_VER)

# Ncurses
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter06/ncurses.html
NCURSES_URL = https://mirrors.ocf.berkeley.edu/gnu/ncurses/ncurses-6.5.tar.gz
NCURSES_VER = 6.5
NCURSES_PATH = $(SRC_PATH)/ncurses-$(NCURSES_VER)

# Acl
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/acl.html
ACL_URL = https://download-mirror.savannah.gnu.org/releases/acl/acl-2.3.2.tar.gz
ACL_VER = 2.3.2
ACL_PATH = $(SRC_PATH)/acl-$(ACL_VER)

# Libcap
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/libcap.html
LIBCAP_URL = https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.76.tar.gz
LIBCAP_VER = 2.76
LIBCAP_PATH = $(SRC_PATH)/libcap-$(LIBCAP_VER)

# Libseccomp
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libseccomp.html
LIBSECCOMP_URL = https://github.com/seccomp/libseccomp/releases/download/v2.6.0/libseccomp-2.6.0.tar.gz
LIBSECCOMP_VER = 2.6.0
LIBSECCOMP_PATH = $(SRC_PATH)/libseccomp-$(LIBSECCOMP_VER)

# GMP
# URL: https://www.linuxfromscratch.org/~thomas/multilib-systemd/chapter08/gmp.html (ignore multilib instructions)
GMP_URL = https://mirrors.ocf.berkeley.edu/gnu/gmp/gmp-6.3.0.tar.gz
GMP_VER = 6.3.0
GMP_PATH = $(SRC_PATH)/gmp-$(GMP_VER)

# Libxcrypt
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/libxcrypt.html
LIBXCRYPT_URL = https://github.com/besser82/libxcrypt/releases/download/v4.4.38/libxcrypt-4.4.38.tar.xz
LIBXCRYPT_VER = 4.4.38
LIBXCRYPT_PATH = $(SRC_PATH)/libxcrypt-$(LIBXCRYPT_VER)

# OpenSSL
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/openssl.html
OPENSSL_URL = https://github.com/openssl/openssl/releases/download/openssl-3.5.2/openssl-3.5.2.tar.gz
OPENSSL_VER = 3.5.2
OPENSSL_PATH = $(SRC_PATH)/openssl-$(OPENSSL_VER)

# Linux-PAM
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/linux-pam.html (meson build system may break)
LINUX_PAM_URL = https://github.com/linux-pam/linux-pam/releases/download/v1.7.1/Linux-PAM-1.7.1.tar.xz
LINUX_PAM_DOC_URL = https://github.com/linux-pam/linux-pam/releases/download/v1.6.1/Linux-PAM-1.6.1-docs.tar.xz # do you need it?
LINUX_PAM_VER = 1.7.1
LINUX_PAM_PATH = $(SRC_PATH)/Linux-PAM-$(LINUX_PAM_VER)

# Shadow (REQUIRED for user management and logins)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/shadow.html
SHADOW_URL = https://github.com/shadow-maint/shadow/releases/download/4.18.0/shadow-4.18.0.tar.xz
SHADOW_VER = 4.18.0
SHADOW_PATH = $(SRC_PATH)/shadow-$(SHADOW_VER)

# Attr
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/attr.html
ATTR_URL = https://download-mirror.savannah.gnu.org/releases/attr/attr-2.5.2.tar.gz
ATTR_VER = 2.5.2
ATTR_PATH = $(SRC_PATH)/attr-$(ATTR_VER)

# Audit-userspace (Linux-audit)
# URL: https://github.com/linux-audit/audit-userspace (w/o instructions)
# Referred to by https://www.linuxfromscratch.org/lfs/view/systemd/appendices/dependencies.html
LINUX_AUDIT_URL = https://github.com/linux-audit/audit-userspace/archive/refs/tags/v4.1.1.tar.gz
LINUX_AUDIT_VER = 4.1.1
LINUX_AUDIT_PATH = $(SRC_PATH)/audit-userspace-$(LINUX_AUDIT_VER)

# Libcap-NG
# URL: https://github.com/stevegrubb/libcap-ng (w/o instructions)
# Referred to by https://www.linuxfromscratch.org/lfs/view/systemd/appendices/dependencies.html
LIBCAP_NG_URL = https://github.com/stevegrubb/libcap-ng/archive/refs/tags/v0.8.5.tar.gz
LIBCAP_NG_VER = 0.8.5
LIBCAP_NG_PATH = $(SRC_PATH)/libcap-ng-$(LIBCAP_NG_VER)

# Zlib
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/zlib.html
ZLIB_URL = https://www.zlib.net/fossils/zlib-1.3.1.tar.gz
ZLIB_VER = 1.3.1
ZLIB_PATH = $(SRC_PATH)/zlib-$(ZLIB_VER)
ZLIB_PATH = $(SRC_PATH)/zlib-$(ZLIB_VER)

# OpenLDAP (also provides liblber)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/server/openldap.html
OPENLDAP_URL = https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.6.10.tgz
OPENLDAP_VER = 2.6.10
OPENLDAP_PATH = $(SRC_PATH)/openldap-$(OPENLDAP_VER)

# Libgcrypt
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libgcrypt.html
LIBGCRYPT_URL = https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.11.2.tar.bz2
LIBGCRYPT_VER = 1.11.2
LIBGCRYPT_PATH = $(SRC_PATH)/libgcrypt-$(LIBGCRYPT_VER)

# Libgpg-error
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libgpg-error.html
LIBGPG_ERROR_URL = https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.55.tar.gz
LIBGPG_ERROR_VER = 1.55
LIBGPG_ERROR_PATH = $(SRC_PATH)/libgpg-error-$(LIBGPG_ERROR_VER)

# Readline
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/readline.html
READLINE_URL = https://mirrors.ocf.berkeley.edu/gnu/readline/readline-8.3.tar.gz
READLINE_VER = 8.3
READLINE_PATH = $(SRC_PATH)/readline-$(READLINE_VER)

# Cryptsetup
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/cryptsetup.html
CRYPTSETUP_URL = https://www.kernel.org/pub/linux/utils/cryptsetup/v2.8/cryptsetup-2.8.1.tar.gz
CRYPTSETUP_VER = 2.8.1
CRYPTSETUP_PATH = $(SRC_PATH)/cryptsetup-$(CRYPTSETUP_VER)

# Cyrus-SASL
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/cyrus-sasl.html
CYRUS_SASL_URL = https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.28/cyrus-sasl-2.1.28.tar.gz
CYRUS_SASL_VER = 2.1.28
CYRUS_SASL_PATH = $(SRC_PATH)/cyrus-sasl-$(CYRUS_SASL_VER)

# Popt
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/popt.html
POPT_URL = https://ftp.osuosl.org/pub/rpm/popt/releases/popt-1.x/popt-1.19.tar.gz
POPT_VER = 1.19
POPT_PATH = $(SRC_PATH)/popt-$(POPT_VER)

# JSON-C
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/json-c.html
JSON_C_URL = https://s3.amazonaws.com/json-c_releases/releases/json-c-0.18.tar.gz
JSON_C_VER = 0.18
JSON_C_PATH = $(SRC_PATH)/json-c-$(JSON_C_VER)

# Zstd
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/zstd.html
ZSTD_URL = https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz
ZSTD_VER = 1.5.7
ZSTD_PATH = $(SRC_PATH)/zstd-$(ZSTD_VER)

# Bzip2
# URL: https://sourceware.org/pub/bzip2/ (w/o instructions)
BZIP2_URL = https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
BZIP2_VER = 1.0.8
BZIP2_PATH = $(SRC_PATH)/bzip2-$(BZIP2_VER)

# XZ Utils
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/xz.html
XZ_UTILS_URL = https://github.com/tukaani-project/xz/releases/download/v5.8.1/xz-5.8.1.tar.gz
XZ_UTILS_VER = 5.8.1
XZ_UTILS_PATH = $(SRC_PATH)/xz-$(XZ_UTILS_VER)

# Lz4
# URL: http://www.linuxfromscratch.org/lfs/view/systemd/chapter08/lz4.html
LZ4_URL = https://github.com/lz4/lz4/releases/download/v1.10.0/lz4-1.10.0.tar.gz
LZ4_VER = 1.10.0
LZ4_PATH = $(SRC_PATH)/lz4-$(LZ4_VER)

# Gzip
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter06/gzip.html
GZIP_URL = https://mirrors.ocf.berkeley.edu/gnu/gzip/gzip-1.14.tar.gz
GZIP_VER = 1.14
GZIP_PATH = $(SRC_PATH)/gzip-$(GZIP_VER)

# Libaio
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libaio.html
LIBAIO_URL = https://pagure.io/libaio/archive/libaio-0.3.113/libaio-0.3.113.tar.gz
LIBAIO_VER = 0.3.113
LIBAIO_PATH = $(SRC_PATH)/libaio-$(LIBAIO_VER)

# Krb5 (MIT Kerberos V5)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/mitkrb.html
KRB5_URL = https://kerberos.org/dist/krb5/1.22/krb5-1.22.tar.gz
KRB5_VER = 1.22
KRB5_PATH = $(SRC_PATH)/krb5-$(KRB5_VER)

# Lmdb
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/server/lmdb.html
LMDB_URL = https://git.openldap.org/openldap/openldap/-/archive/LMDB_0.9.33.tar.bz2
LMDB_VER = 0.9.33
LMDB_PATH = $(SRC_PATH)/openldap-LMDB_$(LMDB_VER)

# Libnsl
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/basicnet/libnsl.html
LIBNSL_URL = https://github.com/thkukuk/libnsl/releases/download/v2.0.1/libnsl-2.0.1.tar.xz
LIBNSL_VER = 2.0.1
LIBNSL_PATH = $(SRC_PATH)/libnsl-$(LIBNSL_VER)

# Libtirpc
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/basicnet/libtirpc.html
LIBTIRPC_URL = https://downloads.sourceforge.net/libtirpc/libtirpc-1.3.7.tar.bz2
LIBTIRPC_VER = 1.3.7
LIBTIRPC_PATH = $(SRC_PATH)/libtirpc-$(LIBTIRPC_VER)

# Keyutils
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/keyutils.html
KEYUTILS_URL = https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/keyutils.git/snapshot/keyutils-1.6.3.tar.gz
KEYUTILS_VER = 1.6.3
KEYUTILS_PATH = $(SRC_PATH)/keyutils-$(KEYUTILS_VER)

# Libfuse (Fuse)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/fuse.html
LIBFUSE_URL = https://github.com/libfuse/libfuse/releases/download/fuse-3.17.4/fuse-3.17.4.tar.gz
LIBFUSE_VER = 3.17.4
LIBFUSE_PATH = $(SRC_PATH)/fuse-$(LIBFUSE_VER)

# D-Bus (for certain systemd units)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/dbus.html
DBUS_URL = https://dbus.freedesktop.org/releases/dbus/dbus-1.16.2.tar.xz
DBUS_VER = 1.16.2
DBUS_PATH = $(SRC_PATH)/dbus-$(DBUS_VER)

# D-Bus Broker (systemd integration)
# Why do we need both D-Bus implementations?
# URL: https://github.com/bus1/dbus-broker (w/o instructions)
DBUS_BROKER_URL = https://github.com/bus1/dbus-broker/releases/download/v37/dbus-broker-37.tar.xz
DBUS_BROKER_VER = 37
DBUS_BROKER_PATH = $(SRC_PATH)/dbus-broker-$(DBUS_BROKER_VER)

# Kbd (for systemd-vconsole-setup)
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/kbd.html
KBD_URL = https://www.kernel.org/pub/linux/utils/kbd/kbd-2.8.0.tar.gz
KBD_VER = 2.8.0
KBD_PATH = $(SRC_PATH)/kbd-$(KBD_VER)

# Targets
.PHONY: all
all: dirs timestamp gmp zlib libgpg-error libgcrypt libxcrypt libcap libcap-ng acl attr libaio libtirpc libnsl lmdb keyutils krb5 libfuse glibc ncurses readline file json-c popt linux-audit linux-pam shadow cyrus-sasl openldap bzip2 xz-utils lz4 zstd gzip openssl cryptsetup coreutils util-linux bash e2fsprogs systemd lvm2 gcc libseccomp dbus dbus-broker kbd

# Create system hierarchy
.PHONY: dirs
dirs: .dirs-done

.dirs-done:
	mkdir -p $(STAGING_PATH) $(OUTPUT_PATH) $(SRC_PATH)

	mkdir -p $(STAGING_PATH)/{boot,dev,etc,home,mnt,opt,proc,root,run,sys,tmp,var}
	mkdir -p $(STAGING_PATH)/usr/{bin,include,lib,local,share,src}
	ln -sf bin $(STAGING_PATH)/usr/sbin
	ln -sf lib $(STAGING_PATH)/usr/lib64
	ln -sf lib $(STAGING_PATH)/usr/libexec
	ln -sf usr/bin $(STAGING_PATH)/bin
	ln -sf usr/bin $(STAGING_PATH)/sbin
	ln -sf usr/lib $(STAGING_PATH)/lib
	ln -sf usr/lib $(STAGING_PATH)/lib64
	touch .dirs-done

# Download Glibc
.PHONY: download-glibc
download-glibc: .glibc-obtained

.glibc-obtained:
	mkdir -p $(SRC_PATH)
	cd $(SRC_PATH) && wget -O glibc-$(GLIBC_VER).tar.gz $(GLIBC_URL) && tar xf glibc-$(GLIBC_VER).tar.gz
	touch .glibc-obtained

# Compile Glibc
.PHONY: glibc
glibc: download-glibc .glibc-done

.glibc-done:
	mkdir -p $(GLIBC_PATH)/build
	cd $(GLIBC_PATH)/build && ../configure --prefix=/usr --disable-werror --enable-kernel=5.4 \
	--enable-stack-protector=strong --disable-nscd --enable-shared libc_cv_slibdir=/usr/lib && $(MAKE) CFLAGS="-O2" -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .glibc-done

# Download systemd
.PHONY: download-systemd
download-systemd: .systemd-obtained

.systemd-obtained:
	cd $(SRC_PATH) && wget -O systemd-$(SYSTEMD_VER).tar.gz $(SYSTEMD_URL) && tar xf systemd-$(SYSTEMD_VER).tar.gz
	touch .systemd-obtained

# Compile systemd
.PHONY: systemd
systemd: download-systemd .systemd-done

.systemd-done:
	mkdir -p $(SYSTEMD_PATH)/build
	cd $(SYSTEMD_PATH)/build && meson setup .. --prefix=/usr --buildtype=release \
	-D default-dnssec=no -D firstboot=false -D install-tests=false -D ldconfig=false \
	-D man=auto -D sysusers=false -D rpmmacrosdir=no -D homed=disabled \
	-D userdb=false -D mode=release -D pam=enabled -D pamconfdir=/etc/pam.d \
	-D dev-kvm-mode=0660 -D nobody-group=nogroup -D sysupdate=disabled -D ukify=disabled \
	-D docdir=/usr/share/doc/systemd-$(SYSTEMD_VER) && ninja && DESTDIR=$(STAGING_PATH) ninja install

	echo "arkana" > $(STAGING_PATH)/etc/hostname
	
	echo "NAME=arkanaOS" > $(STAGING_PATH)/etc/os-release
	echo "VERSION=dev" >> $(STAGING_PATH)/etc/os-release
	echo "ID=arkana" >> $(STAGING_PATH)/etc/os-release
	echo "ID_LIKE=lfs" >> $(STAGING_PATH)/etc/os-release
	echo "VERSION_ID=dev" >> $(STAGING_PATH)/etc/os-release
	echo "PRETTY_NAME='arkanaOS Dev'" >> $(STAGING_PATH)/etc/os-release
	echo "ANSI_COLOR='38;5;6'" >> $(STAGING_PATH)/etc/os-release

	mkdir -p $(STAGING_PATH)/etc/systemd/system/getty@tty1.service.d
	echo "[Service]" > $(STAGING_PATH)/etc/systemd/system/getty@tty1.service.d/override.conf
	echo "ExecStart=" >> $(STAGING_PATH)/etc/systemd/system/getty@tty1.service.d/override.conf
	echo "ExecStart=-/sbin/agetty --autologin root --noclear %I $$TERM" >> $(STAGING_PATH)/etc/systemd/system/getty@tty1.service.d/override.conf
	
	touch .systemd-done

.PHONY: timestamp
timestamp:
	BUILD=$$(($$(cat $(BUILDNUM_FILE))+1)); \
	echo "arkanaOS Dev ($$(date +%Y%m%d)) (build $$BUILD)" > $(STAGING_PATH)/etc/issue; \
	echo $$BUILD > $(BUILDNUM_FILE)

# Download coreutils
.PHONY: download-coreutils
download-coreutils: .coreutils-obtained

.coreutils-obtained:
	cd $(SRC_PATH) && wget -O coreutils-$(COREUTILS_VER).tar.gz $(COREUTILS_URL) && tar xf coreutils-$(COREUTILS_VER).tar.gz
	touch .coreutils-obtained

# Compile coreutils
.PHONY: coreutils
coreutils: download-coreutils .coreutils-done

.coreutils-done:
	cd $(COREUTILS_PATH) && autoreconf -fv && automake -af && FORCE_UNSAFE_CONFIGURE=1 \
	./configure --prefix=/usr --enable-no-install-program=kill,uptime && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .coreutils-done

# Download util-linux
.PHONY: download-util-linux
download-util-linux: .util-linux-obtained

.util-linux-obtained:
	cd $(SRC_PATH) && wget -O util-linux-$(UTIL_LINUX_VER).tar.gz $(UTIL_LINUX_URL) && tar xf util-linux-$(UTIL_LINUX_VER).tar.gz
	touch .util-linux-obtained

# Compile util-linux
.PHONY: util-linux
util-linux: download-util-linux .util-linux-done

.util-linux-done:
	cd $(UTIL_LINUX_PATH) && ./configure --bindir=/usr/bin --libdir=/usr/lib --sbindir=/usr/sbin \
	--runstatedir=/run --disable-chfn-chsh -disable-login --disable-nologin --disable-su --disable-setpriv \
	--disable-runuser --disable-pylibmount --disable-liblastlog2 --without-python \
	ADJTIME_PATH=/var/lib/hwclock/adjtime --docdir=/usr/share/doc/util-linux-$(UTIL_LINUX_VER) && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .util-linux-done

# Download bash
.PHONY: download-bash
download-bash: .bash-obtained

.bash-obtained:
	cd $(SRC_PATH) && wget -O bash-$(BASH_VER).tar.gz $(BASH_URL) && tar xf bash-$(BASH_VER).tar.gz
	touch .bash-obtained

# Compile bash
.PHONY: bash
bash: download-bash .bash-done

.bash-done:
	cd $(BASH_PATH) && ./configure --prefix=/usr --without-bash-malloc && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && \
	ln -sf bash $(STAGING_PATH)/usr/bin/sh && cp -a /etc/profile $(STAGING_PATH)/etc/profile && cp -a /etc/bash.bashrc $(STAGING_PATH)/etc/bash.bashrc
	touch .bash-done

.PHONY: download-file
download-file: .file-obtained

.file-obtained:
	cd $(SRC_PATH) && wget -O file-$(FILE_VER).tar.gz $(FILE_URL) && tar xf file-$(FILE_VER).tar.gz
	touch .file-obtained

.PHONY: file
file: download-file .file-done

.file-done:
	cd $(FILE_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .file-done

# Download LVM2
.PHONY: download-lvm2
download-lvm2: .lvm2-obtained

.lvm2-obtained:
	cd $(SRC_PATH) && wget -O lvm2-$(LVM2_VER).tgz $(LVM2_URL) && tar xf lvm2-$(LVM2_VER).tgz
	touch .lvm2-obtained

# Compile LVM2
.PHONY: lvm2
lvm2: download-lvm2 .lvm2-done

.lvm2-done:
	cd $(LVM2_PATH) && ./configure --prefix=/usr --enable-cmdlib --enable-pkgconfig --enable-udev_sync && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) -C tools install_tools_dynamic && $(MAKE) DESTDIR=$(STAGING_PATH) -C udev install && $(MAKE) DESTDIR=$(STAGING_PATH) -C libdm install
	touch .lvm2-done

# Download e2fsprogs
.PHONY: download-e2fsprogs
download-e2fsprogs: .e2fsprogs-obtained

.e2fsprogs-obtained:
	cd $(SRC_PATH) && wget -O e2fsprogs-$(E2FSPROGS_VER).tar.gz $(E2FSPROGS_URL) && tar xf e2fsprogs-$(E2FSPROGS_VER).tar.gz
	touch .e2fsprogs-obtained

# Compile e2fsprogs
.PHONY: e2fsprogs
e2fsprogs: download-e2fsprogs .e2fsprogs-done

.e2fsprogs-done:
	mkdir -p $(E2FSPROGS_PATH)/build && cd $(E2FSPROGS_PATH)/build && ../configure --prefix=/usr --sysconfdir=/etc --enable-elf-shlibs --disable-libblkid --disable-libuuid \
	--disable-uuidd --disable-fsck && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .e2fsprogs-done

# Library targets

# Download GCC
.PHONY: download-gcc
download-gcc: .gcc-obtained

.gcc-obtained:
	cd $(SRC_PATH) && wget -O gcc-$(GCC_VER).tar.gz $(GCC_URL) && tar xf gcc-$(GCC_VER).tar.gz
	touch .gcc-obtained

# Compile GCC (libs only)
.PHONY: gcc
gcc: download-gcc .gcc-done

.gcc-done:
	mkdir -p $(GCC_PATH)/build && cd $(GCC_PATH) && ./contrib/download_prerequisites && cd build && ../configure --prefix=/usr --disable-multilib \
	--enable-languages=c,c++ --disable-bootstrap && make -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install-target-libstdc++-v3 install-target-libgcc
	touch .gcc-done

# Download ncurses
.PHONY: download-ncurses
download-ncurses: .ncurses-obtained

.ncurses-obtained:
	cd $(SRC_PATH) && wget -O ncurses-$(NCURSES_VER).tar.gz $(NCURSES_URL) && tar xf ncurses-$(NCURSES_VER).tar.gz
	touch .ncurses-obtained

# Compile ncurses
.PHONY: ncurses
ncurses: download-ncurses .ncurses-done

.ncurses-done:
	cd $(NCURSES_PATH) && ./configure --prefix=/usr --mandir=/usr/share/man --with-shared --without-debug \
	--without-normal --with-cxx-shared --enable-pc-files --with-pkg-config-libdir=/usr/lib/pkgconfig \
	--with-versioned-syms && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	ln -sf libncursesw.so $(STAGING_PATH)/usr/lib/libcurses.so
	touch .ncurses-done

# Download acl
.PHONY: download-acl
download-acl: .acl-obtained

.acl-obtained:
	cd $(SRC_PATH) && wget -O acl-$(ACL_VER).tar.gz $(ACL_URL) && tar xf acl-$(ACL_VER).tar.gz
	touch .acl-obtained

# Compile acl
.PHONY: acl
acl: download-acl .acl-done

.acl-done:
	cd $(ACL_PATH) && ./configure --prefix=/usr --docdir=/usr/share/doc/acl-$(ACL_VER) && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .acl-done

# Download libcap
.PHONY: download-libcap
download-libcap: .libcap-obtained

.libcap-obtained:
	cd $(SRC_PATH) && wget -O libcap-$(LIBCAP_VER).tar.gz $(LIBCAP_URL) && tar xf libcap-$(LIBCAP_VER).tar.gz
	touch .libcap-obtained

# Compile libcap
.PHONY: libcap
libcap: download-libcap .libcap-done

.libcap-done:
	cd $(LIBCAP_PATH) && $(MAKE) -j$(THREADS) prefix=/usr lib=lib && $(MAKE) prefix=$(STAGING_PATH)/usr lib=lib install
	cd $(LIBCAP_PATH) && $(MAKE) -j$(THREADS) -C pam_cap && mkdir -p $(STAGING_PATH)/etc/security && install -v -m755 pam_cap/pam_cap.so $(STAGING_PATH)/usr/lib/security && \
	install -v -m644 pam_cap/capability.conf $(STAGING_PATH)/etc/security
	touch .libcap-done

# Download libseccomp
.PHONY: download-libseccomp
download-libseccomp: .libseccomp-obtained

.libseccomp-obtained:
	cd $(SRC_PATH) && wget -O libseccomp-$(LIBSECCOMP_VER).tar.gz $(LIBSECCOMP_URL) && tar xf libseccomp-$(LIBSECCOMP_VER).tar.gz
	touch .libseccomp-obtained

# Compile libseccomp
.PHONY: libseccomp
libseccomp: download-libseccomp .libseccomp-done

.libseccomp-done:
	cd $(LIBSECCOMP_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libseccomp-done

# Download GMP
.PHONY: download-gmp
download-gmp: .gmp-obtained

.gmp-obtained:
	cd $(SRC_PATH) && wget -O gmp-$(GMP_VER).tar.gz $(GMP_URL) && tar xf gmp-$(GMP_VER).tar.gz
	touch .gmp-obtained

# Compile GMP
.PHONY: gmp
gmp: download-gmp .gmp-done

.gmp-done:
	cd $(GMP_PATH) && ./configure --prefix=/usr --enable-cxx --docdir=/usr/share/doc/gmp-$(GMP_VER) && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .gmp-done

# Download libxcrypt
.PHONY: download-libxcrypt
download-libxcrypt: .libxcrypt-obtained

.libxcrypt-obtained:
	cd $(SRC_PATH) && wget -O libxcrypt-$(LIBXCRYPT_VER).tar.xz $(LIBXCRYPT_URL) && tar xf libxcrypt-$(LIBXCRYPT_VER).tar.xz
	touch .libxcrypt-obtained

# Compile libxcrypt
.PHONY: libxcrypt
libxcrypt: download-libxcrypt .libxcrypt-done

.libxcrypt-done:
	cd $(LIBXCRYPT_PATH) && ./configure --prefix=/usr --enable-hashes=strong,glibc --enable-obsolete-api=no \
	--disable-failure-tokens && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libxcrypt-done

# Download OpenSSL
.PHONY: download-openssl
download-openssl: .openssl-obtained

.openssl-obtained:
	cd $(SRC_PATH) && wget -O openssl-$(OPENSSL_VER).tar.gz $(OPENSSL_URL) && tar xf openssl-$(OPENSSL_VER).tar.gz
	touch .openssl-obtained

# Compile OpenSSL
.PHONY: openssl
openssl: download-openssl .openssl-done

.openssl-done:
	cd $(OPENSSL_PATH) && ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic && \
	$(MAKE) -j$(THREADS) && $(MAKE) MANSUFFIX=ssl DESTDIR=$(STAGING_PATH) PATH=$$PATH:/usr/bin/core_perl/ install
	touch .openssl-done

# Download Linux-PAM
.PHONY: download-linux-pam
download-linux-pam: .linux-pam-obtained

.linux-pam-obtained:
	cd $(SRC_PATH) && wget -O linux-pam-$(LINUX_PAM_VER).tar.xz $(LINUX_PAM_URL) && tar xf linux-pam-$(LINUX_PAM_VER).tar.xz
	cd $(SRC_PATH) && wget -O linux-pam-$(LINUX_PAM_VER)-docs.tar.xz $(LINUX_PAM_DOC_URL) && tar xf linux-pam-$(LINUX_PAM_VER)-docs.tar.xz -C $(STAGING_PATH)/usr/share/doc
	touch .linux-pam-obtained

# Compile Linux-PAM
.PHONY: linux-pam
linux-pam: download-linux-pam .linux-pam-done

.linux-pam-done:
	rm $(STAGING_PATH)/etc/security || true
	mkdir -p $(STAGING_PATH)/etc/pam.d
	mkdir -p $(LINUX_PAM_PATH)/build && cd $(LINUX_PAM_PATH)/build && meson setup .. --prefix=/usr && ninja && DESTDIR=$(STAGING_PATH) ninja install && \
	chmod 4755 $(STAGING_PATH)/usr/sbin/unix_chkpwd && cp -a /etc/pam.d/* $(STAGING_PATH)/etc/pam.d/ && cp ../../../passwd $(STAGING_PATH)/etc/passwd && \
	cp ../../../shadow $(STAGING_PATH)/etc/shadow && cp ../../../group $(STAGING_PATH)/etc/group

	touch .linux-pam-done

# Download shadow
.PHONY: download-shadow
download-shadow: .shadow-obtained

.shadow-obtained:
	cd $(SRC_PATH) && wget -O shadow-$(SHADOW_VER).tar.xz $(SHADOW_URL) && tar xf shadow-$(SHADOW_VER).tar.xz
	touch .shadow-obtained

# Compile shadow
shadow: download-shadow .shadow-done
.shadow-done:
	cd $(SHADOW_PATH) && sed -i 's/groups$(EXEEXT) //' src/Makefile.in && find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \; && \
	find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \; && \
	find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \; && \
	sed -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD YESCRYPT@' -e 's@/var/spool/mail@/var/mail@' -e '/PATH=/{s@/sbin:@@;s@/bin:@@}' -i etc/login.defs && \
	./configure --sysconfdir=/etc --without-libbsd --with-{b,yes}crypt && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .shadow-done

# Download attr
.PHONY: download-attr
download-attr: .attr-obtained

.attr-obtained:
	cd $(SRC_PATH) && wget -O attr-$(ATTR_VER).tar.gz $(ATTR_URL) && tar xf attr-$(ATTR_VER).tar.gz
	touch .attr-obtained

# Compile attr
.PHONY: attr
attr: download-attr .attr-done

.attr-done:
	cd $(ATTR_PATH) && ./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/attr-$(ATTR_VER) && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .attr-done

# Download Linux-audit
.PHONY: download-linux-audit
download-linux-audit: .linux-audit-obtained

.linux-audit-obtained:
	cd $(SRC_PATH) && wget -O linux-audit-$(LINUX_AUDIT_VER).tar.gz $(LINUX_AUDIT_URL) && tar xf linux-audit-$(LINUX_AUDIT_VER).tar.gz
	touch .linux-audit-obtained

# Compile Linux-audit
.PHONY: linux-audit
linux-audit: download-linux-audit .linux-audit-done

.linux-audit-done:
	cd $(LINUX_AUDIT_PATH) && autoreconf -fi && ./configure --prefix=/usr --without-python3 --with-libcap-ng=yes --without-golang --with-io_uring && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && mkdir -p $(STAGING_PATH)/etc/systemd/system && ln -sf /dev/null $(STAGING_PATH)/etc/systemd/system/auditd.service && \
	ln -sf /dev/null $(STAGING_PATH)/etc/systemd/system/audit-rules.service
	touch .linux-audit-done

# Download libcap-ng
.PHONY: download-libcap-ng
download-libcap-ng: .libcap-ng-obtained

.libcap-ng-obtained:
	cd $(SRC_PATH) && wget -O libcap-ng-$(LIBCAP_NG_VER).tar.gz $(LIBCAP_NG_URL) && tar xf libcap-ng-$(LIBCAP_NG_VER).tar.gz
	touch .libcap-ng-obtained

# Compile libcap-ng
.PHONY: libcap-ng
libcap-ng: download-libcap-ng .libcap-ng-done

.libcap-ng-done:
	cd $(LIBCAP_NG_PATH) && ./autogen.sh && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libcap-ng-done

# Download zlib
.PHONY: download-zlib
download-zlib: .zlib-obtained

.zlib-obtained:
	cd $(SRC_PATH) && wget -O zlib-$(ZLIB_VER).tar.gz $(ZLIB_URL) && tar xf zlib-$(ZLIB_VER).tar.gz
	touch .zlib-obtained

# Compile zlib
.PHONY: zlib
zlib: download-zlib .zlib-done

.zlib-done:
	cd $(ZLIB_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .zlib-done

# Download OpenLDAP
.PHONY: download-openldap
download-openldap: .openldap-obtained

.openldap-obtained:
	cd $(SRC_PATH) && wget -O openldap-$(OPENLDAP_VER).tgz $(OPENLDAP_URL) && tar xf openldap-$(OPENLDAP_VER).tgz
	touch .openldap-obtained

# Compile OpenLDAP
.PHONY: openldap
openldap: download-openldap .openldap-done

.openldap-done:
	cd $(OPENLDAP_PATH) && autoconf && ./configure --prefix=/usr --sysconfdir=/etc --enable-dynamic \
	--disable-debug && $(MAKE) -j$(THREADS) depend && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && \
	ln -sf /dev/null $(STAGING_PATH)/etc/systemd/system/slapd.service
	touch .openldap-done

# Download libgcrypt
.PHONY: download-libgcrypt
download-libgcrypt: .libgcrypt-obtained

.libgcrypt-obtained:
	cd $(SRC_PATH) && wget -O libgcrypt-$(LIBGCRYPT_VER).tar.bz2 $(LIBGCRYPT_URL) && tar xf libgcrypt-$(LIBGCRYPT_VER).tar.bz2
	touch .libgcrypt-obtained

# Compile libgcrypt
.PHONY: libgcrypt
libgcrypt: download-libgcrypt .libgcrypt-done

.libgcrypt-done:
	cd $(LIBGCRYPT_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) -j$(THREADS) -C doc html && \
	makeinfo --html --no-split -o doc/gcrypt_nochunks.html doc/gcrypt.texi && makeinfo --plaintext -o doc/gcrypt.txt doc/gcrypt.texi && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install && install -dm755 $(STAGING_PATH)/usr/share/doc/libgcrypt-$(LIBGCRYPT_VER) && \
	install -m644 README doc/{README.apichanges,fips*,libgcrypt*} $(STAGING_PATH)/usr/share/doc/libgcrypt-$(LIBGCRYPT_VER) && \
	install -dm755 $(STAGING_PATH)/usr/share/doc/libgcrypt-$(LIBGCRYPT_VER)/html && install -m644 doc/gcrypt.html/* \
	$(STAGING_PATH)/usr/share/doc/libgcrypt-$(LIBGCRYPT_VER)/html && install -m644 doc/gcrypt_nochunks.html $(STAGING_PATH)/usr/share/doc/libgcrypt-$(LIBGCRYPT_VER) && \
	install -m644 doc/gcrypt.{txt,texi} $(STAGING_PATH)/usr/share/doc/libgcrypt-$(LIBGCRYPT_VER)
	touch .libgcrypt-done

# Download libgpg-error
.PHONY: download-libgpg-error
download-libgpg-error: .libgpg-error-obtained

.libgpg-error-obtained:
	cd $(SRC_PATH) && wget -O libgpg-error-$(LIBGPG_ERROR_VER).tar.gz $(LIBGPG_ERROR_URL) && tar xf libgpg-error-$(LIBGPG_ERROR_VER).tar.gz
	touch .libgpg-error-obtained

# Compile libgpg-error
.PHONY: libgpg-error
libgpg-error: download-libgpg-error .libgpg-error-done

.libgpg-error-done:
	cd $(LIBGPG_ERROR_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && \
	install -m644 -D README /usr/share/doc/libgpg-error-$(LIBGPG_ERROR_VER)/README
	touch .libgpg-error-done

# Download readline
.PHONY: download-readline
download-readline: .readline-obtained

.readline-obtained:
	cd $(SRC_PATH) && wget -O readline-$(READLINE_VER).tar.gz $(READLINE_URL) && tar xf readline-$(READLINE_VER).tar.gz
	touch .readline-obtained

# Compile readline
.PHONY: readline
readline: download-readline .readline-done

.readline-done:
	cd $(READLINE_PATH) && ./configure --prefix=/usr --with-curses --docdir=/usr/share/doc/readline-$(READLINE_VER) && $(MAKE) SHLIB_LIBS="-lncursesw" -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) SHLIB_LIBS="-lncursesw" install && install -m644 doc/*.{ps,pdf,html,dvi} $(STAGING_PATH)/usr/share/doc/readline-$(READLINE_VER)
	touch .readline-done

# Download cryptsetup
.PHONY: download-cryptsetup
download-cryptsetup: .cryptsetup-obtained

.cryptsetup-obtained:
	cd $(SRC_PATH) && wget -O cryptsetup-$(CRYPTSETUP_VER).tar.gz $(CRYPTSETUP_URL) && tar xf cryptsetup-$(CRYPTSETUP_VER).tar.gz
	touch .cryptsetup-obtained

# Compile cryptsetup
.PHONY: cryptsetup
cryptsetup: download-cryptsetup .cryptsetup-done

.cryptsetup-done:
	cd $(CRYPTSETUP_PATH) && ./configure --prefix=/usr --disable-ssh-token --disable-asciidoc && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .cryptsetup-done

# Download Cyrus-SASL
.PHONY: download-cyrus-sasl
download-cyrus-sasl: .cyrus-sasl-obtained

.cyrus-sasl-obtained:
	cd $(SRC_PATH) && wget -O cyrus-sasl-$(CYRUS_SASL_VER).tar.gz $(CYRUS_SASL_URL) && tar xf cyrus-sasl-$(CYRUS_SASL_VER).tar.gz
	touch .cyrus-sasl-obtained

# Compile Cyrus-SASL
.PHONY: cyrus-sasl
cyrus-sasl: download-cyrus-sasl .cyrus-sasl-done

.cyrus-sasl-done:
	cd $(CYRUS_SASL_PATH) && sed '/saslint/a #include <time.h>' -i lib/saslutil.c && sed '/plugin_common/a #include <time.h>' -i plugins/cram.c && \
	./configure --prefix=/usr --sysconfdir=/etc --enable-auth-sasldb --with-dblib=lmdb --with-dbpath=/var/lib/sasl/sasldb2 --with-sphinx-build=no \
	--with-saslauthd=/var/run/saslauthd && $(MAKE) && $(MAKE) DESTDIR=$(STAGING_PATH) install && install -dm755 $(STAGING_PATH)/usr/share/doc/cyrus-sasl-$(CYRUS_SASL_VER)/html && \
	install -m644 saslauthd/LDAP_SASLAUTHD $(STAGING_PATH)/usr/share/doc/cyrus-sasl-$(CYRUS_SASL_VER) && install -m644 doc/legacy/*.html \
	$(STAGING_PATH)/usr/share/doc/cyrus-sasl-$(CYRUS_SASL_VER)/html && install -dm700 $(STAGING_PATH)/var/lib/sasl
	touch .cyrus-sasl-done

# Download popt
.PHONY: download-popt
download-popt: .popt-obtained

.popt-obtained:
	cd $(SRC_PATH) && wget -O popt-$(POPT_VER).tar.gz $(POPT_URL) && tar xf popt-$(POPT_VER).tar.gz
	touch .popt-obtained

# Compile popt
.PHONY: popt
popt: download-popt .popt-done

.popt-done:
	cd $(POPT_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .popt-done

# Download JSON-C
.PHONY: download-json-c
download-json-c: .json-c-obtained

.json-c-obtained:
	cd $(SRC_PATH) && wget -O json-c-$(JSON_C_VER).tar.gz $(JSON_C_URL) && tar xf json-c-$(JSON_C_VER).tar.gz
	touch .json-c-obtained

# Compile JSON-C
.PHONY: json-c
json-c: download-json-c .json-c-done

.json-c-done:
	mkdir -p $(JSON_C_PATH)/build
	# Outdated build system may cause problems on Arch Linux
	cd $(JSON_C_PATH)/build && cmake -D CMAKE_POLICY_VERSION_MINIMUM=3.5 -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release .. && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .json-c-done

# Download zstd
.PHONY: download-zstd
download-zstd: .zstd-obtained

.zstd-obtained:
	cd $(SRC_PATH) && wget -O zstd-$(ZSTD_VER).tar.gz $(ZSTD_URL) && tar xf zstd-$(ZSTD_VER).tar.gz
	touch .zstd-obtained

# Compile zstd
.PHONY: zstd
zstd: download-zstd .zstd-done

.zstd-done:
	cd $(ZSTD_PATH) && $(MAKE) -j$(THREADS) prefix=/usr && $(MAKE) prefix=$(STAGING_PATH)/usr install
	touch .zstd-done

# Download bzip2
.PHONY: download-bzip2
download-bzip2: .bzip2-obtained

.bzip2-obtained:
	cd $(SRC_PATH) && wget -O bzip2-$(BZIP2_VER).tar.gz $(BZIP2_URL) && tar xf bzip2-$(BZIP2_VER).tar.gz
	touch .bzip2-obtained

# Compile bzip2
.PHONY: bzip2
bzip2: download-bzip2 .bzip2-done

.bzip2-done:
	cd $(BZIP2_PATH) && sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile && $(MAKE) clean && \
	$(MAKE) -f Makefile-libbz2_so && $(MAKE) clean && $(MAKE) -j$(THREADS) && \
	$(MAKE) PREFIX=$(STAGING_PATH)/usr install && cp -a libbz2.so.* $(STAGING_PATH)/usr/lib && \
	ln -sf libbz2.so.1.0.8 /usr/lib/libbz2.so && cp bzip2-shared $(STAGING_PATH)/usr/bin/bzip2
	for i in /usr/bin/{bzcat,bunzip2}; do \
	  cd $(STAGING_PATH) && ln -sf bzip2 $$i; \
	done
	touch .bzip2-done

# Download XZ Utils
.PHONY: download-xz-utils
download-xz-utils: .xz-utils-obtained

.xz-utils-obtained:
	cd $(SRC_PATH) && wget -O xz-$(XZ_UTILS_VER).tar.gz $(XZ_UTILS_URL) && tar xf xz-$(XZ_UTILS_VER).tar.gz
	touch .xz-utils-obtained

# Compile XZ Utils
.PHONY: xz-utils
xz-utils: download-xz-utils .xz-utils-done

.xz-utils-done:
	cd $(XZ_UTILS_PATH) && ./configure --prefix=/usr --docdir=/usr/share/doc/xz-$(XZ_VER) && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .xz-utils-done

# Download lz4
.PHONY: download-lz4
download-lz4: .lz4-obtained

.lz4-obtained:
	cd $(SRC_PATH) && wget -O lz4-$(LZ4_VER).tar.gz $(LZ4_URL) && tar xf lz4-$(LZ4_VER).tar.gz
	touch .lz4-obtained

# Compile lz4
.PHONY: lz4
lz4: download-lz4 .lz4-done

.lz4-done:
	cd $(LZ4_PATH) && $(MAKE) -j$(THREADS) PREFIX=/usr && $(MAKE) PREFIX=$(STAGING_PATH)/usr install
	touch .lz4-done

# Download gzip
.PHONY: download-gzip
download-gzip: .gzip-obtained

.gzip-obtained:
	cd $(SRC_PATH) && wget -O gzip-$(GZIP_VER).tar.gz $(GZIP_URL) && tar xf gzip-$(GZIP_VER).tar.gz
	touch .gzip-obtained

# Compile gzip
.PHONY: gzip
gzip: download-gzip .gzip-done

.gzip-done:
	cd $(GZIP_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .gzip-done

# Download libaio
.PHONY: download-libaio
download-libaio: .libaio-obtained

.libaio-obtained:
	cd $(SRC_PATH) && wget -O libaio-$(LIBAIO_VER).tar.gz $(LIBAIO_URL) && tar xf libaio-$(LIBAIO_VER).tar.gz
	touch .libaio-obtained

# Compile libaio
.PHONY: libaio
libaio: download-libaio .libaio-done

.libaio-done:
	cd $(LIBAIO_PATH) && $(MAKE) && $(MAKE) -j$(THREADS) DESTDIR=$(STAGING_PATH) install
	touch .libaio-done

# Download krb5
.PHONY: download-krb5
download-krb5: .krb5-obtained

.krb5-obtained:
	cd $(SRC_PATH) && wget -O krb5-$(KRB5_VER).tar.gz $(KRB5_URL) && tar xf krb5-$(KRB5_VER).tar.gz
	touch .krb5-obtained

# Compile krb5
.PHONY: krb5
krb5: download-krb5 .krb5-done

.krb5-done:
	cd $(KRB5_PATH)/src && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var/lib --runstatedir=/run --with-system-et \
	--with-system-ss --with-system-verto=no --enable-dns-for-realm --disable-rpath && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install && cp -fr ../doc $(STAGING_PATH)/usr/share/doc/krb5-$(KRB5_VER)
	touch .krb5-done

# Download libnsl
.PHONY: download-libnsl
download-libnsl: .libnsl-obtained

.libnsl-obtained:
	cd $(SRC_PATH) && wget -O libnsl-$(LIBNSL_VER).tar.xz $(LIBNSL_URL) && tar xf libnsl-$(LIBNSL_VER).tar.xz
	touch .libnsl-obtained

# Compile libnsl
.PHONY: libnsl
libnsl: download-libnsl .libnsl-done

.libnsl-done:
	cd $(LIBNSL_PATH) && ./configure --sysconfdir=/etc && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libnsl-done

# Download libtirpc
.PHONY: download-libtirpc
download-libtirpc: .libtirpc-obtained

.libtirpc-obtained:
	cd $(SRC_PATH) && wget -O libtirpc-$(LIBTIRPC_VER).tar.bz2 $(LIBTIRPC_URL) && tar xf libtirpc-$(LIBTIRPC_VER).tar.bz2 && \
	cd $(LIBTIRPC_PATH) && curl -s -L $(LIBTIRPC_PATCH_URL) | patch -p1
	touch .libtirpc-obtained

# Compile libtirpc
.PHONY: libtirpc
libtirpc: download-libtirpc .libtirpc-done

.libtirpc-done:
	cd $(LIBTIRPC_PATH) && ./configure --prefix=/usr --sysconfdir=/etc && $(MAKE) -j$(THREADS) && \
	$(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libtirpc-done

# Download keyutils
.PHONY: download-keyutils
download-keyutils: .keyutils-obtained

.keyutils-obtained:
	cd $(SRC_PATH) && wget -O keyutils-$(KEYUTILS_VER).tar.gz $(KEYUTILS_URL) && tar xf keyutils-$(KEYUTILS_VER).tar.gz
	touch .keyutils-obtained

# Compile keyutils
.PHONY: keyutils
keyutils: download-keyutils .keyutils-done

.keyutils-done:
	cd $(KEYUTILS_PATH) && $(MAKE) -j$(THREADS) && $(MAKE) NO_ARLIB=1 DESTDIR=$(STAGING_PATH) install
	touch .keyutils-done

# Download lmdb
.PHONY: download-lmdb
download-lmdb: .lmdb-obtained

.lmdb-obtained:
	cd $(SRC_PATH) && wget -O lmdb-$(LMDB_VER).tar.gz $(LMDB_URL) && tar xf lmdb-$(LMDB_VER).tar.gz
	touch .lmdb-obtained

# Compile lmdb
.PHONY: lmdb
lmdb: download-lmdb .lmdb-done

.lmdb-done:
	cd $(LMDB_PATH)*/libraries/liblmdb && $(MAKE) -j$(THREADS) && $(MAKE) prefix=$(STAGING_PATH)/usr install
	touch .lmdb-done

# Download libfuse
.PHONY: download-libfuse
download-libfuse: .libfuse-obtained

.libfuse-obtained:
	cd $(SRC_PATH) && wget -O fuse-$(LIBFUSE_VER).tar.gz $(LIBFUSE_URL) && tar xf fuse-$(LIBFUSE_VER).tar.gz
	touch .libfuse-obtained

# Compile libfuse
.PHONY: libfuse
libfuse: download-libfuse .libfuse-done

.libfuse-done:
	mkdir -p $(LIBFUSE_PATH)/build && cd $(LIBFUSE_PATH)/build && meson setup --prefix=/usr --buildtype=release .. && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install && chmod u+s $(STAGING_PATH)/usr/bin/fusermount3 && cd .. && \
	cp -R doc/html -T $(STAGING_PATH)/usr/share/doc/fuse-$(LIBFUSE_VER) && install -v -m644 doc/{README.NFS,kernel.txt} $(STAGING_PATH)/usr/share/doc/fuse-$(LIBFUSE_VER)
	touch .libfuse-done

# Download D-Bus
.PHONY: download-dbus
download-dbus: .dbus-obtained

.dbus-obtained:
	cd $(SRC_PATH) && wget -O dbus-$(DBUS_VER).tar.xz $(DBUS_URL) && tar xf dbus-$(DBUS_VER).tar.xz
	touch .dbus-obtained

# Compile D-Bus
dbus: download-dbus .dbus-done
.dbus-done:
	mkdir -p $(DBUS_PATH)/build && cd $(DBUS_PATH)/build && meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback .. && ninja && \
	DESTDIR=$(STAGING_PATH) ninja install && chown 0:18 $(STAGING_PATH)/usr/lib/dbus-daemon-launch-helper || true && \
	chmod 4750 $(STAGING_PATH)/usr/lib/dbus-daemon-launch-helper || true && if [ -e $(STAGING_PATH)/usr/share/doc/dbus ]; then rm -rf $(STAGING_PATH)/usr/share/doc/dbus-$(DBUS_VER) && \
	mv $(STAGING_PATH)/usr/share/doc/dbus{,-$(DBUS_VER)}; fi && rm -rf $(STAGING_PATH)/usr/bin/dbus-launch
	touch .dbus-done

# Download dbus-broker
.PHONY: download-dbus-broker
download-dbus-broker: .dbus-broker-obtained

.dbus-broker-obtained:
	cd $(SRC_PATH) && wget -O dbus-broker-$(DBUS_BROKER_VER).tar.xz $(DBUS_BROKER_URL) && tar xf dbus-broker-$(DBUS_BROKER_VER).tar.xz
	touch .dbus-broker-obtained

# Compile dbus-broker
dbus-broker: download-dbus-broker .dbus-broker-done
.dbus-broker-done:
	mkdir -p $(DBUS_BROKER_PATH)/build && cd $(DBUS_BROKER_PATH)/build && meson setup --prefix=/usr --buildtype=release .. && \
	ninja && DESTDIR=$(STAGING_PATH) ninja install && mv $(STAGING_PATH)/usr/lib/systemd/system/dbus-broker.service $(STAGING_PATH)/usr/lib/systemd/system/dbus.service 
	touch .dbus-broker-done

# Download Kbd
.PHONY: download-kbd
download-kbd: .kbd-obtained

.kbd-obtained:
	cd $(SRC_PATH) && wget -O kbd-$(KBD_VER).tar.gz $(KBD_URL) && tar xf kbd-$(KBD_VER).tar.gz
	touch .kbd-obtained

# Compile Kbd
kbd: download-kbd .kbd-done
.kbd-done:
	cd $(KBD_PATH) && sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure && sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in && \
	./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .kbd-done
