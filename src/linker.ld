ENTRY(kernel_entry)

SECTIONS
{
    /* Match the address with the bootloader's expectations */
    . = 0x1000;
    
    .text : {
        *(.text*)
    }
    
    .rodata : {
        *(.rodata*)
    }
    
    .data : {
        *(.data*)
    }
    
    .bss : {
        *(COMMON)
        *(.bss*)
    }
}
