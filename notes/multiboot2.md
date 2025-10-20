Multiboot2

A boot protocol. There are lots of boot protocol for x86 kernels, there are:

1. Multiboot (v1) — old GRUB standard

2. Multiboot2 — modern GRUB standard

3. Linux boot protocol — used by Linux kernel

4. Stivale / Stivale2 — used by modern hobbyist kernels (e.g., Limine)

5. UEFI boot protocol — for UEFI systems (no BIOS)

A quick comparison:

Best for beginners: 🟢 Stivale2

Best for GRUB users / traditional setup: 🟢 Multiboot2

Best for long-term real-world OS dev: 🟢 UEFI

Avoid: Multiboot1 (outdated), Linux boot protocol (too specific)

In this project, we plan to use GRUB as our bootloader and dont want to write our own boot, therefore, Multiboot2 protocol just simply the most fit way 

