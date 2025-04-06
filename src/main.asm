org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
    jmp main


;
; Prints a string to the screen
; Params: 
;   - ds:si points to string
;
puts:
    ; save registers we will modify
    push si
    push ax

.loop:
    lodsb                       ; load next char in al
    or al, al                   ; verify if next char is null
    jz .done                    

    mov ah, 0x0e
    mov bh, 0
    int 0x10

    jmp .loop


.done:
    pop ax
    pop si
    ret




main:
    ; Set up data segment
    mov ax, 0                   ; ds/es can not be written directly
    mov ds, ax
    mov es, ax

    ; Set up stack
    mov ss, ax
    mov sp, 0x7C00              ; stack grows downward from where we are loaded from memory

    ; print message
    mov si, msg_hello
    call puts

    hlt

.halt:
    jmp .halt


msg_hello: db 'Hello World OS!', ENDL, 0

times 510-($-$$) db 0
dw 0AA55h