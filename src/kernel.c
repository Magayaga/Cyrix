// kernel.c

// Function to print a null-terminated string
void print_string(const char* str) {
    // Video memory address (0xB8000 for VGA text mode)
    volatile char* video_memory = (volatile char*)0xB8000;
    
    // Print each character in the string
    while (*str != '\0') {
        // Write the character and attribute to video memory
        *video_memory++ = *str++;
        *video_memory++ = 0x0F; // Attribute: white text on black background
    }
}

// Entry point of the kernel
void kernel_main() {
    // Welcome message
    print_string("Hello, World!");

    // Infinite loop to halt the CPU
    while (1) {}
}

