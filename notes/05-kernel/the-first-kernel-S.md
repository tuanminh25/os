# The Very First kernel.S

A breakdown of the essential components of the first kernel assembly file.

---

## 1. First 32 KB → Multiboot2 Header

**Correct:** GRUB scans this for a Multiboot2 header.

### Includes:
- Magic number
- Architecture
- Header length
- Checksum
- At least an end tag

**Purpose:** Marks start and end so GRUB knows the header size.

---

## 2. Kernel Code Start

### `.section .text`
Declares executable code.

### `.align 16`
16-byte alignment is preferred on x86_64 for performance.

**Why?**
- CPU fetches instructions faster
- Some instructions require 16-byte alignment
- 8-byte alignment would work, but 16 is common for modern CPUs

---

## 3. _start

Writes "A" to VGA text buffer as a simple test to verify the kernel runs.

---

## 4. Halt + Infinite Loop

### `hlt` instruction
Halts CPU until the next interrupt (low-power wait).

- It does **not** permanently stop the CPU
- It just pauses until something like a timer or keyboard interrupt occurs

### `jmp 1b` instruction
Loops back to `hlt`, creating an infinite loop.

**Why loop?** Because the kernel has nothing else to do, and without the loop, the CPU would execute whatever garbage is after your code (crash/undefined behavior).
