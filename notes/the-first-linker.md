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