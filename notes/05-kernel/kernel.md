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
