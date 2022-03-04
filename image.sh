#!/usr/bin/env bash

set -e

UNPACK_TGT="ikeda_fs"

if [[ -d ${UNPACK_TGT} ]]; then
    rm -rf ${UNPACK_TGT}
fi

mkdir ${UNPACK_TGT}

# since tar overwrites.....
tar -xf out/filesystem.tar.zst -C ${UNPACK_TGT}/

for pkg in $(ls out/ | grep zst | grep -v filesystem); do
    echo $pkg
    tar --skip-old-files -xf out/${pkg} -C ${UNPACK_TGT}/
done

rm -rf ${UNPACK_TGT}/{scripts,md.toml}
mv ${UNPACK_TGT}/overlay/* ${UNPACK_TGT}/.
rm -rf ${UNPACK_TGT}/overlay

size=$(du -sh ${UNPACK_TGT} | awk '{ print $1 }')

echo "fs size in ${UNPACK_TGT} is ${size}"
printf "Disk size (MB)? : "
read NDISK

fallocate -l${NDISK}M ikeda
parted ikeda mklabel msdos --script
parted --script ikeda 'mkpart primary ext4 1 -1' 

if [[ ! -d limine ]]; then
    git clone https://github.com/limine-bootloader/limine.git --branch=latest-binary --depth=1
else
    pushd limine && git pull && popd
fi

echo "${UNPACK_TGT}" >> .fsroot

chmod +x image_root.sh
sudo ./image_root.sh
rm .fsroot

pushd limine

./limine-install-linux-x86_64 ../ikeda

popd
