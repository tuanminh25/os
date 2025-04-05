[bits 16]
[org 0x7c00] 

; Set up segments and stack 
xor ax, ax
mov ds, ax                                      ; Set data segments = 0 
mov es, ax                                      ; Set extra segments = 0
mov ss, ax                                      ; Set stack segments = 0
mov sp, 0x7c00                                  ; Set stack pointer to 0x7c00

; Print message
mov si, hello_msg                               ; SI points to our message
call print_string                               ; Call oyur string-printing routine

; Infinite loop (hang)
jmp $                                           ; Jump to current address - jump forever


print_string:                                   ; print string func
    push ax
    push si

    mov ah, 0x0E

.loop:                                          ; Print char by char
    lodsb                                         
    test al, al                                 ; AND operator of al and al
    jz .done                                    ; jump if zero
    int 0x10                                    ; 
    jmp .loop

.done: 
    pop si                                      ; Restore register
    pop ax                                      
    ret

; Data
hello_msg db 'Hello, OS World!', 0

; Padding and magic number
times 510-($-$$) db 0    ; Pad with zeros to make it exactly 512 bytes
dw 0xAA55                ; Boot signature at the end of the bootloader
