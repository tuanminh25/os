# 1️⃣ Assemble the kernel
as --32 kernel.S -o kernel.o

# 2️⃣ Link kernel into ELF
ld -m elf_i386 -T linker.ld -o kernel.elf kernel.o -z max-page-size=0x1000

# 3️⃣ Optional: verify ELF is Multiboot2-compliant
grub-file --is-x86-multiboot2 kernel.elf && echo "OK" || echo "NOT OK"

# 4️⃣ Check that object file contains the multiboot2 section
readelf -S kernel.o | grep multiboot

# 5️⃣ Prepare ISO directories and copy ELF
mkdir -p iso/boot/grub
cp kernel.elf iso/boot/

# 6️⃣ Write GRUB config (if not already created)
cat > iso/boot/grub/grub.cfg <<'EOF'
set timeout=3
set default=0

menuentry "Can you see my os here?" {
  multiboot2 /boot/kernel.elf
  boot
}
EOF

# 7️⃣ Build the bootable ISO
grub-mkrescue -o os.iso iso

# 8️⃣ Boot the ISO in QEMU
qemu-system-x86_64 -cdrom os.iso -m 512