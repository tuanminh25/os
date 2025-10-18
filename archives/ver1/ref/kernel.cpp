// kernel.cpp - The core of our OS
#include "kernel.h"

void kernel_main() {
    // Clear the screen
    clear_screen();
    
    // Print welcome message
    kprint("Welcome to MyCoolOS!\n");
    
    // Initialize system components
    init_idt();
    init_keyboard();
    
    // Print another message
    kprint("Keyboard initialized. Start typing...\n");
}