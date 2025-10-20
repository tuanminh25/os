// kernel.c
#include <stdint.h>

volatile uint16_t* vga_buffer = (uint16_t*)0xb8000;

void main() {
    const char* msg = "Hello Kernel in C!";
    for (int i = 0; msg[i] != '\0'; i++) {
        vga_buffer[i] = (0x0F << 8) | msg[i];  // white on black
    }

    while (1) {
        __asm__ volatile("hlt");
    }
}
