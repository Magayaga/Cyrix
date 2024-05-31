#!/bin/bash
set -e

# Assemble bootloader
nasm -f bin boot.asm -o boot.bin

# Compile kernel
gcc -m64 -ffreestanding -c kernel.c -o kernel.o

# Link kernel
ld -n -o kernel.bin -T linker.ld kernel.o

# Create OS image
cat boot.bin kernel.bin > os_image.bin

# Create ISO
mkdir -p iso/boot/grub
cp os_image.bin iso/boot/
echo 'set timeout=0' > iso/boot/grub/grub.cfg
echo 'set default=0' >> iso/boot/grub/grub.cfg
echo 'menuentry "My OS" {' >> iso/boot/grub/grub.cfg
echo '  multiboot /boot/os_image.bin' >> iso/boot/grub/grub.cfg
echo '  boot' >> iso/boot/grub/grub.cfg
echo '}' >> iso/boot/grub/grub.cfg
grub-mkrescue -o my_os.iso iso

# Clean up
rm -rf iso
