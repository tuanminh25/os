ISO = myos.iso
KERNEL = myos.bin
BUILD = build
SRC = src

CC = gcc
AS = as
LD = ld
CFLAGS = -ffreestanding -O2 -Wall -Wextra -m32
LDFLAGS = -T $(SRC)/linker.ld -m elf_i386

all: $(ISO)

$(BUILD)/kernel.o: $(SRC)/kernel.c
	mkdir -p $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/multiboot_header.o: $(SRC)/multiboot_header.s
	mkdir -p $(BUILD)
	$(AS) --32 $< -o $@

$(KERNEL): $(BUILD)/multiboot_header.o $(BUILD)/kernel.o
	$(LD) $(LDFLAGS) -o $(KERNEL) $^

iso/boot/grub/grub.cfg:
	mkdir -p iso/boot/grub
	echo 'set timeout=0' > iso/boot/grub/grub.cfg
	echo 'set default=0' >> iso/boot/grub/grub.cfg
	echo 'menuentry "MyOS" {' >> iso/boot/grub/grub.cfg
	echo '  multiboot /boot/myos.bin' >> iso/boot/grub/grub.cfg
	echo '  boot' >> iso/boot/grub/grub.cfg
	echo '}' >> iso/boot/grub/grub.cfg

$(ISO): $(KERNEL) iso/boot/grub/grub.cfg
	cp $(KERNEL) iso/boot/myos.bin
	grub-mkrescue -o $(ISO) iso

run: $(ISO)
	qemu-system-i386 -cdrom $(ISO)

clean:
	rm -rf $(BUILD) $(KERNEL) $(ISO)
