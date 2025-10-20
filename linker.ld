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
