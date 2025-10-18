# Compiler and linker settings
CPP = g++
ASM = nasm
CPPFLAGS = -m32 -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti
LDFLAGS = -m elf_i386 -T src/linker.ld
ASMFLAGS = -f elf32

# Source and object files
C_SOURCES = $(wildcard src/*.cpp)
ASM_SOURCES = src/kernel_entry.asm src/idt_load.asm
HEADERS = $(wildcard src/*.h)
OBJ = ${C_SOURCES:.cpp=.o} ${ASM_SOURCES:.asm=.o}

# Output binaries
KERNEL = src/kernel.bin
OS_IMAGE = src/os.bin

# Default target
all: $(OS_IMAGE)

# Run in QEMU
run: $(OS_IMAGE)
	qemu-system-i386 -fda $(OS_IMAGE)

# Create OS image
$(OS_IMAGE): src/bootloader.bin $(KERNEL)
	cat src/bootloader.bin $(KERNEL) > $(OS_IMAGE)
	# Pad the image to ensure it works in QEMU
	size=$$(stat -c%s "$(OS_IMAGE)"); \
	pad_bytes=$$((1474560 - $$size)); \
	if [ $$pad_bytes -gt 0 ]; then dd if=/dev/zero bs=1 count=$$pad_bytes >> $(OS_IMAGE); fi

# Build bootloader
src/bootloader.bin: src/bootloader.asm
	$(ASM) -f bin src/bootloader.asm -o src/bootloader.bin

# Build kernel
$(KERNEL): $(OBJ)
	ld $(LDFLAGS) -o $(KERNEL) $(OBJ) --oformat binary

# Compile C++ sources
%.o: %.cpp $(HEADERS)
	$(CPP) $(CPPFLAGS) -c $< -o $@

# Compile assembly sources
%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

# Clean up
clean:
	rm -f $(OBJ) $(KERNEL) src/bootloader.bin $(OS_IMAGE)

.PHONY: all clean run 