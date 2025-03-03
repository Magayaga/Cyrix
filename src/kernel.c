// kernel.c
#include <stdint.h>

void print_string(const char* str) {
    volatile uint16_t* VideoMemory = (uint16_t*)0xB8000;
    uint8_t attribute = 0x0F; // White on black
    
    for (int i = 0; str[i] != '\0'; i++) {
        VideoMemory[i] = (attribute << 8) | str[i];
    }
}

void clear_screen() {
    volatile uint16_t* VideoMemory = (uint16_t*)0xB8000;
    uint8_t attribute = 0x0F; // White on black
    uint16_t blank = (attribute << 8) | ' ';
    
    for (int i = 0; i < 80 * 25; i++) {
        VideoMemory[i] = blank;
    }
}

void kernel_entry() {
    clear_screen();
    print_string("Hello, World!!");
    
    // Infinite loop to keep the OS running
    while (1) {
        asm volatile("hlt");
    }
}
