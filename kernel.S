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
    /*                KERNEL CODE START              */
    /**************************************************/
    .section .text               /* executable code section */
    .align 16                    /* align code on 16 byte boundary (common for x86_64) */
    .globl _start                /* make _start visible to the linker/entry point */

_start:
    /* Note: GRUB will have set up registers and passed a Multiboot2 info pointer in RBX
       (if it loaded in 32-bit mode it uses different register conventions; for our
       simple test we'll not rely on those values). */

    /* A very small test: write a byte to VGA text buffer to verify we ran.
       If you run under QEMU and see the character, you know control reached here. */

    /* rdi = 0xb8000 (VGA text buffer), rsi = character word, rcx = count */
    lea 0xb8000(%rip), %rdi      /* rdi <- address of VGA text buffer (RIP-relative load) */
    mov $0x2F41, %ax             /* ax <- character & attribute (0x41 = 'A', 0x2F = attr) */
    mov %ax, (%rdi)              /* store ax into VGA buffer (first character cell) */

    /* infinite loop so we don't fall off into nowhere */
1:
    hlt                         /* halt CPU until next interrupt (low-power spin) */
    jmp 1b                      /* jump back to label 1 (infinite loop) */
