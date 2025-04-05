[bits 32]
[extern kernel_main]                                ; Declare kernel_main exist outside

; Kernel entry point
global_start
_start

    ; Set up stack
    mov esp, kernel_stack_top                       ; esp = stack pointer is set to top

    ; Call C++ kernel
    call kernel_main

    ; Halt if return
    cli                                             ; Disable if kernel returns
    hlt                                             ; hlt CPU
    jmp $                                           

; reserve space for kernel stack
section .bss
align 4
kernel_stack_bottom: resb 16384 ; 16kb for stack
kernel_stack_top: 
