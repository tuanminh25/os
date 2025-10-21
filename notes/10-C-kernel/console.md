# Console Implementation Concepts

Essential C concepts used in kernel console development.

---

## `#include <stdint.h>`

A C standard header that defines **fixed-width integer types**.

### Fixed-Width Integer Types:

| Type | Size | Range |
|------|------|-------|
| `uint8_t` | 1 byte | 0–255 |
| `uint16_t` | 2 bytes | 0–65,535 |
| `uint32_t` | 4 bytes | 0–4,294,967,295 |

> 💡 **Why use these?** Guarantees exact sizes across different platforms, critical for hardware interaction and memory-mapped I/O.

---

## The `static` Keyword

The `static` keyword has **different meanings** depending on context.

### For Functions

```c
static void console_putc(char c) { ... }
```

| Aspect | Meaning |
|--------|---------|
| **Scope** | Function is **private** to this translation unit (`.c` file) |
| **Visibility** | Not visible outside this file |
| **Memory** | Does **not** affect stack vs heap—it's about visibility only |

**Example:** `console_putc` cannot be called from other `.c` files.

---

### For Variables at File Scope

```c
static int cursor_row = 0;
```

| Aspect | Meaning |
|--------|---------|
| **Lifetime** | Variable exists for the **entire lifetime** of the program |
| **Location** | Not on the stack—stored in data segment |
| **Linkage** | Limits visibility to this translation unit |

> **Note:** Without `static`, a global variable is already "static" in memory. Here, `static` mainly provides clarity and limits linkage to the current file.
