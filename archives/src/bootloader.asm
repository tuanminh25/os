[bits 16]
[org 0x7c00] 

; Set up segments and stack 
xor ax, ax
mov ds, ax                                      ; Set data segments = 0 
mov es, ax                                      ; Set extra segments = 0
mov ss, ax                                      ; Set stack segments = 0
mov sp, 0x7c00                                  ; Set stack pointer to 0x7c00

; Save boot drive number
mov [BOOT_DRIVE], dl                            ; CHANGED: Store boot drive number

; Print welcome message
mov si, hello_msg                               ; SI points to our message
call print_string                               ; Call your string-printing routine

; Print loading message
mov si, loading_msg                             ; CHANGED: Print loading message
call print_string                               ; CHANGED: Call string-printing routine

; Load kernel
KERNEL_OFFSET equ 0x1000                        ; CHANGED: Address to load kernel
mov bx, KERNEL_OFFSET                           ; CHANGED: Set destination address
mov dh, 15                                      ; CHANGED: Number of sectors to read (15)
mov dl, [BOOT_DRIVE]                            ; CHANGED: Which drive to read from
call disk_load                                  ; CHANGED: Call disk_load function

; Switch to 32-bit protected mode
call switch_to_pm                               ; CHANGED: Enter protected mode

; Infinite loop (fallback, should never reach here)
jmp $                                           ; Jump to current address - jump forever

; ==========================================
; Function: print_string
; ==========================================
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

; ==========================================
; Function: disk_load - load DH sectors to ES:BX from drive DL
; ==========================================
disk_load:                                      ; CHANGED: Added disk_load function
    push dx                                     ; CHANGED: Store DX (contains sector count)
    
    mov ah, 0x02                                ; CHANGED: BIOS read sector function
    mov al, dh                                  ; CHANGED: Read DH sectors
    mov ch, 0x00                                ; CHANGED: Cylinder 0
    mov dh, 0x00                                ; CHANGED: Head 0
    mov cl, 0x02                                ; CHANGED: Start from sector 2 (sector after boot sector)
    
    int 0x13                                    ; CHANGED: BIOS interrupt for disk operations
    
    jc disk_error                               ; CHANGED: Jump if error (carry flag set)
    
    pop dx                                      ; CHANGED: Restore DX
    cmp dh, al                                  ; CHANGED: Compare sectors expected with sectors read
    jne disk_error                              ; CHANGED: Display error if mismatch
    ret

disk_error:                                     ; CHANGED: Added disk error handler
    mov si, disk_error_msg                      ; CHANGED: Point to error message
    call print_string                           ; CHANGED: Print error message
    jmp $                                       ; CHANGED: Hang

; ==========================================
; GDT for 32-bit protected mode
; ==========================================
; GDT Start
gdt_start:                                      ; CHANGED: Added GDT

gdt_null:                                       ; CHANGED: Null descriptor
    dd 0x0                                      ; CHANGED: 4 bytes of zeros
    dd 0x0                                      ; CHANGED: 4 bytes of zeros

gdt_code:                                       ; CHANGED: Code segment descriptor
    dw 0xffff                                   ; CHANGED: Limit (bits 0-15)
    dw 0x0                                      ; CHANGED: Base (bits 0-15)
    db 0x0                                      ; CHANGED: Base (bits 16-23)
    db 10011010b                                ; CHANGED: 1st flags, type flags
    db 11001111b                                ; CHANGED: 2nd flags, Limit (bits 16-19)
    db 0x0                                      ; CHANGED: Base (bits 24-31)

gdt_data:                                       ; CHANGED: Data segment descriptor
    dw 0xffff                                   ; CHANGED: Limit (bits 0-15)
    dw 0x0                                      ; CHANGED: Base (bits 0-15)
    db 0x0                                      ; CHANGED: Base (bits 16-23)
    db 10010010b                                ; CHANGED: 1st flags, type flags
    db 11001111b                                ; CHANGED: 2nd flags, Limit (bits 16-19)
    db 0x0                                      ; CHANGED: Base (bits 24-31)

gdt_end:                                        ; CHANGED: Label for GDT size calculation

; GDT descriptor
gdt_descriptor:                                 ; CHANGED: GDT descriptor
    dw gdt_end - gdt_start - 1                  ; CHANGED: Size of GDT
    dd gdt_start                                ; CHANGED: Start address of GDT

; Define constants for GDT segment descriptor offsets
CODE_SEG equ gdt_code - gdt_start               ; CHANGED: Offset to code segment
DATA_SEG equ gdt_data - gdt_start               ; CHANGED: Offset to data segment

; ==========================================
; Switch to 32-bit protected mode
; ==========================================
switch_to_pm:                                   ; CHANGED: Added protected mode switch
    cli                                         ; CHANGED: Turn off interrupts
    lgdt [gdt_descriptor]                       ; CHANGED: Load GDT
    
    ; Set PE bit in CR0 to enter protected mode
    mov eax, cr0                                ; CHANGED: Get current value of CR0
    or eax, 0x1                                 ; CHANGED: Set PE bit
    mov cr0, eax                                ; CHANGED: Update CR0
    
    ; Perform far jump to flush pipeline and load CS
    jmp CODE_SEG:init_pm                        ; CHANGED: Far jump to 32-bit code

[bits 32]                                       ; CHANGED: Switch to 32-bit mode
; Initialize 32-bit protected mode
init_pm:                                        ; CHANGED: Protected mode initialization
    ; Update segment registers
    mov ax, DATA_SEG                            ; CHANGED: Set data segment
    mov ds, ax                                  ; CHANGED: Update DS
    mov ss, ax                                  ; CHANGED: Update SS
    mov es, ax                                  ; CHANGED: Update ES
    mov fs, ax                                  ; CHANGED: Update FS
    mov gs, ax                                  ; CHANGED: Update GS
    
    ; Set up stack
    mov ebp, 0x90000                            ; CHANGED: Set base pointer
    mov esp, ebp                                ; CHANGED: Set stack pointer
    
    ; Jump to kernel
    jmp KERNEL_OFFSET                           ; CHANGED: Jump to loaded kernel code

; Data
hello_msg db 'Hello, OS World!', 0
loading_msg db 'Loading kernel...', 0           ; CHANGED: Added loading message
disk_error_msg db 'Disk read error!', 0         ; CHANGED: Added disk error message
BOOT_DRIVE db 0                                 ; CHANGED: Variable to store boot drive number

; Padding and magic number
times 510-($-$$) db 0    ; Pad with zeros to make it exactly 512 bytes
dw 0xAA55                ; Boot signature at the end of the bootloader