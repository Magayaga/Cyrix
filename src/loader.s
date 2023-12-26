; loader.s - a simple boot loader
; This code is in the public domain

; Define some constants
%define SECTOR_SIZE 512 ; The size of a disk sector in bytes
%define BOOT_DRIVE 0x80 ; The BIOS drive number for the first hard disk
%define KERNEL_SECTOR 2 ; The sector number where the kernel is located
%define KERNEL_OFFSET 0x1000 ; The memory offset where the kernel will be loaded

; The boot loader starts here
section .text
    global _start ; Make the entry point visible to the linker
    _start:
        ; Set up the stack pointer
        mov bp, 0x9000 ; Set the base pointer to 0x9000
        mov sp, bp ; Set the stack pointer to the base pointer

        ; Reset the disk system
        mov ah, 0x00 ; Set the BIOS function number to 0x00 (reset disk system)
        mov dl, BOOT_DRIVE ; Set the drive number to the boot drive
        int 0x13 ; Call the BIOS interrupt 0x13 (disk services)
        jc disk_error ; If the carry flag is set, jump to disk_error

        ; Read the kernel from the disk
        mov ah, 0x02 ; Set the BIOS function number to 0x02 (read sectors from drive)
        mov al, 1 ; Set the number of sectors to read to 1
        mov ch, 0 ; Set the cylinder number to 0
        mov cl, KERNEL_SECTOR ; Set the sector number to the kernel sector
        mov dh, 0 ; Set the head number to 0
        mov dl, BOOT_DRIVE ; Set the drive number to the boot drive
        mov bx, KERNEL_OFFSET ; Set the buffer address to the kernel offset
        int 0x13 ; Call the BIOS interrupt 0x13 (disk services)
        jc disk_error ; If the carry flag is set, jump to disk_error

        ; Jump to the kernel
        jmp KERNEL_OFFSET ; Jump to the kernel offset

    disk_error:
        ; Display an error message and halt
        mov si, error_msg ; Set the source index to the error message
        call print_string ; Call the print_string function
        cli ; Clear the interrupt flag
        hlt ; Halt the CPU

    ; A function to print a null-terminated string
    print_string:
        pusha ; Push all registers to the stack
        mov ah, 0x0E ; Set the BIOS function number to 0x0E (write character in TTY mode)
        .loop:
            lodsb ; Load the next character from si to al and increment si
            cmp al, 0 ; Compare al with 0
            je .done ; If al is 0, jump to .done
            int 0x10 ; Call the BIOS interrupt 0x10 (video services)
            jmp .loop ; Jump to .loop
        .done:
            popa ; Pop all registers from the stack
            ret ; Return from the function

    ; A null-terminated error message
    error_msg db "Disk error!", 0

    ; Pad the boot loader with zeros and add the boot signature
    times SECTOR_SIZE - ($ - $$) - 2 db 0 ; Fill the rest of the sector with zeros
    dw 0xAA55 ; The boot signature

