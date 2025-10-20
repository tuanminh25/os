    /**************************************************/
    /*                MULTIBOOT2 HEADER               */
    /**************************************************/

    /* --- GRUB scans the first 32 KB of your kernel binary for a Multiboot2 header --- */
    .section .multiboot2, "a"    /* create special binary section named .multiboot2 that GRUB will scan for a Multiboot2 header */
    .align 8                     /* ensure 8-byte alignment as required by spec */

mb2_header_start:
    .long 0xE85250D6             /* (1) multiboot2 magic number (constant) */
    .long 0x00000000             /* (2) architecture: 0 = i386 (Multiboot2 uses 0) */
    .long mb2_header_end - mb2_header_start
                                /* (3) header_length: size in bytes from start to end */
    /* checksum = - (magic + architecture + header_length) modulo 2^32 */
    .long -(0xE85250D6 + 0 + (mb2_header_end - mb2_header_start))
                                /* (4) checksum (computed so sum = 0 mod 2^32) */

    /* minimal empty tag: align and mark end-of-header with tag type 0 (end) */
    /* Multiboot2 spec requires tags; at minimum an end tag (type 0) ends the header. */
    .align 8
    .long 0                     /* tag type 0 = end tag */
    .long 8                     /* tag size (8 bytes for an end tag) */

mb2_header_end:
    .size mb2_header_end, . - mb2_header_start



    /**************************************************/
    /*                KERNEL CODE START               */
    /**************************************************/
    .section .text               /* executable code section */
    .align 16                    /* align code on 16 byte boundary (common for x86) */
    .globl _start                /* make _start visible to the linker/entry point */
    .code32

_start:
    /* --- Set up a stack (use our .bss-allocated stack) --- */
    mov $stack_top, %esp

    /* --- VGA string print --- */
    mov $0xb8000, %edi           /* edi = VGA text buffer (phys mapped identity) */
    mov $msg, %esi               /* esi = pointer to string (zero-terminated) */
    mov $0x1F, %ah               /* attribute: bright white on blue background */

1:
    lodsb                        /* al = *esi++; */
    test %al, %al                /* reached NUL? */
    jz 2f
    mov %ax, (%edi)              /* write char+attr */
    add $2, %edi
    jmp 1b

2:
    /* Halt forever */
3:
    hlt
    jmp 3b

    /* --- Read-only data (string) --- */
    .section .rodata
msg:
    .asciz "Hello, OS!"

    /* --- BSS: kernel stack --- */
    .section .bss
    .align 16
stack_bottom:
    .skip 16384                  /* 16 KiB stack */
stack_top: