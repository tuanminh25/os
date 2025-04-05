#include "kernel.h"

// Video mem address
uint16_t *video_memory = (uint16_t*)0xB8000;

// Cursor position
int cursor_x = 0;
int cursor_y = 0;

// clear screen 
void clear_screen() {
    uint16_t blank = 0x0720; // 0x07 is light grey on black, 0x20 is space

    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; ++i) {
        video_memory[i] = blank;
    }

    cursor_x = 0;
    cursor_y = 0;
}

void kprint_char(char c, int col, int row) {
    int index = row * VGA_WIDTH + col;

    uint16_t attribute = 0x0F00;            // White on black
    uint16_t character = (attribute | c);

    // Handling new line
    if (c == '\n') {
        cursor_x = 0;
        ++cursor_y;
        return;
    }

    video_memory[index] = character;
    ++cursor_x;

    // line wrapping
    if (cursor_x >= VGA_WIDTH) {
        cursor_x = 0;
        ++cursor_y;
    }

    if (cursor_y >= VGA_HEIGHT) {
        // Move everything up 1 line
        for (int i = 0; i < (VGA_HEIGHT-1) * VGA_WIDTH; ++i) {
            video_memory[i] = video_memory[i + VGA_WIDTH];
        }

        // Clear last line
        for (int i = (VGA_HEIGHT-1)*VGA_WIDTH; i< VGA_HEIGHT * VGA_WIDTH; ++i) {
            video_memory[i] = 0x0720;
        }

        cursor_y = VGA_HEIGHT - 1;
    }

    
}

// Print string at current pos
void kprint(const char *str) {
    for (int i = 0; str[i] != '\0'; ++i) {
        kprint_char(str[i], cursor_x, cursor_y);
    }
}

// Print string at specified pos
void kprint(const char *str, int col, int row) {
    cursor_x = col;
    cursor_y = row;
    kprint(str);
}

