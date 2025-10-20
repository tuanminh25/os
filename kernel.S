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
    .section .text
    .align 16
    .globl _start
    .code32

_start:
    /* Save Multiboot2 registers to globals before changing %esp */
    mov %eax, mb_magic
    mov %ebx, mb_info_ptr

    /* Set up a stack */
    mov $stack_top, %esp

    /* Decide message based on Multiboot2 magic */
    mov mb_magic, %eax
    cmp $0x36D76289, %eax            /* Multiboot2 magic */
    jne 1f
    mov $msg_ok, %esi
    jmp 2f
1:
    mov $msg_bad, %esi

2:
    /* VGA string print */
    mov $0xb8000, %edi
    mov $0x1F, %ah                   /* bright white on blue */

3:
    lodsb                            /* al = *esi++ */
    test %al, %al
    jz 4f
    mov %ax, (%edi)
    add $2, %edi
    jmp 3b

4:
    /* Halt forever */
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