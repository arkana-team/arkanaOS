FROM archlinux:latest

ENV PACMAN_NOCONFIRM=1
ENV MAKEFLAGS="-j$(nproc)"
ENV NINJAFLAGS="-j$(nproc)"
ENV CFLAGS="-O2 -pipe"
ENV CXXFLAGS="-O2 -pipe"
ENV LDFLAGS="-fuse-ld=mold -Wl,-O1 --as-needed"
ENV RUSTFLAGS="-C link-arg=-fuse-ld=mold"
ENV PATH="/usr/lib/ccache/bin:$PATH"
ENV CCACHE_COMPRESS=1
ENV CCACHE_SLOPPINESS=include_file_ctime,include_file_mtime,time_macros

# If set to 1, the builder won't exit on success, and you'll be able to make further changes.
ENV ARKANA_NO_SUCCESSFUL_EXIT=0

RUN yes | pacman -Syu --noconfirm && \
    yes | pacman -S --noconfirm --needed \
        base-devel \
        git \
        sudo \
        rsync \
        squashfs-tools \
        xorriso \
        grub \
        dosfstools \
        mtools \
        libisoburn \
        strace \
        wget \
        ccache \
        mold \
        meson \
        ninja \
        cmake \
        docbook-xml \
        docbook-xsl \
        gperf \
        python-jinja \
        libaio \
        libndp \
        polkit \
        libnewt \
        libnvme \
        glib2-devel \
        lzip \
        python-pip \
        python-setuptools \
        help2man \
        xorgproto \
        xtrans \
        pixman \
        libxkbfile \
        libxfont2 \
        xorg-font-util \
        libxcvt \
        mesa \
        libepoxy \
        libmd \
        glslang \
        rust \
        rust-bindgen \
        libclc \
        python-mako \
        python-yaml \
        llvm \
        spirv-llvm-translator \
        libxfixes \
        xorg-xrandr \
        cbindgen \
        xorg-mkfontscale \
        xorg-server-devel \
        libevdev \
        mtdev \
        pango \
        libxaw \
        libwacom \
        gtk4 \
        imlib2 \
        gobject-introspection \
        cargo-c \
        nasm \
        python-docutils \
        libinput \
        wayland-protocols \
        seatd \
        libpipewire \
        freerdp \
        xcb-util-cursor \
        expect \
        bc \
        efibootmgr \
        vulkan-headers \
        cpio \
        dbus-glib

RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
WORKDIR /build

# Add a user that D-Bus expects during installation phase
RUN sudo groupadd -r messagebus 2>/dev/null || true
RUN sudo useradd -r -g messagebus -d /var/run/dbus -s /bin/false messagebus 2>/dev/null || true

COPY --chown=builder:builder . /build/arkana

WORKDIR /build/arkana

RUN sudo ln -sf /bin/true /sbin/ldconfig && \
    echo 'tries = 5' | sudo tee -a /etc/wgetrc && \
    echo 'timeout = 30' | sudo tee -a /etc/wgetrc && \
    echo 'read_timeout = 30' | sudo tee -a /etc/wgetrc

CMD ["bash", "-c", "set +e; sudo make; ret=$?; \
if [ $ret -eq 130 ]; then \
    echo -ne '\n*** BUILD INTERRUPTED — ENTERING DEBUGGING SHELL ***\nThe build process was interrupted (CTRL+C).\nRun `sudo make` to continue building.\nCAUTION: Exiting this shell will cause the build progress to be lost!\n\n'; \
    exec bash; \
elif [ $ret -ne 0 ]; then \
    echo -ne '\n*** BUILD FAILED — ENTERING DEBUGGING SHELL ***\nThe build process encountered an error and cannot continue.\nFix any errors and run `sudo make` again\nCAUTION: Exiting this shell will cause the build progress to be lost!\n\n'; \
    exec bash; \
elif [ ${ARKANA_NO_SUCCESSFUL_EXIT:-0} -eq 1 ]; then \
    exec bash; \
fi"]
