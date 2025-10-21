#include <stdint.h>


// Todo: explore this file more, may be rewrite the algorithm

static volatile uint16_t* const vga = (uint16_t*)0xB8000;
enum { VGA_WIDTH = 80, VGA_HEIGHT = 25 };
static int cursor_row = 0, cursor_col = 0;
static uint8_t vga_color = 0x0F;  // white on black

static void console_putc(char c) {
    if (c == '\n') {
        cursor_col = 0;
        if (++cursor_row >= VGA_HEIGHT) cursor_row = 0;
        return;
    }
    int idx = cursor_row * VGA_WIDTH + cursor_col;
    vga[idx] = ((uint16_t)vga_color << 8) | (uint8_t)c;
    if (++cursor_col >= VGA_WIDTH) {
        cursor_col = 0;
        if (++cursor_row >= VGA_HEIGHT) cursor_row = 0;
    }
}

static void console_puts(const char* s) {
    for (; *s; ++s) console_putc(*s);
}

static void console_clear(void) {
    for (int r = 0; r < VGA_HEIGHT; ++r) {
        for (int c = 0; c < VGA_WIDTH; ++c) {
            vga[r * VGA_WIDTH + c] = ((uint16_t)vga_color << 8) | ' ';
        }
    }
    cursor_row = 0;
    cursor_col = 0;
}

void main() {
    console_clear();
    console_puts("Let's change and be unpredictable ish!\nThis should be the second line");
    while (1) {
        __asm__ volatile("hlt");
    }
}