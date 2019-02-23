FROM debian:stretch-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    debootstrap \
    squashfs-tools \
    dosfstools \
    memtest86+ \
    parted \
    pciutils \
    syslinux \
    syslinux-common \
    && rm -rf /var/lib/apt/lists/*

# This is for Grub building
RUN apt-get update && apt-get install -y --no-install-recommends \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools

COPY xixer.sh syslinux.cfg /xixer/

WORKDIR /xixer

ENTRYPOINT ["/xixer/xixer.sh"]
