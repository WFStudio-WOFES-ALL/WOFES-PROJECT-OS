#!/bin/bash
# WOFES OS — автоматическая сборка ISO

set -e

echo "=== Установка инструментов ==="
sudo apt update
sudo apt install -y debootstrap squashfs-tools xorriso isolinux

echo "=== Создание корневой ФС ==="
sudo debootstrap stable ./rootfs http://deb.debian.org/debian

echo "=== Настройка системы ==="
sudo chroot rootfs apt install --no-install-recommends -y linux-image-amd64 firefox-esr
echo "root:root" | sudo chroot rootfs chpasswd

echo "=== Подготовка ISO ==="
sudo mkdir -p iso/boot/grub
sudo cp rootfs/boot/vmlinuz-* iso/boot/kernel
sudo cp rootfs/boot/initrd.img-* iso/boot/initrd

sudo cat > iso/boot/grub/grub.cfg << EOF
set timeout=5
set default=0
menuentry "WOFES OS" {
    linux /boot/kernel root=/dev/sda1
    initrd /boot/initrd
}
EOF

sudo mksquashfs rootfs iso/filesystem.squashfs -comp xz
sudo grub-mkrescue -o wofes-os.iso iso

echo "=== Готово ==="
echo "ISO: wofes-os.iso"