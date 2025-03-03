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

    ; Print message
    mov si, boot_message
    call print_string_rm

    ; Enable A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Enter protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to flush the prefetch queue
    jmp 0x08:protected_mode

; Real mode print function
print_string_rm:
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

boot_message db 'Booting OS...', 0

BITS 32
protected_mode:
    ; Set up data segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set up page tables
    mov edi, 0x1000    ; PML4 table
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd
    mov edi, 0x1000

    ; Set up paging structures
    mov dword [edi], 0x2003      ; PML4 entry points to PDPT
    add edi, 0x1000
    mov dword [edi], 0x3003      ; PDPT entry points to PD
    add edi, 0x1000
    mov dword [edi], 0x4003      ; PD entry points to PT
    add edi, 0x1000

    ; Identity map the first 2MB
    mov ebx, 0x00000003          ; Present + writable
    mov ecx, 512                 ; 512 entries
    
.set_entry:
    mov dword [edi], ebx
    add ebx, 0x1000
    add edi, 8
    loop .set_entry

    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Enable long mode
    mov ecx, 0xC0000080          ; Set EFER MSR
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Enable paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; Jump to 64-bit code
    jmp 0x08:long_mode

BITS 64
long_mode:
    ; Clear all segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Jump to the kernel entry point
    mov rax, 0x1000  ; Kernel entry point address (adjusted)
    jmp rax

halt:
    hlt
    jmp halt

; GDT setup
gdt_start:
    dq 0x0000000000000000        ; Null descriptor
    dq 0x00AF9A000000FFFF        ; 64-bit code segment
    dq 0x00AF92000000FFFF        ; 64-bit data segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

TIMES 510-($-$$) db 0
DW 0xAA55
