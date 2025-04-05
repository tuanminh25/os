[bits 16]
[org 0x7c00] 

; Set up segments and stack 
xor ax, ax
xor ds, ax                                      ; Set data segments = 0 
xor es, ax                                      ; Set extra segments = 0
xor ss, ax                                      ; Set stack segments = 0
mov sp, 0x7c00                                  ; Set stack pointer to 0x7c00

; Print message
mov si, hello_msg                               ; SI points to our message
call print_string l                             ; Call oyur string-printing routine

; Infinite loop (hang)


