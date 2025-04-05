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
// this keyboard focuses on simple print-able character rather than tab, space...
const char keyboard_map[128] = {
    0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0, 0,
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n', 0,
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\',
    'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' '
};

// Keyboard interrupt handler
extern "C" void keyboard_handler() {
    uint8_t scancode = inb(KEYBOARD_DATA_PORT);

    // Only handle key press for now
    if (scancode & 0x80) {
        // key release - ignore for now
        return;
    }

    char c = keyboard_map[scancode];
    if (c != 0) {
        char str[2] = { c, '\0' };
        kprint(str);
    }
}


void init_keyboard() {
    // Set up IRQ1 (keyboard) in the IDT
    // Code to set up the keyboard interrupt handler
    
    // Here we would register keyboard_handler to IDT entry 33 (IRQ1)

    // Enable keyboard IRQ
    outb(0x21, inb(0x21) & ~2);
}