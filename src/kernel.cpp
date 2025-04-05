#include "kernel.h"

void kernel_main() {
    clear_screen();

    kprint("Welcome to OS!\n");

    init_idt();
    init_keyboard();

    kprint("Keyboard initialized! Start typing:....\n");
}