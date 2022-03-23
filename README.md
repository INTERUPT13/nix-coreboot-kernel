# nix-coreboot-kernel
builds a small [wg+network+kexec] hardened kernel to embed into coreboot(bios flash) to use as an kexec based bootloader/rescue env

## build

git clone https://github.com/INTERUPT13/nix-coreboot-kernel
cd nix-coreboot-kernel
nix build

check result/
