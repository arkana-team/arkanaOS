# Enable multi-threaded Bash operation
SHELL = bash
THREADS = $(shell nproc)

# Build the Arkana toolchain?
BUILD_TOOLCHAIN = true
TOOLCHAIN_TARGETS = gcc-compilers binutils meson ninja make autoconf cmake gc libarchive guile libuv libxml2 libtool expat python3 perl automake

# Paths used in the build
SRC_PATH = $(shell realpath ./src)
STAGING_PATH = $(shell realpath ./staging)
OUTPUT_PATH = $(shell realpath ./output)

# Binutils
# It downloads slowly. Thanks, GNU.
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/binutils.html
BINUTILS_URL = https://ftpmirror.gnu.org/gnu/binutils/binutils-2.45.tar.gz
BINUTILS_VER = 2.45
BINUTILS_PATH = $(SRC_PATH)/binutils-$(BINUTILS_VER)

# GCC (pre-compiled beforehands, install only)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/gcc.html
GCC_URL = None 
GCC_VER = 15.2.0
GCC_PATH = $(SRC_PATH)/gcc-$(GCC_VER)

# Meson (alternative to GNU Make)
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/meson.html
MESON_URL = https://github.com/mesonbuild/meson/releases/download/1.8.3/meson-1.8.3.tar.gz
MESON_VER = 1.8.3
MESON_PATH = $(SRC_PATH)/meson-$(MESON_VER)

# Ninja (used in Meson builds)
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/ninja.html
NINJA_URL = https://github.com/ninja-build/ninja/archive/refs/tags/v1.13.1.tar.gz
NINJA_VER = 1.13.1
NINJA_PATH = $(SRC_PATH)/ninja-$(NINJA_VER)

# Make (the usual)
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter06/make.html
MAKE_URL = https://ftpmirror.gnu.org/gnu/make/make-4.4.1.tar.gz
MAKE_VER = 4.4.1
MAKE_PATH = $(SRC_PATH)/make-$(MAKE_VER)

# Autoconf (extensions for GNU Make)
# URL: https://ftpmirror.gnu.org/gnu/autoconf/ (w/o instructions)
AUTOCONF_URL = https://ftpmirror.gnu.org/gnu/autoconf/autoconf-2.72.tar.gz
AUTOCONF_VER = 2.72
AUTOCONF_PATH = $(SRC_PATH)/autoconf-$(AUTOCONF_VER)

# CMake (build system generator for Make/Meson)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/cmake.html
CMAKE_URL = https://github.com/Kitware/CMake/releases/download/v4.1.0/cmake-4.1.0.tar.gz
CMAKE_VER = 4.1.0
CMAKE_PATH = $(SRC_PATH)/cmake-$(CMAKE_VER)

# GC
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/gc.html
GC_URL = https://github.com/ivmai/bdwgc/releases/download/v8.2.8/gc-8.2.8.tar.gz
GC_VER = 8.2.8
GC_PATH = $(SRC_PATH)/gc-$(GC_VER)

# Libarchive
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libarchive.html
LIBARCHIVE_URL = https://github.com/libarchive/libarchive/releases/download/v3.8.1/libarchive-3.8.1.tar.gz
LIBARCHIVE_VER = 3.8.1
LIBARCHIVE_PATH = $(SRC_PATH)/libarchive-$(LIBARCHIVE_VER)

# Guile
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/guile.html
GUILE_URL = https://ftpmirror.gnu.org/gnu/guile/guile-3.0.10.tar.gz
GUILE_VER = 3.0.10
GUILE_PATH = $(SRC_PATH)/guile-$(GUILE_VER)

# Libuv
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libuv.html
LIBUV_URL = https://dist.libuv.org/dist/v1.51.0/libuv-v1.51.0.tar.gz
LIBUV_VER = 1.51.0
LIBUV_PATH = $(SRC_PATH)/libuv-v$(LIBUV_VER)

# Libxml2
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/libxml2.html
LIBXML2_URL = https://download.gnome.org/sources/libxml2/2.14/libxml2-2.14.5.tar.xz
LIBXML2_VER = 2.14.5
LIBXML2_PATH = $(SRC_PATH)/libxml2-$(LIBXML2_VER)

# Libtool
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/libtool.html
LIBTOOL_URL = https://ftpmirror.gnu.org/gnu/libtool/libtool-2.5.4.tar.gz
LIBTOOL_VER = 2.5.4
LIBTOOL_PATH = $(SRC_PATH)/libtool-$(LIBTOOL_VER)

# Expat
EXPAT_URL = https://github.com/libexpat/libexpat/releases/download/R_2_7_1/expat-2.7.1.tar.gz
EXPAT_VER = 2.7.1
EXPAT_PATH = $(SRC_PATH)/expat-$(EXPAT_VER)

# Python3 (dependency of meson)
# URL: https://www.linuxfromscratch.org/blfs/view/systemd/general/python3.html
PYTHON3_URL = https://www.python.org/ftp/python/3.13.7/Python-3.13.7.tar.xz
PYTHON3_VER = 3.13.7
PYTHON3_PATH = $(SRC_PATH)/Python-$(PYTHON3_VER)

# Perl (dependency of autoconf)
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/perl.html
PERL_URL = https://www.cpan.org/src/5.0/perl-5.42.0.tar.gz
PERL_VER = 5.42.0
PERL_PATH = $(SRC_PATH)/perl-$(PERL_VER)

# Automake
# URL: https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/automake.html
AUTOMAKE_URL = https://ftpmirror.gnu.org/gnu/automake/automake-1.18.1.tar.gz
AUTOMAKE_VER = 1.18.1
AUTOMAKE_PATH = $(SRC_PATH)/automake-$(AUTOMAKE_VER)

# Targets
all:
	@if [ "$(BUILD_TOOLCHAIN)" = "true" ]; then \
		make -f arkanas/03_toolchain.mk $(TOOLCHAIN_TARGETS) || exit $$?; \
	else \
		echo "note: arkana toolchain is disabled, set BUILD_TOOLCHAIN=true to enable it"; \
		exit 0; \
	fi

# Install the GCC compilers
gcc-compilers: .gcc-compilers-done
.gcc-compilers-done:
	# GCC has been pre-compiled before in 01_base.mk to obtain the libgcc_s and libstdc++, the compilers can be installed directly.
	cd $(GCC_PATH)/build && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .gcc-compilers-done

# Download binutils
download-binutils: .binutils-obtained
.binutils-obtained:
	cd $(SRC_PATH) && wget -O binutils-$(BINUTILS_VER).tar.gz $(BINUTILS_URL) && tar xf binutils-$(BINUTILS_VER).tar.gz
	touch .binutils-obtained

# Compile binutils
binutils: download-binutils .binutils-done
.binutils-done:
	cd $(BINUTILS_PATH) && ./configure --prefix=/usr --enable-gold --enable-ld=default --enable-plugins --enable-shared --disable-werror --enable-64bit-bfd --with-system-zlib && $(MAKE) tooldir=/usr -j$(THREADS) && $(MAKE) tooldir=/usr DESTDIR=$(STAGING_PATH) install
	touch .binutils-done

# Download meson
download-meson: .meson-obtained
.meson-obtained:
	cd $(SRC_PATH) && wget -O meson-$(MESON_VER).tar.gz $(MESON_URL) && tar xf meson-$(MESON_VER).tar.gz
	touch .meson-obtained

# Compile meson
meson: download-meson .meson-done
.meson-done:
	cd $(MESON_PATH) && /usr/bin/pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $$PWD && \
	/usr/bin/pip3 install --no-index --target=$(STAGING_PATH)/usr --find-links dist meson && \
	install -Dm644 data/shell-completions/bash/meson $(STAGING_PATH)/usr/share/bash-completion/completions/meson
	touch .meson-done

# Download ninja
download-ninja: .ninja-obtained
.ninja-obtained:
	cd $(SRC_PATH) && wget -O ninja-$(NINJA_VER).tar.gz $(NINJA_URL) && tar xf ninja-$(NINJA_VER).tar.gz
	touch .ninja-obtained

# Compile ninja
ninja: download-ninja .ninja-done
.ninja-done:
	cd $(NINJA_PATH) && sed -i '/int Guess/a int   j = 0;char* jobs = getenv( "NINJAJOBS" );if ( jobs != NULL ) j = atoi( jobs );if ( j > 0 ) return j;' src/ninja.cc && \
	python3 configure.py --bootstrap --verbose && install -m755 ninja $(STAGING_PATH)/usr/bin/ && \
	install -Dm644 misc/bash-completion $(STAGING_PATH)/usr/share/bash-completion/completions/ninja
	touch .ninja-done

# Download make
download-make: .make-obtained
.make-obtained:
	cd $(SRC_PATH) && wget -O make-$(MAKE_VER).tar.gz $(MAKE_URL) && tar xf make-$(MAKE_VER).tar.gz
	touch .make-obtained

# Does this shadow any internal names?
# Compile make
make: download-make .make-done
.make-done:
	# You DO NEED make to build make. Make is compiling itself, funny, I know.
	cd $(MAKE_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .make-done

# Download automake
download-autoconf: .autoconf-obtained
.autoconf-obtained:
	cd $(SRC_PATH) && wget -O autoconf-$(AUTOCONF_VER).tar.gz $(AUTOCONF_URL) && tar xf autoconf-$(AUTOCONF_VER).tar.gz
	touch .autoconf-obtained

# Compile automake
autoconf: download-autoconf .autoconf-done
.autoconf-done:
	cd $(AUTOCONF_PATH) && sed '361 s/{/\\{/' -i bin/autoscan.in && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .autoconf-done

# Download cmake
download-cmake: .cmake-obtained
.cmake-obtained:
	cd $(SRC_PATH) && wget -O cmake-$(CMAKE_VER).tar.gz $(CMAKE_URL) && tar xf cmake-$(CMAKE_VER).tar.gz
	touch .cmake-obtained

# Compile cmake
cmake: download-cmake .cmake-done
.cmake-done:
	cd $(CMAKE_PATH) && sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake && ./bootstrap --prefix=/usr --system-libs --mandir=/share/man --no-system-jsoncpp \
	--no-system-cppdap --no-system-librhash --docdir=/share/doc/cmake-$(CMAKE_VER).tar.gz && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .cmake-done

# Download gc
download-gc: .gc-obtained
.gc-obtained:
	cd $(SRC_PATH) && wget -O gc-$(GC_VER).tar.gz $(GC_URL) && tar xf gc-$(GC_VER).tar.gz
	touch .gc-obtained

# Compile gc
gc: download-gc .gc-done
.gc-done:
	cd $(GC_PATH) && ./configure --prefix=/usr --enable-cplusplus --docdir=/usr/share/doc/gc-$(GC_VER) && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .gc-done

# Download libarchive
download-libarchive: .libarchive-obtained
.libarchive-obtained:
	cd $(SRC_PATH) && wget -O libarchive-$(LIBARCHIVE_VER).tar.gz $(LIBARCHIVE_URL) && tar xf libarchive-$(LIBARCHIVE_VER).tar.gz
	touch .libarchive-obtained

# Compile libarchive
libarchive: download-libarchive .libarchive-done
.libarchive-done:
	cd $(LIBARCHIVE_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libarchive-done

# Download guile
download-guile: .guile-obtained
.guile-obtained:
	cd $(SRC_PATH) && wget -O guile-$(GUILE_VER).tar.gz $(GUILE_URL) && tar xf guile-$(GUILE_VER).tar.gz
	touch .guile-obtained

# Compile guile (this takes a LONG time!)
guile: download-guile .guile-done
.guile-done:
	cd $(GUILE_PATH) && ./configure --prefix=/usr --docdir=/usr/share/doc/guile-$(GUILE_VER) && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && \
	mkdir -p $(STAGING_PATH)/usr/share/gdb/auto-load/usr/lib && mv $(STAGING_PATH)/usr/lib/libguile-*-gdb.scm \
	$(STAGING_PATH)/usr/share/gdb/auto-load/usr/lib
	touch .guile-done

# Download libuv
download-libuv: .libuv-obtained
.libuv-obtained:
	cd $(SRC_PATH) && wget -O libuv-$(LIBUV_VER).tar.gz $(LIBUV_URL) && tar xf libuv-$(LIBUV_VER).tar.gz
	touch .libuv-obtained

# Compile libuv
libuv: download-libuv .libuv-done
.libuv-done:
	cd $(LIBUV_PATH) && sh autogen.sh && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libuv-done

# Download libxml2
download-libxml2: .libxml2-obtained
.libxml2-obtained:
	cd $(SRC_PATH) && wget -O libxml2-$(LIBXML2_VER).tar.xz $(LIBXML2_URL) && tar xf libxml2-$(LIBXML2_VER).tar.xz
	touch .libxml2-obtained

# Compile libxml2
libxml2: download-libxml2 .libxml2-done
.libxml2-done:
	cd $(LIBXML2_PATH) && ./configure --prefix=/usr --sysconfdir=/etc --with-history PYTHON=/usr/bin/python3 --docdir=/usr/share/doc/libxml2-$(LIBXML2_VER) && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && sed '/libs=/s/xml2.*/xml2"/' -i $(STAGING_PATH)/usr/bin/xml2-config
	touch .libxml2-done

# Download libtool
download-libtool: .libtool-obtained
.libtool-obtained:
	cd $(SRC_PATH) && wget -O libtool-$(LIBTOOL_VER).tar.gz $(LIBTOOL_URL) && tar xf libtool-$(LIBTOOL_VER).tar.gz
	touch .libtool-obtained

# Compile libtool
libtool: download-libtool .libtool-done
.libtool-done:
	cd $(LIBTOOL_PATH) && ./configure --prefix=/usr && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .libtool-done

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

# Download python3
download-python3: .python3-obtained
.python3-obtained:
	cd $(SRC_PATH) && wget -O python-$(PYTHON3_VER).tar.xz $(PYTHON3_URL) && tar xf python-$(PYTHON3_VER).tar.xz
	touch .python3-obtained

# Compile python3
python3: download-python3 .python3-done
.python3-done:
	cd $(PYTHON3_PATH) && CXX="/usr/bin/g++" ./configure --prefix=/usr --enable-shared --with-system-expat --enable-optimizations && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && \
	ln -sf /usr/bin/python3 $(STAGING_PATH)/usr/bin/python && chroot $(STAGING_PATH) python3 -m ensurepip && \
	ln -sf /usr/bin/pip $(STAGING_PATH)/usr/bin/pip3
	touch .python3-done

# Download perl
download-perl: .perl-obtained
.perl-obtained:
	cd $(SRC_PATH) && wget -O perl-$(PERL_VER).tar.gz $(PERL_URL) && tar xf perl-$(PERL_VER).tar.gz
	touch .perl-obtained

# Compile perl
perl: download-perl .perl-done
.perl-done:
	cd $(PERL_PATH) && sh Configure -des -D prefix=/usr -D vendorprefix=/usr -D privlib=/usr/lib/perl5/$(basename $(PERL_VER))/core_perl \
	-D archlib=/usr/lib/perl5/$(basename $(PERL_VER))/core_perl -D sitelib=/usr/lib/perl5/$(basename $(PERL_VER))/site_perl \
	-D sitearch=/usr/lib/perl5/$(basename $(PERL_VER))/site_perl -D vendorlib=/usr/lib/perl5/$(basename $(PERL_VER))/vendor_perl \
	-D vendorarch=/usr/lib/perl5/$(basename $(PERL_VER))/vendor_perl -D man1dir=/usr/share/man/man1 -D man3dir=/usr/share/man/man3 \
	-D pager="/usr/bin/less -isR" -D useshrplib -D usethreads && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .perl-done

# Download automake
download-automake: .automake-obtained
.automake-obtained:
	cd $(SRC_PATH) && wget -O automake-$(AUTOMAKE_VER).tar.gz $(AUTOMAKE_URL) && tar xf automake-$(AUTOMAKE_VER).tar.gz
	touch .automake-obtained

# Compile automake
automake: download-automake .automake-done
.automake-done:
	cd $(AUTOMAKE_PATH) && ./configure --prefix=/usr --docdir=/usr/share/doc/automake-$(AUTOMAKE_PATH) && $(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install
	touch .automake-done
