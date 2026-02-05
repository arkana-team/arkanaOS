# Enable multi-threaded Bash operation
SHELL = bash
THREADS = $(shell nproc)
DOCKER = $(shell \
	if [ -f /.dockerenv ]; then echo true; \
	elif [ -n "$$container" ]; then echo true; \
	elif grep -qaE '(docker|containerd)' /proc/1/cgroup 2>/dev/null; then echo true; \
	elif grep -qx '0::/' /proc/1/cgroup 2>/dev/null; then echo true; \
	else echo false; fi)

ifeq ($(DOCKER),false)
$(error must run in Docker container - use ./build.sh to start build)
endif

# Enable ccache to be used in the build
ifneq ($(shell which ccache 2>/dev/null),)
	CC := ccache gcc
	CXX := ccache g++
	CC.cc := ccache cc
	CXX.cc := ccache c++
	CLANG := ccache clang
	CLANGXX := ccache clang++
else
	_ := $(warning ccache is unavailable; build may be slower)
endif

GCC_VER := $(shell gcc -dumpversion | cut -d'.' -f1)
ifeq ($(shell test $(GCC_VER) -ge 15; echo $$?), 0)
	CFLAGS := -std=gnu17  # Must set or the C compiler will hate you. C++ compilers will discard it.
	_ := $(info note: GCC 15 compatibility mode set)
endif
CFLAGS += -mtls-dialect=gnu  # If not set, libgallium will use GLIBC_ABI_GNU2_TLS, but Glibc REFUSES to acknowledge that "gnu2" is available, and we tried hard. It couldn't be done.
export CFLAGS CC CXX CLANG CLANGXX SHELL

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

# Targets
.PHONY: all
all: arkanas

# Make all arkanas
.PHONY: arkanas
arkanas:
	mkdir -p $(SRC_PATH) $(STAGING_PATH) $(ISO_STAGING_PATH) $(CPIO_STAGING_PATH) $(OUTPUT_PATH)
	for arkana in arkanas/*.mk; do \
		$(MAKE) -f $$arkana || { echo "fatal: failed to make the $$arkana arkana"; exit 1; } \
	done
	$(MAKE) check-libs

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

# There are no test suites in arkanaOS, but we can run QEMU to start the built system.
.PHONY: test
.IGNORE: test check-libs
test: check-libs
	qemu-system-x86_64 -cdrom $(OUTPUT_PATH)/arkana.iso -m 1G -vnc :0
