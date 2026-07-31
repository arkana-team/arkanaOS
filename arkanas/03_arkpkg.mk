SHELL = bash
THREADS = $(shell nproc)

SRC_PATH = $(shell realpath ./src)
STAGING_PATH = $(shell realpath ./staging)
OUTPUT_PATH = $(shell realpath ./output)

ARKPKG_URL = https://github.com/debarkak/arkpkg/archive/refs/heads/main.tar.gz
ARKPKG_VER = main
ARKPKG_PATH = $(SRC_PATH)/arkpkg-$(ARKPKG_VER)

.PHONY: all
all: arkpkg

.PHONY: download-arkpkg
download-arkpkg: .arkpkg-obtained

.arkpkg-obtained:
	cd $(SRC_PATH) && wget -O arkpkg-$(ARKPKG_VER).tar.gz $(ARKPKG_URL) && tar xf arkpkg-$(ARKPKG_VER).tar.gz
	touch .arkpkg-obtained

.PHONY: arkpkg
arkpkg: download-arkpkg .arkpkg-done

.arkpkg-done:
	cd $(ARKPKG_PATH) && cargo build --release
	install -Dm755 $(ARKPKG_PATH)/target/release/arkpkg $(STAGING_PATH)/usr/bin/arkpkg
	install -Dm755 $(ARKPKG_PATH)/target/release/arkpkg-build $(STAGING_PATH)/usr/bin/arkpkg-build
	touch .arkpkg-done
