# Enable multi-threaded Bash operation
SHELL = bash
THREADS = $(shell nproc)

# Enable ccache to be used in the build
ifneq ($(shell which ccache 2>/dev/null),)
	CC := ccache gcc
	CXX := ccache g++
	CC.cc := ccache cc
else
	_ := $(info warning: ccache is unavailable; build may be slower)
endif

# Paths used in the build
SRC_PATH = $(shell realpath ./src)
STAGING_PATH = $(shell realpath ./staging)
ISO_STAGING_PATH = $(shell realpath ./iso-staging)
CPIO_STAGING_PATH = $(shell realpath ./cpio-staging)
OUTPUT_PATH = $(shell realpath ./output)

# Dependency checking
LIBRARIES = ./libs.found
EXECUTABLES = ./exes.found
MISSING_LIBS = ./libs.missing

# Every required binary
# arkana's packager is optional, compile the ark.c file to get it
DEPENDENCIES = cmake meson ninja make gcc g++ ld as cc autoconf autoreconf automake sed awk tar wget grep gzip bzip2 xz mksquashfs makeinfo expect glib-mkenums rst2man pod2man curl xorriso mformat install xsltproc help2man

# Targets
.PHONY: all
all: check-deps

# Make all arkanas
.PHONY: arkanas
arkanas:
	for arkana in arkanas/*.mk; do \
		$(MAKE) -f $$arkana || { echo "fatal: failed to make the $$arkana arkana"; exit 1; } \
	done
	$(MAKE) check-libs

	ark -c $(STAGING_PATH) -o $(OUTPUT_PATH)/base.ark || echo "warning: arkana packager not found, not making an arkana package."

# Check dependencies
.PHONY: check-deps
.SILENT: check-deps
check-deps:
	echo "checking dependencies..."
	for dep in $(DEPENDENCIES); do \
		printf "$$dep... "; command -v "$$dep" || { echo "not found"; echo "error: $$dep is required to compile this arkana."; exit 1; } \
	done

	printf "docbook-xml... "; find /usr/share -name "docbookx.dtd" | head -n1 | grep . || { echo "error: docbook-xml is required to compile this arkana."; exit 1; }
	printf "docbook-xsl... "; find /usr/share -name "xsl-stylesheets" | head -n1 | grep . || { echo "error: docbook-xsl is required to compile this arkana."; exit 1; }
	$(MAKE) arkanas

# Check for missing libraries in current packaging
.PHONY: check-libs
.SILENT: check-libs
check-libs:
	if ! [ -f $(STAGING_PATH)/bin/sh ]; then \
	  echo "error: compile a working 'bash' before running this target."; false; \
	fi

	find $(STAGING_PATH)/usr/bin -type f -executable -printf '/usr/bin/%P\n' > $(EXECUTABLES)
	# systemd incorrectly triggers a missing library, ignore it here
	find $(STAGING_PATH)/usr/lib -type f -name "*.so*" ! -name "libsystemd-core-257.so" -printf '/usr/bin/%P\n' > $(LIBRARIES)

	echo "checking missing libraries..."
	> $(MISSING_LIBS)
	while read -r file; do \
	  chroot $(STAGING_PATH) /bin/sh -c "ldd \"$$file\" 2>/dev/null" | grep "not found" | awk -v f="$$file" '{$$1=$$1;print $$0, "in", f}' >> $(MISSING_LIBS) || true; \
	done < $(EXECUTABLES)
	while read -r file; do \
	  chroot $(STAGING_PATH) /bin/sh -c "ldd \"$$file\" 2>/dev/null" | grep "not found" | awk -v f="$$file" '{$$1=$$1;print $$0, "in", f}' >> $(MISSING_LIBS) || true; \
	done < $(LIBRARIES)
	rm $(STAGING_PATH)/dev/null
	if [ -s $(MISSING_LIBS) ]; then \
	  echo "warning: found missing libraries:"; cat $(MISSING_LIBS) | sort -u; \
	else \
	  echo "no missing libraries found."; \
	fi

# Remove build files
.PHONY: clean
clean:
	rm .*-done .*-obtained $(EXECUTABLES) $(LIBRARIES) $(MISSING_LIBS) || true
	rm -rf $(SRC_PATH) $(STAGING_PATH) $(OUTPUT_PATH) $(ISO_STAGING_PATH) $(CPIO_STAGING_PATH)

# There are no test suites in arkanaOS
.PHONY: test
test: check-libs
	qemu-system-x86_64 -cdrom $(OUTPUT_PATH)/arkana.iso -m 1G -vnc :0
