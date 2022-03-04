#!/usr/bin/env bash

set -e

fs_root=$(cat .fsroot)

loopdev=$(losetup -P -f --show ikeda)
mkdir ikeda_mount
mkfs.ext4 ${loopdev}p1
mount ${loopdev}p1 ikeda_mount
cp -rv ${fs_root}/* ikeda_mount/.
partuuid=$(fdisk -l ./ikeda | grep "Disk identifier" | awk '{split($0,a,": "); print a[2]}' | sed 's/0x//g')
echo "PARTUUID=${partuuid}"
cp limine/limine.sys ikeda_mount/boot/. -v
sed -i "s/something/${partuuid}-01/g" ikeda_mount/boot/limine.cfg

if [ -d ikeda_mount ]; then
    findmnt | grep ikeda
    if [[ "$?" == "0" ]]; then
        umount ikeda_mount
    fi
    rm ikeda_mount -rf
    losetup -D
fi