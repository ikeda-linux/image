#!/usr/bin/env bash

set -e

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."
ver="5.8"

gh_ver="v6.0.0"

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

get () {
    inf "Getting source..."
    mkdir -p ${out}/overlay
    wget https://github.com/romkatv/zsh-bin/releases/download/${gh_ver}/zsh-${ver}-linux-x86_64.tar.gz -O zsh.tar.gz
    tar -xvf zsh.tar.gz -C ${out}/overlay/
}

clean () {
    inf "Getting rid of build artifacts..."
    rm -rf zsh.tar.gz
    rm -rf ${src}/* ${src}/.* > /dev/null 2>&1
}

permissions () {
    inf "Setting correct permissions..."
    chown -R root:root ${out}/
    chmod -R 777 ${out}/
}

main () {
    get
    clean
    permissions
    exit 0
}

main