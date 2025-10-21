1. ENTRY(_start)
ENTRY(_start)


This tells the linker that the entry point of the executable is the symbol _start.

_start is usually defined in your assembly or C code as the very first function that runs when the kernel starts.

Think of it as “the first instruction the CPU executes after boot.”

2. SECTIONS { ... }
SECTIONS
{
  ...
}


This defines the memory layout of the program.

You tell the linker where each section of your program should go in memory.

Inside SECTIONS, we have the actual placement rules.

3. Set initial location
. = 0x00100000;


. is the location counter, i.e., “current memory address.”

This sets the starting address of the output binary to 0x00100000 (1 MiB).

Common in OS kernels because low memory (below 1 MiB) is often reserved for the bootloader or BIOS.

4. Multiboot2 header
.multiboot_header ALIGN(8) : {
  KEEP(*(.multiboot2))
}


Creates a section called .multiboot_header.

ALIGN(8) ensures this section starts at an 8-byte boundary (required by the Multiboot2 specification).

KEEP(*(.multiboot2)):

Keeps all input sections named .multiboot2 from object files.

KEEP prevents the linker from discarding them even if they appear unused.

Purpose: The Multiboot2 header must appear first in the kernel binary so that bootloaders like GRUB can recognize and load it.

5. Code and read-only data
.text ALIGN(0x1000) : {
  *(.text*)
  *(.rodata*)
}


Creates a .text section for code and read-only data.

ALIGN(0x1000) aligns it to 4 KiB, which is the typical page size (useful for paging later).

*(.text*) collects all text/code sections from input object files.

*(.rodata*) collects all read-only data sections from input object files.

Purpose: Keep your code and constant data together, aligned nicely for execution.

6. Data section
.data : { *(.data) }


Creates a .data section for initialized writable data.

*(.data) collects all .data sections from object files.

This memory will have actual values stored in the binary, and can be modified at runtime.

7. BSS section
.bss  : { *(.bss COMMON) }


Creates a .bss section for uninitialized or zero-initialized data.

*(.bss COMMON):

.bss for normal uninitialized variables.

COMMON handles global variables that aren’t explicitly placed in .data or .bss.

The linker knows that .bss doesn’t need to store actual data in the binary; it’s just memory that the loader should zero out.


ENTRY(_start)

SECTIONS
{
  . = 0x00100000;

  /* Force multiboot2 header to stay and appear first */
  .multiboot_header ALIGN(8) : {
    KEEP(*(.multiboot2))
  }

  /* Code and read-only data */
  .text ALIGN(0x1000) : {
    *(.text*)
    *(.rodata*)
  }

  /* Data and BSS */
  .data : { *(.data) }
  .bss  : { *(.bss COMMON) }
}


here in the first ever linker, we can see that read only data is embedded with text, this is because 


- Both .text and .rodata are static, known at compile-time.

- Both do not change at runtime.

- Putting them together simplifies memory layout.

In bigger OSes (like Linux), .rodata is often separate, mainly for finer-grained memory protection (e.g., .text can be executable but not writable, .rodata can be readable but not executable).


right now it is still coupled in my code because i still directly move memory:

start:
    /* Save Multiboot2 registers to globals before changing %esp */
    mov %eax, mb_magic
    mov %ebx, mb_info_ptr

    /* Set up a stack */
    mov $stack_top, %esp

    /* Call C kernel main function */
    call main

    /* If main returns, halt forever */
5:
    hlt
    jmp 5b

    /* --- Read-only data (strings) --- */
    .section .rodata
msg_ok:
    .asciz "MB2 OK"
msg_bad:
    .asciz "MB2 BAD"

    /* --- BSS: kernel stack + saved boot regs --- */
    .section .bss
    .align 16
stack_bottom:
    .skip 16384                      /* 16 KiB stack */
stack_top:
    .align 4
mb_magic:
    .long 0
mb_info_ptr:
    .long 0