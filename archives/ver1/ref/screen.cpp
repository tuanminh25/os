#include "kernel.h"

// Video memory address
uint16_t* video_memory = (uint16_t*)0xB8000;

// Cursor position
int cursor_x = 0;
int cursor_y = 0;

// Clear the screen
void clear_screen() {
    // Black on black, with space character (effectively blank)
    uint16_t blank = 0x0720;  // 0x07 is light gray on black, 0x20 is space
    
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        video_memory[i] = blank;
    }
    
    // Reset cursor position
    cursor_x = 0;
    cursor_y = 0;
}

// Print a single character
void kprint_char(char c, int col, int row) {
    // Calculate the position in video memory
    int index = row * VGA_WIDTH + col;
    
    // Create the character with attributes (white on black)
    uint16_t attribute = 0x0F00;  // White on black
    uint16_t character = (attribute | c);
    
    // Special handling for newline
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
        return;
    }
    
    // Write to video memory
    video_memory[index] = character;
    
    // Update cursor
    cursor_x++;
    
    // Handle line wrapping
    if (cursor_x >= VGA_WIDTH) {
        cursor_x = 0;
        cursor_y++;
    }
    
    // Scroll if needed
    if (cursor_y >= VGA_HEIGHT) {
        // Move everything up one line
        for (int i = 0; i < (VGA_HEIGHT-1) * VGA_WIDTH; i++) {
            video_memory[i] = video_memory[i + VGA_WIDTH];
        }
        
        // Clear the last line
        for (int i = (VGA_HEIGHT-1) * VGA_WIDTH; i < VGA_HEIGHT * VGA_WIDTH; i++) {
            video_memory[i] = 0x0720;
        }
        
        cursor_y = VGA_HEIGHT - 1;
    }
}

// Print a string at current cursor position
void kprint(const char* str) {
    for (int i = 0; str[i] != '\0'; i++) {
        kprint_char(str[i], cursor_x, cursor_y);
    }
}

// Print a string at specified position
void kprint_at(const char* str, int col, int row) {
    cursor_x = col;
    cursor_y = row;
    kprint(str);
}