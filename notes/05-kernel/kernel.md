# Kernel Memory Layout

## Overview

The kernel itself is a manager. It manages itself and the user space application (memory).

---

## Kernel Memory Layout Sequence

Normally it will starts somewhere after 1MiB, it first starts with:

### 1. Text
The kernel program code

### 2. Initialized Data Segment
From the kernel

### 3. Uninitialized Data Segment (BSS)
Declared or init = 0 from the kernel

### 4. Heap
Grows upward

**Heap stores:** Kernel structures (task structs, page tables, device info)

```
--- A blank unallocated memory here which will be dynamically allocated ---
```

### 5. Stack Top
Growing downward

**Stack stores:** Local variables

---

## 1️⃣ Visual Representation: Kernel Memory Layout

```
0x00000000 ── BIOS + Bootloader (reserved)

0x00100000 ── Kernel starts here

     ↓

[ .text ]          ← Kernel code

[ .data ]          ← Kernel initialized globals/statics

[ .bss ]           ← Kernel uninitialized globals/statics (zeroed at boot)

[ Heap ]           ← Kernel heap: stores kernel structures (task structs, page tables, device info)

[ ... free memory for dynamic use ... ]

[ Stack top ]      ← Kernel stack (grows downward)
```

---

## 2️⃣ Each User-Space Process Layout

```
[ Text (code) ]      ← Executable instructions

[ Data (initialized) ] ← Global/static initialized variables

[ BSS (uninitialized) ] ← Global/static zeroed variables

[ Heap ]             ← Process dynamic allocations (malloc, new, textures, etc.)

[ Stack top ]        ← Process stack (grows downward)
```

### How the Kernel Manages Processes

- Each process has its own virtual address space; kernel maps them to physical RAM.

- Kernel tracks all these mappings in its heap/structures.

- Heap grows upward, stack grows downward — eventually, if they collide, the process crashes (stack overflow/heap overflow).

---

## 3️⃣ How It All Fits Together

| Component | Role | Details |
|-----------|------|---------|
| **Kernel** | The manager | Small footprint (heap + stack + code/data/bss) |
| **Processes** | The workers | Each gets its own text/data/bss/heap/stack |
| **Kernel heap/stack** | Metadata storage | Store metadata about all user processes and memory allocations |
| **Physical RAM** | Unified storage | Holds both kernel and user-space memory at the same time, coordinated by the kernel |

---

## 4️⃣ How Kernel Manages User-Space Applications

### What the Compiler/Linker Puts in the Binary

When you compile a program (`.exe` on Windows or `ELF` on Linux):

| Section | Contents |
|---------|----------|
| `.text` | Machine code for your functions |
| `.rodata` | Read-only constants (string literals, const tables) |
| `.data` | Initialized global/static variables |
| `.bss` | Uninitialized global/static variables (size only, no actual bytes) |

✅ **Key Point:** Stack and heap are **NOT** stored in the binary.

The compiler/linker assumes these will exist at runtime and emits calls to runtime library functions (`malloc`, `operator new`), but the actual memory is allocated at runtime.

---

### Who Creates Stack and Heap?

#### Stack
The **kernel/runtime loader** sets up the stack when the program starts.

| OS | Implementation |
|----|----------------|
| **Linux** | `execve()` system call sets up stack region with `argv`, `envp`, and auxiliary vectors |
| **Windows** | PE loader reserves stack region based on executable header's stack size |

> The compiler assumes a stack exists; the OS ensures it actually does.

#### Heap
The **compiler** generates code that calls allocation functions (`malloc`, `new`).  
The **OS** provides actual heap memory via system calls:

- **Linux:** `brk`/`mmap`
- **Windows:** `VirtualAlloc`

> The heap doesn't exist in the binary—it's created dynamically at runtime.

---

### Binary vs Runtime Memory Layout

#### Binary file (`.exe` / `ELF`)
```
✅ Contains:    .text, .rodata, .data, .bss
❌ Does NOT:    stack, heap
```

#### At runtime (process memory)
```
[ stack ]  ← Created by OS, grows downward
[ heap  ]  ← Created by OS dynamically, grows upward
[ bss   ]  ← Zeroed by loader/OS
[ data  ]  ← Initialized globals
[ text  ]  ← Loaded from binary
```

**Address handling:** Global/static variables get absolute addresses (relative to program load base) and go into `.data`/`.bss`.

---

### What the OS Does When Starting a Program

When you run a binary (e.g., `./myapp` or `.exe`), the OS performs these steps:

#### 1. Load the binary into memory
- Reads `.text`, `.rodata`, `.data`, `.bss` from file
- Places them at addresses in the process's virtual memory space

#### 2. Set up the stack
- Reserves a memory region for the stack
- Sets stack pointer (`SP`/`RSP`/`ESP`) at the top of this region
- Pushes `argv`, `envp`, and initial information onto the stack

#### 3. Set up the heap
- Marks a region for dynamic allocation
- Process calls `malloc`/`new` to request memory from this region

#### 4. Initialize BSS and Data
- `.data` → Copy initialized global/static variables from binary
- `.bss` → Zero out memory for uninitialized global/static variables

#### 5. Jump to the entry point
For C/C++: `_start` (assembly stub) → calls `main()`

---

### Key Points About Stack Pointer

- The **OS** chooses the stack location and size for the process
- The **compiler** generates code assuming a stack exists and references offsets from `SP`
- At runtime, the **OS** ensures `SP` points to the top of allocated stack so local variables and function calls work correctly