# Add a minimal console and use it in main

## Rationale

- C runtime is already safe: interrupts disabled, .bss cleared, stack set before calling main.
- The smallest productive step is to wrap VGA writes behind `putc`/`puts` with simple cursor state and newline handling, all inside `kernel.c` (no new files yet).
- A follow-up bite-sized step will print Multiboot2 OK/BAD by reading the saved magic.

## Files to change

- `kernel.c` only (for this step)

## Steps

1. In `kernel.c`, add tiny console state and helpers (static scope):

   - `static volatile uint16_t* const vga = (uint16_t*)0xB8000;`
   - `static int cursor_row = 0, cursor_col = 0;`
   - `enum { VGA_WIDTH = 80, VGA_HEIGHT = 25 };`
   - `static uint8_t vga_color = 0x0F; // white on black`
   - Functions:
```c
static void console_putc(char c) {
    if (c == '\n') { cursor_col = 0; if (++cursor_row >= VGA_HEIGHT) cursor_row = 0; return; }
    const int idx = cursor_row * VGA_WIDTH + cursor_col;
    vga[idx] = ((uint16_t)vga_color << 8) | (uint8_t)c;
    if (++cursor_col >= VGA_WIDTH) { cursor_col = 0; if (++cursor_row >= VGA_HEIGHT) cursor_row = 0; }
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
    cursor_row = cursor_col = 0;
}
```

   - Note: No scrolling yet; newline wraps to top after last line for simplicity in this first step.

2. Replace the direct VGA loop in `main` with the console helpers:
```c
void main() {
    console_clear();
    console_puts("Hello Kernel in C!\n");
    for (;;) __asm__ volatile("hlt");
}
```

3. Build and boot to verify the same message appears, now via the console.

## Next bite-sized step (after this):

- Export `mb_magic` and `mb_info_ptr` from `kernel.S` with `.globl` and declare them in `kernel.c` as `extern`.
- Compare `mb_magic` to `0x36D76289`; print `"MB2 OK"` or `"MB2 BAD"` using `console_puts`.