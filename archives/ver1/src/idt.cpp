#include "kernel.h"

// IDT entry structure
struct idt_entry {
    uint16_t base_low;
    uint16_t selector;
    uint8_t always0;
    uint8_t flags;
    uint16_t base_high;
} __attribute__((packed));

// IDT pointer structure
struct idt_ptr {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

// Declare IDT
struct idt_entry idt[256]; // array of idt entry
struct idt_ptr idtp; // call an empty struct of idt_ptr and name it idtp

// Function to load IDT
extern "C" void load_idt(struct idt_ptr* idt_ptr);

// Set an entry in the IDT
void idt_set_gate(uint8_t num,  uint32_t base, uint16_t sel, uint8_t flags) {
    idt[num].base_low = (base & 0xFFFF);
    idt[num].base_high = (base >> 16) & 0xFFFF;
    idt[num].selector = sel;
    idt[num].always0 = 0;
    idt[num].flags = flags;
}


void init_idt() {
    idtp.limit = (sizeof(struct idt_entry) * 256) - 1;
    idtp.base = (uint32_t)&idt;

    // Clear out the IDT
    for (int i = 0; i < 256; ++i) {
        idt_set_gate(i, 0, 0, 0);
    }

    // Set up exception handlers (simplified for now)
    // real implementation would set up proper handlers for each exception

    // Loads idt
    load_idt(&idtp);

    // Enable interrupts
    asm volatile("sti");
}