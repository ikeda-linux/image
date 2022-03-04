#!/usr/bin/env bash

set -e

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."
ver="master"

MGCC="musl-gcc"

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

get () {
    inf "Getting source..."
    mkdir -p ${out}/overlay/usr/bin/
    wget https://raw.githubusercontent.com/minos-org/minos-static/master/static-get -O ${out}/overlay/usr/bin/static-get
}

clean () {
    inf "Getting rid of build artifacts..."
    rm -rf ${src}/* ${src}/.* > /dev/null 2>&1
}

permissions () {
    inf "Setting correct permissions..."
    chown -R root:root ${out}/
    chmod -R 777 ${out}/
    chmod +x ${out}/overlay/usr/bin/static-get
}

main () {
    get
    clean
    permissions
    exit 0
}

main