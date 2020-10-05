FROM archlinux/base

# makepkg cannot (and should not) be run as root:
RUN useradd -m notroot

# Generally, refreshing without sync'ing is discouraged, but we've a clean
# environment here.
RUN pacman -Sy --noconfirm archlinux-keyring reflector && \
    reflector --verbose --country 'Germany' -l 20 -p http --sort rate --save /etc/pacman.d/mirrorlist && \
    pacman -Sy --noconfirm base-devel git && \
    pacman -Syu --noconfirm

# Allow notroot to run stuff as root (to install dependencies):
RUN echo "notroot ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/notroot

# Continue execution (and CMD) as notroot:
WORKDIR /home/notroot

# Auto-fetch GPG keys (for checking signatures):
RUN mkdir .gnupg && \
    touch .gnupg/gpg.conf && \
    echo "keyserver-options auto-key-retrieve" > .gnupg/gpg.conf

# Install yay (for building AUR dependencies):
# RUN git clone https://aur.archlinux.org/yay-bin.git && \
#     cd yay-bin && \
#     makepkg --noconfirm --syncdeps --rmdeps --install --clean

USER notroot
RUN git clone https://aur.archlinux.org/pikaur.git pikaur || (rm -rf pikaur && git clone https://aur.archlinux.org/pikaur.git pikaur) && \
    pushd pikaur && \
    makepkg --noconfirm --syncdeps --rmdeps --install --clean && \
    popd && \
    rm -rf pikaur
USER root

ADD run.sh /
RUN chmod +x /run.sh

# Build the package
ENV PKGDEST=/pkg
WORKDIR "$PKGDEST"
VOLUME "$PKGDEST"
ENTRYPOINT ["/run.sh"]
