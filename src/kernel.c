// kernel.c

#include <stdbool.h> // Include necessary headers

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

// Helper function to compare two strings
bool strcmp(const char *str1, const char *str2)
{
    while (*str1 != '\0' && *str2 != '\0')
    {
        if (*str1 != *str2)
        {
            return false;
        }
        str1++;
        str2++;
    }
    return *str1 == *str2;
}

// Function to handle the "clear" command
void handle_clear_command()
{
    clear_screen();
}

// Function to handle the "echo" command
void handle_echo_command(const char *args)
{
    print_string(args);
}

// Function to handle the "help" command
void handle_help_command()
{
    print_string("Available commands:");
    print_newline();
    print_string("- clear: Clear the screen");
    print_newline();
    print_string("- echo [text]: Print the specified text");
    print_newline();
}

// Function to handle unknown commands
void handle_unknown_command(const char *command)
{
    print_string("Unknown command: ");
    print_string(command);
    print_newline();
}

// Function to process and execute commands
void process_command(const char *command)
{
    if (strcmp(command, "clear"))
    {
        handle_clear_command();
    }
    else if (strcmp(command, "echo"))
    {
        // Assume the rest of the command line is the argument to echo
        const char *args = command + 4; // Skip "echo "
        handle_echo_command(args);
    }
    else if (strcmp(command, "help"))
    {
        handle_help_command();
    }
    else
    {
        handle_unknown_command(command);
    }
}

// The kernel entry point
void kernel_main()
{
    // Clear the screen
    clear_screen();

    // Welcome message
    print_string("Welcome to my OS! Type 'help' for a list of commands.");

    // Main shell loop
    while (1)
    {
        print_newline();
        print_string(">");
        
        // Assume a fixed-size command buffer for simplicity
        char command_buffer[100];
        
        // Read a line of input (you need to implement this function)
        read_input(command_buffer);

        // Process and execute the command
        process_command(command_buffer);
    }
}

