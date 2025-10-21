# Interrupts in Kernel Development

## Why Clear Interrupts Before Setting Stack Pointer?

One of the critical early kernel steps:

```assembly
cli    # Clear Interrupts
cld    # Clear Direction Flag
```

---

## What is an Interrupt?

An **interrupt** is a signal to the CPU that something needs immediate attention.

### How It Works:
1. Temporarily pauses current code
2. Saves CPU state
3. Jumps to an "interrupt handler"

---

## The Danger of Interrupts Without IDT

Before setting up the **IDT (Interrupt Descriptor Table)**, leaving interrupts enabled is dangerous.

### The Problem:
The interrupt table tells the CPU where to jump when an interrupt occurs. **Right now, there is no interrupt descriptor table**, so the CPU has no idea where to jump.

### Consequences:

| What Happens | Result |
|--------------|--------|
| Jump to random location or `0x0` | Undefined behavior |
| Kernel crashes immediately | Triple fault, freeze, or reboot |

---

## Why `cli` Fixes This

```assembly
cli    # Disable external interrupts
```

**Purpose:** Tells the CPU "don't handle any external interrupts right now."

This prevents anything from interrupting between startup and `main()`.

> 💡 **Later:** Re-enable interrupts with `sti` after the IDT is properly configured.

---

## What is a Triple Fault?

A **triple fault** occurs when cascading errors cause the CPU to give up and reset.

### The Cascade:

| Stage | What Happens |
|-------|--------------|
| **1️⃣ First Fault** | CPU tries to invoke handler |
| **2️⃣ Second Fault** | CPU tries to handle first fault, but handler itself causes another fault |
| **3️⃣ Third Fault** | CPU gives up and triggers **CPU reset** 🔄 |

**Result:** System reboot or freeze.
