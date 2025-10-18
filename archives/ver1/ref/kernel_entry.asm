[bits 32]
[extern kernel_main]  ; Declare that kernel_main exists elsewhere

; Kernel entry point
global _start
_start:
    ; Set up stack
    mov esp, kernel_stack_top
    
    ; Call C++ kernel
    call kernel_main
    
    ; Halt if kernel returns
    cli                 ; Disable interrupts
    hlt                 ; Halt the CPU
    jmp $               ; Infinite loop (fallback)

; Reserve space for kernel stack
section .bss
align 4
kernel_stack_bottom: resb 16384  ; 16 KB for stack
kernel_stack_top: