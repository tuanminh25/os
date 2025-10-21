# How Computers Read Memory

**Question:** How do computers "read" memory? Why is it faster when things are divisible by 8?

---

## 1️⃣ How a Computer "Reads" Memory

Memory is a linear array of bytes, but CPUs usually read in chunks: 1, 2, 4, 8, or even 16 bytes at a time (depending on CPU word size).

**Example:** A 64-bit CPU reads 8 bytes (64 bits) at a time.

---

## 2️⃣ What "Alignment" Means

**Aligned memory:** The address of the data is a multiple of its size.

- **Example:** 8-byte data starting at address `0x1000` ✅ (divisible by 8)
- **Misaligned:** 8-byte data at `0x1003` ❌ (not divisible by 8)

---

## 3️⃣ Why Aligned Memory is Faster

CPUs fetch memory in blocks (cache lines). 

### If data is aligned:
- The CPU can read the entire data in a **single memory access**.

### If data is misaligned:
- The CPU might need **two memory accesses** to fetch the same data.
- Some CPUs even raise faults on misaligned access (older x86, many RISC CPUs).

---

## 4️⃣ Practical Example: Multiboot2 Header

GRUB reads the header in 32-bit or 64-bit words.

### If the header isn't 8-byte aligned, GRUB might:
- Misinterpret a field
- Fail checksum
- Fail to boot your kernel
