#ifndef KERNEL_H
#define KERNEL_H

// Define some useful types
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

// Screen dimensions
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

// Screen I/O
void clear_screen();
void kprint(const char* str);
void kprint_at(const char* str, int col, int row);

// Hardware communication
void init_idt();
void init_keyboard();

#endif