#!/bin/bash
set -e

# Assemble bootloader
nasm -f bin boot.asm -o boot.bin

# Compile kernel
gcc -m64 -ffreestanding -fno-builtin -nostdlib -mno-red-zone -c kernel.c -o kernel.o

# Link kernel
ld -n -o kernel.bin -T linker.ld kernel.o

# Create OS image
cat boot.bin kernel.bin > os_image.bin

# Create bootable ISO
mkdir -p iso/boot
cp os_image.bin iso/boot/

# Create GRUB configuration
mkdir -p iso/boot/grub
cat > iso/boot/grub/grub.cfg << EOF
set timeout=5
set default=0

menuentry "My OS" {
    multiboot /boot/os_image.bin
    boot
}
EOF

# Create ISO
grub-mkrescue -o my_os.iso iso

echo "Build complete! OS image is at my_os.iso"

# Clean up temporary files
rm -f boot.bin kernel.o kernel.bin os_image.bin
rm -rf iso
