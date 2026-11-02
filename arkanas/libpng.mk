# Shared, checksum-verified libpng build used by both graphics and ISO stages.
LIBPNG_URL = https://downloads.sourceforge.net/libpng/libpng-1.6.50.tar.xz
LIBPNG_PATCH_URL = https://downloads.sourceforge.net/sourceforge/libpng-apng/libpng-1.6.47-apng.patch.gz
LIBPNG_VER = 1.6.50
LIBPNG_SHA256 = 4df396518620a7aa3651443e87d1b2862e4e88cad135a8b93423e01706232307
LIBPNG_PATCH_SHA256 = 5b086fafe7e12784b28693e19a5bcf68677a8c52947115712a56c3d123944f6f
LIBPNG_PATH = $(SRC_PATH)/libpng-$(LIBPNG_VER)

download-libpng: .libpng-$(LIBPNG_VER)-obtained-verified
.libpng-$(LIBPNG_VER)-obtained-verified:
	set -euo pipefail; cd $(SRC_PATH); \
	archive="libpng-$(LIBPNG_VER).tar.xz"; patch_file="libpng-apng.patch.gz"; \
	wget --tries=5 --timeout=30 -O "$$archive" "$(LIBPNG_URL)"; \
	printf '%s  %s\n' '$(LIBPNG_SHA256)' "$$archive" | sha256sum -c -; \
	curl -fsSL --retry 3 --connect-timeout 20 -o "$$patch_file" "$(LIBPNG_PATCH_URL)"; \
	printf '%s  %s\n' '$(LIBPNG_PATCH_SHA256)' "$$patch_file" | sha256sum -c -; \
	gzip -t "$$patch_file"; rm -rf "$(LIBPNG_PATH)"; tar xf "$$archive"; \
	gzip -dc "$$patch_file" | (cd "$(LIBPNG_PATH)" && patch --batch --forward -p1); \
	rm -f "$$patch_file"; touch "$@"

# BFD is needed for libpng's PNG16_0 symbol versions, which Cairo requires.
libpng: download-libpng .libpng-$(LIBPNG_VER)-bfd-done
.libpng-$(LIBPNG_VER)-bfd-done:
	cd $(LIBPNG_PATH) && { $(MAKE) distclean >/dev/null 2>&1 || true; } && \
	CFLAGS="-O2 -std=gnu17" LDFLAGS="-fuse-ld=bfd" ./configure --prefix=/usr --disable-static && \
	$(MAKE) -j$(THREADS) && $(MAKE) DESTDIR=$(STAGING_PATH) install && \
	mkdir -p $(STAGING_PATH)/usr/share/doc/libpng-$(LIBPNG_VER) && cp README libpng-manual.txt $(STAGING_PATH)/usr/share/doc/libpng-$(LIBPNG_VER)
	touch .libpng-$(LIBPNG_VER)-bfd-done
