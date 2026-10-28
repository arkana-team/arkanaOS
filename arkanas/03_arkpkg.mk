SHELL = bash
THREADS ?= $(shell nproc)
.NOTPARALLEL:

SRC_PATH = $(shell realpath ./src)
include arkanas/staging-guard.mk
STAGING_PATH = $(shell realpath ./staging)
OUTPUT_PATH = $(shell realpath ./output)

ARKPKG_VER = ecc4fe1983e295a9efe71ec27040a44f9d603752
ARKPKG_URL = https://github.com/arkana-team/arkpkg/archive/$(ARKPKG_VER).tar.gz
ARKPKG_PATH = $(SRC_PATH)/arkpkg-$(ARKPKG_VER)
ARKCFG_URL = https://github.com/arkana-team/arkcfg/archive/refs/heads/main.tar.gz
ARKCFG_VER = main
ARKCFG_PATH = $(SRC_PATH)/arkcfg-$(ARKCFG_VER)
ARKUP_VER = 2df9786e00cf8a82b9ceecdae295972692ee653a
ARKUP_URL = https://github.com/arkana-team/arkup/archive/$(ARKUP_VER).tar.gz
ARKUP_SHA256 = 3d898cafde63eca84e9195cc65ffb1f7e19b1afcb6cb5da1934df6ca3e989d95
ARKUP_PATH = $(SRC_PATH)/arkup-$(ARKUP_VER)

.PHONY: all
all: arkpkg arkcfg arkup

.PHONY: download-arkpkg
download-arkpkg: .arkpkg-obtained-$(ARKPKG_VER)

.arkpkg-obtained-$(ARKPKG_VER):
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O arkpkg-$(ARKPKG_VER).tar.gz $(ARKPKG_URL) && tar xf arkpkg-$(ARKPKG_VER).tar.gz
	touch .arkpkg-obtained-$(ARKPKG_VER)

.PHONY: arkpkg
arkpkg: download-arkpkg .arkpkg-done-$(ARKPKG_VER)

.arkpkg-done-$(ARKPKG_VER): arkanas/03_arkpkg.mk
	cd $(ARKPKG_PATH) && CARGO_BUILD_JOBS=1 CARGO_INCREMENTAL=0 cargo build --locked --release
	install -Dm755 $(ARKPKG_PATH)/target/release/arkpkg $(STAGING_PATH)/usr/bin/arkpkg
	install -Dm755 $(ARKPKG_PATH)/target/release/arkpkg-build $(STAGING_PATH)/usr/bin/arkpkg-build
	install -d $(STAGING_PATH)/etc/arkpkg/repos.d
	printf '%s\n' '{"name":"arkanaos","url":"https://arkana-team.github.io/arkpkg-repo"}' > $(STAGING_PATH)/etc/arkpkg/repos.d/arkanaos.json
	chmod 0644 $(STAGING_PATH)/etc/arkpkg/repos.d/arkanaos.json
	touch .arkpkg-done-$(ARKPKG_VER)

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

.PHONY: download-arkup verify-arkup-source arkup
download-arkup: verify-arkup-source

$(SRC_PATH)/arkup-$(ARKUP_VER).tar.gz:
	cd $(SRC_PATH) && wget --tries=5 --timeout=30 -O arkup-$(ARKUP_VER).tar.gz.tmp $(ARKUP_URL)
	cd $(SRC_PATH) && echo '$(ARKUP_SHA256)  arkup-$(ARKUP_VER).tar.gz.tmp' | sha256sum -c -
	cd $(SRC_PATH) && mv arkup-$(ARKUP_VER).tar.gz.tmp arkup-$(ARKUP_VER).tar.gz

verify-arkup-source: $(SRC_PATH)/arkup-$(ARKUP_VER).tar.gz
	cd $(SRC_PATH) && echo '$(ARKUP_SHA256)  arkup-$(ARKUP_VER).tar.gz' | sha256sum -c -

arkup: download-arkup $(STAGING_PATH)/usr/bin/arkup

$(STAGING_PATH)/usr/bin/arkup: arkanas/03_arkpkg.mk $(SRC_PATH)/arkup-$(ARKUP_VER).tar.gz
	cd $(SRC_PATH) && echo '$(ARKUP_SHA256)  arkup-$(ARKUP_VER).tar.gz' | sha256sum -c -
	rm -rf $(ARKUP_PATH)
	cd $(SRC_PATH) && tar xf arkup-$(ARKUP_VER).tar.gz
	test -f $(ARKUP_PATH)/Cargo.toml && test -f $(ARKUP_PATH)/Cargo.lock
	cd $(ARKUP_PATH) && CARGO_BUILD_JOBS=1 CARGO_INCREMENTAL=0 cargo build --locked --release
	install -Dm755 $(ARKUP_PATH)/target/release/arkup $(STAGING_PATH)/usr/bin/arkup
