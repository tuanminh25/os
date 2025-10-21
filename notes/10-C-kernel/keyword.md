# C Kernel Keywords & Syntax

Essential C keywords and syntax used in kernel development.

---

## `volatile` Keyword

**Purpose:** Tells the compiler not to optimize reads/writes to this variable because its value may change unexpectedly.

### Common Use Cases:
- Hardware registers
- Memory-mapped I/O
- Shared memory accessed by interrupts or DMA

---

## VGA Buffer Declaration

```c
volatile uint16_t* vga_buffer = (uint16_t*)0xb8000;
```

### Breaking It Down:

| Component | Meaning |
|-----------|---------|
| `uint16_t*` | Pointer to 16-bit unsigned integers |
| `volatile` | Tells compiler that writes affect hardware and must not be optimized away |
| `(uint16_t*)0xb8000` | Points to VGA text buffer memory at physical address `0xb8000` |

**Result:** `vga_buffer` is a pointer to the VGA screen memory that we can write to directly.

---

## `__asm__` Keyword

**Purpose:** Allows you to write inline assembly inside C code.

---

## Inline Assembly Example

```c
__asm__ volatile("hlt");
```

### Breaking It Down:

| Component | Meaning |
|-----------|---------|
| `__asm__` | Inline assembly directive |
| `volatile` | Tells compiler not to remove this instruction, even if it seems unused |
| `"hlt"` | x86 instruction that halts the CPU until the next interrupt |

**Purpose:** Halts the CPU in a low-power state until the next interrupt occurs.

> 💡 **Note:** The `volatile` qualifier in assembly context prevents the compiler from optimizing away the instruction, ensuring the CPU actually halts.
