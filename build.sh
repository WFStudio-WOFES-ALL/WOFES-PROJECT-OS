#!/bin/bash
set -e

ROOT_PASS="root"

sudo apt update
sudo apt install -y debootstrap squashfs-tools xorriso isolinux grub-pc-bin grub-efi-amd64-bin mtools

sudo debootstrap --variant=minbase stable ./rootfs http://deb.debian.org/debian

sudo chroot rootfs apt install --no-install-recommends -y \
    linux-image-amd64 \
    live-boot \
    live-boot-initramfs-tools \
    locales \
    firefox-esr

echo "root:${ROOT_PASS}" | sudo chroot rootfs chpasswd

sudo chroot rootfs apt-get clean
sudo chroot rootfs rm -rf /var/lib/apt/lists/*

sudo mkdir -p iso/boot/grub

KERNEL=$(ls rootfs/boot/vmlinuz-* 2>/dev/null | tail -1)
INITRD=$(ls rootfs/boot/initrd.img-* 2>/dev/null | tail -1)

if [ -z "$KERNEL" ] || [ -z "$INITRD" ]; then
    echo "Ошибка: ядро или initrd не найдены в rootfs/boot/"
    exit 1
fi

sudo cp "$KERNEL" iso/boot/kernel
sudo cp "$INITRD" iso/boot/initrd

sudo tee iso/boot/grub/grub.cfg << EOF
set timeout=5
set default=0

menuentry "WOFES OS" {
    linux /boot/kernel boot=live live-media-path=/boot quiet splash
    initrd /boot/initrd
}
EOF

sudo mksquashfs rootfs iso/filesystem.squashfs -comp xz -noappend
sudo grub-mkrescue -o wofes-os.iso iso

echo "Готово: wofes-os.iso"
