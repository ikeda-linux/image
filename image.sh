#!/usr/bin/env bash

set -e

LIMINE_VER="3.20.1"
LIMINE_SRC="https://github.com/limine-bootloader/limine/releases/download/v${LIMINE_VER}/limine-${LIMINE_VER}.tar.gz"

KERN="vm"
NDISK=""

if [[ ! "$EUID" == "0" ]]; then
    echo "Run as root"
    exit 1
fi

if [[ ! "$1" == "" ]]; then
	KERN="$1"
fi

UNPACK_TGT="ikeda_fs"

if [[ -d ${UNPACK_TGT} ]]; then
    rm -rf ${UNPACK_TGT}
fi

if [[ -d ikeda ]]; then
    rm ikeda
fi

mkdir ${UNPACK_TGT}

pacstrap -M -G -C strap.conf ${UNPACK_TGT} linux-${KERN} linux-firmware base limine

size=$(du -sh ${UNPACK_TGT} | awk '{ print $1 }')

echo "fs size in ${UNPACK_TGT} is ${size}"

if [[ "$NDISK" == "" ]]; then
    printf "Disk size (MB)? : "
    read NDISK
fi

fallocate -l${NDISK}M ikeda
parted ikeda mklabel msdos --script
parted --script ikeda 'mkpart primary ext4 1 -1' 

fs_root=${UNPACK_TGT}

loopdev=$(losetup -P -f --show ikeda)
if [[ ! -d ikeda_mount ]]; then
    mkdir ikeda_mount
fi
mkfs.ext4 ${loopdev}p1
mount ${loopdev}p1 ikeda_mount
cp -rv ${fs_root}/* ikeda_mount/.

partuuid=$(fdisk -l ./ikeda | grep "Disk identifier" | awk '{split($0,a,": "); print a[2]}' | sed 's/0x//g')
echo "PARTUUID=${partuuid}"

[[ -d limine-${LIMINE_VER} ]] && rm -rf limine-${LIMINE_VER}
wget $LIMINE_SRC
tar -xf limine*
pushd limine-${LIMINE_VER}
CC=musl-gcc ./configure --enable-bios --enable-uefi-x86_64 --enable-limine-deploy
make
cp bin/limine.sys ../ikeda_mount/boot/. -v
popd


sed -i "s/something/${partuuid}-01/g" ikeda_mount/boot/limine.cfg

if [ -d ikeda_mount ]; then
    findmnt | grep ikeda
    if [[ "$?" == "0" ]]; then
        umount -l ikeda_mount
    fi
    rm ikeda_mount -rf
    losetup -D
fi

limine-${LIMINE_VER}/bin/limine-deploy ./ikeda
rm -rf limine-${LIMINE_VER}*

printf "Remove FS dir? (Y/n): "
read rmd

if [[ ! "$rmd" == "n" ]]; then
    rm -rfv ${UNPACK_TGT}
else
    printf "RootFS tarball? (Y/n): "
    read rtb
    if [[ ! "$rtb" == "n" ]]; then
        printf "Tarball filename: "
        tar -cvf $(read) ikeda_fs/*
        printf "Remove FS dir? (Y/n): "
        read rmd

        if [[ ! "$rmd" == "n" ]]; then
            rm -rfv ${UNPACK_TGT}
        fi
    fi
fi

if [[ -n $SUDO_UID ]]; then
  chown $SUDO_UID:$SUDO_GID ikeda
fi
