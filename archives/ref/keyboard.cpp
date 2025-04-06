#include "kernel.h"

// Keyboard port
#define KEYBOARD_DATA_PORT 0x60

// Function to read from a port
static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

// Function to write to a port
static inline void outb(uint16_t port, uint8_t val) {
    asm volatile("outb %0, %1" : : "a"(val), "Nd"(port));
}

// Simple US keyboard layout
const char keyboard_map[128] = {
    0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0, 0,
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n', 0,
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\',
    'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' '
    // ... remaining keys (simplified for brevity)
};

// Keyboard interrupt handler
extern "C" void keyboard_handler() {
    uint8_t scancode = inb(KEYBOARD_DATA_PORT);
    
    // Only handle key press (ignore key release)
    if (scancode & 0x80) {
        // Key release, ignore for now
    }
    else {
        // Convert scancode to ASCII and print it
        char c = keyboard_map[scancode];
        if (c != 0) {
            char str[2] = {c, '\0'};
            kprint(str);
        }
    }
    
    // Send EOI signal to the PIC
    outb(0x20, 0x20);
}

// Initialize keyboard
void init_keyboard() {
    // Set up IRQ1 (keyboard) in the IDT
    // Code to set up the keyboard interrupt handler
    
    // Here we would register keyboard_handler to IDT entry 33 (IRQ1)
    
    // Enable keyboard IRQ
    outb(0x21, inb(0x21) & ~2);
}