SHELL = bash
THREADS = $(shell nproc)
.NOTPARALLEL:

SRC_PATH = $(shell realpath ./src)
include arkanas/staging-guard.mk
STAGING_PATH = $(shell realpath ./staging)
OUTPUT_PATH = $(shell realpath ./output)

ARKPKG_URL = https://github.com/arkana-team/arkpkg/archive/refs/heads/main.tar.gz
ARKPKG_VER = main
ARKPKG_PATH = $(SRC_PATH)/arkpkg-$(ARKPKG_VER)
ARKCFG_URL = https://github.com/arkana-team/arkcfg/archive/refs/heads/main.tar.gz
ARKCFG_VER = main
ARKCFG_PATH = $(SRC_PATH)/arkcfg-$(ARKCFG_VER)

.PHONY: all
all: arkpkg arkcfg

.PHONY: download-arkpkg
download-arkpkg: .arkpkg-obtained

.arkpkg-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O arkpkg-$(ARKPKG_VER).tar.gz $(ARKPKG_URL) && tar xf arkpkg-$(ARKPKG_VER).tar.gz
	touch .arkpkg-obtained

.PHONY: arkpkg
arkpkg: download-arkpkg .arkpkg-done

.arkpkg-done: arkanas/03_arkpkg.mk
	cd $(ARKPKG_PATH) && CARGO_BUILD_JOBS=1 CARGO_INCREMENTAL=0 cargo build --locked --release
	install -Dm755 $(ARKPKG_PATH)/target/release/arkpkg $(STAGING_PATH)/usr/bin/arkpkg
	install -Dm755 $(ARKPKG_PATH)/target/release/arkpkg-build $(STAGING_PATH)/usr/bin/arkpkg-build
	install -d $(STAGING_PATH)/etc/arkpkg/repos.d
	printf '%s\n' '{"name":"arkanaos","url":"https://arkana-team.github.io/arkpkg-repo"}' > $(STAGING_PATH)/etc/arkpkg/repos.d/arkanaos.json
	chmod 0644 $(STAGING_PATH)/etc/arkpkg/repos.d/arkanaos.json
	touch .arkpkg-done

.PHONY: download-arkcfg
download-arkcfg: .arkcfg-obtained

.arkcfg-obtained:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O arkcfg-$(ARKCFG_VER).tar.gz $(ARKCFG_URL) && tar xf arkcfg-$(ARKCFG_VER).tar.gz
	touch .arkcfg-obtained

.PHONY: arkcfg
arkcfg: download-arkcfg .arkcfg-done

.arkcfg-done: arkanas/03_arkpkg.mk
	cd $(ARKCFG_PATH) && CARGO_BUILD_JOBS=1 CARGO_INCREMENTAL=0 cargo build --locked --release
	install -Dm755 $(ARKCFG_PATH)/target/release/arkcfg $(STAGING_PATH)/usr/bin/arkcfg
	touch .arkcfg-done
