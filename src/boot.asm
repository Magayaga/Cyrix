; boot.asm
BITS 16
ORG 0x7C00

start:
    ; Set up the stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Enter protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to flush the prefetch queue
    jmp 0x08:protected_mode

BITS 32
protected_mode:
    ; Set up data segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Enable A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Switch to long mode
    mov ecx, cr4
    or ecx, 0x20
    mov cr4, ecx

    mov eax, cr3
    mov cr3, eax

    mov ecx, cr0
    or ecx, 0x80000001
    mov cr0, ecx

    jmp 0x08:long_mode

BITS 64
long_mode:
    ; Set up data segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Jump to the kernel entry point
    mov rax, 0x100000  ; Kernel entry point address
    jmp rax

halt:
    hlt
    jmp halt

; GDT setup
gdt_start:
    dq 0x0000000000000000    ; Null descriptor
    dq 0x00A09A000000FFFF    ; Code segment descriptor
    dq 0x00A092000000FFFF    ; Data segment descriptor
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dq gdt_start

TIMES 510-($-$$) db 0
DW 0xAA55
