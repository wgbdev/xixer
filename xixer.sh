#!/usr/bin/env bash

die() { echo -e "$@" ; exit 1; }

# defaults
XIXER_HOSTNAME="xixer-$(sha1sum <<< ${RANDOM} | head -c4)"
XIXER_ROOT_PASSWORD="xixer"
DEB_ARCH="amd64"
DEB_SUITE="stretch"
DEB_MIRROR="http://ftp.us.debian.org/debian/"

TARGET_PACKAGES=(
  ca-certificates
  curl
  linux-image-${DEB_ARCH}
  live-boot
  nmap
  openssh-client
  parted
  squashfs-tools
  systemd-sysv
  tcpdump
  unzip
  xz-utils
  zip
)

for opt in "$@"; do
  case ${opt} in
    --hostname=*)
      XIXER_HOSTNAME="${opt#*=}" ; shift ;;
    --password=*)
      XIXER_ROOT_PASSWORD="${opt#*=}" ; shift ;;
    --usb-device=*)
      XIXER_USB_DEV="${opt#*=}" ; shift ;;
    --arch=*)
      DEB_ARCH="${opt#*=}" ; shift ;;
    --suite=*)
      DEB_SUITE="${opt#*=}" ; shift ;;
    --mirror=*)
      DEB_MIRROR="${opt#*=}" ; shift ;;
  esac
done

[[ -n ${XIXER_USB_DEV} ]] || \
  die "--usb-device=<device name> is required"

XIXER_ROOT=${PWD}/xixer-root
mkdir -p ${XIXER_ROOT} || \
  die "Failed to create ${XIXER_ROOT}!"

echo
echo "Running "
echo "     debootstrap --arch=${DEB_ARCH} --variant=minbase ${DEB_SUITE} ${XIXER_ROOT} ${DEB_MIRROR}"
echo

debootstrap \
  --arch=${DEB_ARCH} --variant=minbase \
  ${DEB_SUITE} ${XIXER_ROOT} ${DEB_MIRROR} || \
    die "debootstrap failed!"

echo
echo "Running "
echo "     chroot ${XIXER_ROOT} /bin/bash"
echo "======================================"
echo

chroot ${XIXER_ROOT} /bin/bash << EOF
set -xe
export DEBIAN_FRONTEND=noninteractive
echo ${XIXER_HOSTNAME} > /etc/hostname
chpasswd <<< "root:${XIXER_ROOT_PASSWORD}"
mount -t tmpfs none /dev/shm
rm -vf /etc/apt/sources.list /etc/apt/sources.list.d/*.list
cat > /etc/apt/sources.list <<EOF_SOURCES
deb http://ftp.us.debian.org/debian/ stretch main contrib non-free
deb http://security.debian.org/debian-security stretch/updates main contrib non-free
deb http://ftp.us.debian.org/debian/ stretch-updates main contrib non-free
EOF_SOURCES
echo
echo "Running "
echo "     apt-get update"
echo
apt-get update
echo
echo "Running "
echo "     apt-get install --no-install-recommends -yq ${TARGET_PACKAGES[@]}"
echo
apt-get install --no-install-recommends -yq ${TARGET_PACKAGES[@]}
echo "Running "
echo "     clean"
echo
apt-get clean
umount /dev/shm
rm -rf /var/lib/apt/lists/*
EOF


[[ $? -eq 0 ]] || \
  die "Failed to configure root filesystem!"

echo
echo "Created: /etc/apt/sources.list =["
cat /etc/apt/sources.list
echo "]"

echo
echo "Running "
echo "     parted /dev/${XIXER_USB_DEV} --script -- 'mklabel msdos mkpart primary fat32 0% 100% set 1 boot on'"
echo

parted /dev/${XIXER_USB_DEV} --script -- \
  'mklabel msdos mkpart primary fat32 0% 100% set 1 boot on' || \
    die "Failed to partition /dev/${XIXER_USB_DEV}!"

echo
echo "Running "
echo "     mkdosfs -F 32 -I /dev/${XIXER_USB_DEV}1"
echo

mkdosfs -F 32 -I /dev/${XIXER_USB_DEV}1 || \
  die "Failed to format /dev/${XIXER_USB_DEV}1!"

echo
echo "Running "
echo "     syslinux -i /dev/${XIXER_USB_DEV}1"
echo

syslinux -i /dev/${XIXER_USB_DEV}1 || \
  die "Failed to install syslinux!"

echo
echo "Running "
echo "     dd conv=notrunc bs=440 count=1 if=/usr/lib/syslinux/mbr/mbr.bin of=/dev/${XIXER_USB_DEV}"
echo

dd conv=notrunc bs=440 count=1 if=/usr/lib/syslinux/mbr/mbr.bin \
  of=/dev/${XIXER_USB_DEV} || \
    die "Failed to install syslinux MBR to ${XIXER_USB_DEV}!"

echo
echo "Running "
echo "     mount /dev/${XIXER_USB_DEV}1 /mnt && mkdir /mnt/live"
echo

mount /dev/${XIXER_USB_DEV}1 /mnt && mkdir /mnt/live || \
  die "Failed to mount ${XIXER_USB_DEV}!"

echo
echo "Running "
echo "     mksquashfs . /mnt/live/filesystem.squashfs -e boot -noappend)"
echo

(cd ${XIXER_ROOT} && \
  mksquashfs . /mnt/live/filesystem.squashfs -e boot -noappend) || \
    die "Failed to create squashfs!"

echo
echo "Running "
echo "        cp -v ${XIXER_ROOT}/boot/vmlinuz* /mnt/live/vmlinuz "
echo

cp -v ${XIXER_ROOT}/boot/vmlinuz* /mnt/live/vmlinuz || \
  die "Failed to copy kernel and ramdisk!"

echo
echo "Running "
echo "        cp -v ${XIXER_ROOT}/boot/initrd.img* /mnt/live/initrd"
echo

cp -v ${XIXER_ROOT}/boot/initrd.img* /mnt/live/initrd || \
  die "Failed to copy kernel and ramdisk!"

echo
echo "Running "
echo "        tar -C /usr/lib/syslinux/modules/bios -cf - menu.c32 hdt.c32 ldlinux.c32 libutil.c32 libmenu.c32 libcom32.c32 libgpl.c32 | tar -C /mnt -xf -"
echo

tar -C /usr/lib/syslinux/modules/bios -cf - \
  menu.c32 hdt.c32 ldlinux.c32 libutil.c32 libmenu.c32 \
  libcom32.c32 libgpl.c32 | tar -C /mnt -xf - || \
    die "Failed to copy syslinux files!"

echo
echo "Running "
echo "        cp /boot/memtest86+.bin /mnt/live/memtest"
echo

cp /boot/memtest86+.bin /mnt/live/memtest || \
  die "Failed to copy memtest86"

echo
echo "Running "
echo "        cp /usr/share/misc/pci.ids /mnt"
echo

cp /usr/share/misc/pci.ids /mnt || \
  die "Failed to copy pci.ids"

echo
echo "Running "
echo "        cp /xixer/syslinux.cfg /mnt"
echo

cp /xixer/syslinux.cfg /mnt || \
  die "Failed to copy syslinux.cfg"

echo
echo "Running "
echo "        umount /mnt && sync"
echo

umount /mnt
sync

echo
echo "DONE!!"
