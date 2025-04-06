[bits 32]
global load_idt

; load_idt - Loads the Interrupt Descriptor Table
; stack: [esp + 4] The address of the IDT pointer
load_idt:
    mov eax, [esp + 4]  ; Get the pointer to the IDT
    lidt [eax]          ; Load the IDT
    ret                 ; Return to the calling function