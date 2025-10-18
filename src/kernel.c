#include <stddef.h>
#include <stdint.h>

static uint16_t* const VGA_BUFFER = (uint16_t*)0xB8000;
static const int VGA_WIDTH = 80;
static const int VGA_HEIGHT = 25;

void kernel_main(void) {
    const char* msg = "Yo from MyOS!";
    for (size_t i = 0; msg[i] != '\0'; i++) {
        VGA_BUFFER[i] = (uint16_t)msg[i] | (0x0F << 8); // white on black
    }
}