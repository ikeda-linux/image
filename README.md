# kbuilds
Package sources for Ikeda

## Build image:
* (Have sigma installed & in path)
* Use `sudo sgma build <packages>` where `<packages>` is (all packge names in src - one of the kernels) {either `linux-vm` or `linux-vanilla`}
    * Specifically, make sure to build: `filesystem`, `busybox`, `rustysd`, `zsh`, `ncurses` and a kernel
* Finally, `sudo ./image.sh`