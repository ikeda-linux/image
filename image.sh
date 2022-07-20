#!/usr/bin/env bash

set -e

LIMINE_BRANCH="v3.12.2-binary"
KERN="vm"
NDISK=""

if [[ ! "$EUID" == "0" ]]; then
    echo "Run as root"
    exit 1
fi

if [[ ! "$1" == "" ]]; then
    NDISK="$1"
fi

if [[ ! "$2" == "" ]]; then
	KERN="$2"
fi

UNPACK_TGT="ikeda_fs"

if [[ -d ${UNPACK_TGT} ]]; then
    rm -rf ${UNPACK_TGT}
fi

if [[ -d ikeda ]]; then
    rm ikeda
fi

mkdir ${UNPACK_TGT}

# since tar overwrites.....
tar -xf packages/filesystem*.tar.zst -C ${UNPACK_TGT}/

for pkg in $(ls packages/ | grep zst | grep -v filesystem | grep -v linux); do
    echo $pkg
    tar --skip-old-files -xf packages/${pkg} -C ${UNPACK_TGT}/
done

if [[ "$KERN" == "" ]]; then
	printf "for kernel, enter 'vm' or 'vanilla': "
	read KERN
fi

tar --skip-old-files -xf packages/linux-${KERN}*.tar.zst -C ${UNPACK_TGT}/
tar --skip-old-files -xf packages/linux-firmware*.tar.zst -C ${UNPACK_TGT}/
rm -rf ${UNPACK_TGT}/{scripts,md.toml,.BUILDINFO,.MTREE,.PKGINFO}

size=$(du -sh ${UNPACK_TGT} | awk '{ print $1 }')

echo "fs size in ${UNPACK_TGT} is ${size}"

if [[ "$NDISK" == "" ]]; then
    printf "Disk size (MB)? : "
    read NDISK
fi

fallocate -l${NDISK}M ikeda
parted ikeda mklabel msdos --script
parted --script ikeda 'mkpart primary ext4 1 -1' 

if [[ ! -d limine ]]; then
    git clone https://github.com/limine-bootloader/limine.git --branch=${LIMINE_BRANCH} --depth=1
else
    pushd limine && git pull && popd
fi

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

pushd limine
make
./limine-deploy ../ikeda
popd

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