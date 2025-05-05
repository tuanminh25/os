; ////////////////////////////////////////////////////// Start up flow /////////////////////////////////////////////
; Power on -> BIOS -> bootloader -> kernel -> operating system
; BIOS looks for bootloader in the first 512 bytes (bootsector or MBR)
; Bootloader: parses filesystem, loads kernel
; Kernel: starts managing hardware, memory, launching user processes
; //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; ////////////////////////////////////////////////////// BIOS //////////////////////////////////////////////////////
; BIOS: basic input output system - low level firmware code in chip of the motherboard
;   + power on self test - check cpu,ram essential devices, displays error if soomething off
;   + initialize hardware: prepare essential devices: disk drives, timers, display ...
;   + find bootable devices: USB -> HDD -> CD , reads first 512 bytes (bootsector or MBR) from that device to memory at 0x7C00
;   + transfer control to bootloader after boot sector is loaded
;   + provides low level services
;               int 13h read sectors from disk
;               int 10h print char on screen
;               int 16h wait for keypress
; //////////////////////////////////////////////////////////////////////////////////////////////////////////////////


; ///////////////////////////////////////////////////// bootloader ////////////////////////////////////////////////
; Definition:
;       - small program that runs immediately after the computer is powered on
;       - first software that bios or firmware loads into memory

; Why does this matters?
;       - It bridges the gap between OS and BIOS/UEFI
;       - BIOS does not know filesystem/kernels/ modern OS structure but bootloader knows
;
;
; It's flow on this file:
;       - BIOS loads this file (bootloader) at OX7C00
;       - Parsing and interpreting drive disk based on FAT12 file system (assume that input drive is FAT12 drive) 
;       - Look for kernel binary file based on assumption 
;       - Load kernel to memory and transfer control to kernel 
;
;
; /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


; //////////////////// BIOS loads this file (bootloader) at OX7C00  ////////////////////////////////////////////////

; Boot sector header and setup
org 0x7C00                                          ; code will be loaded at memory 0x7C00 (standard location for BIOS loads the boot sector)
bits 16                                             ; assembling for 16-bit mode
; /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; macro for new line CR+LF
%define ENDL 0x0D, 0x0A                             

; jump to start, skip FAT12 header 
; nop is filler, making the jump exactly 3 bytes - required for bootsector
jmp short start
nop



; //////////////////////////////////////// Metaphore  ////////////////////////////////////////////////
; physical disk = empty room
; file formating = design layout
; bootloader = interpret those design into the room
; os = tenant move into the room
;
; so that's why some modern machine, hardware can be run with different os
; and some old one like floppy disk can not use ntfs
; ////////////////////////////////////////////////////////////////////////////////////////////////////



; //////////////////// FAT12 file system headers related  ////////////////////////////////////////////////
; assembler will run through everything in compilation
; db, dw, dd will be "defined" at compilation time (initialized at compilation time)
; everything down here is just metadata fields
; bdb: bios data block

; Technically required a tag defining that this is fat 12 
bdb_oem:                    db 'MSWIN4.1'            

;
; 1.44MB FAT12 floppy disk layout
; 
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880                 ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h                 ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9                    ; 9 sectors/fat
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; extended boot record - metadata used by FAT12 filesystem
ebr_drive_number:           db 0                    ; 0x00 floppy, 0x80 hdd 
                            db 0                    ; reserved

ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h   ; serial number, value doesn't matter
ebr_volume_label:           db 'FLOW     OS'        ; 11 bytes, padded with spaces
ebr_system_id:              db 'FAT12   '           ; 8 bytes
; ///////////////////////////////////////////////////////////////////////////////////////////////////////





; ////////////////////////////////////// Bootloader code  ////////////////////////////////////////////////

; ////////////////////////////////////// Set up to correct mem address  //////////////////////////////////
start: 
    ; setup data segments - registers and the stack
    mov ax, 0                                       ; can't set ds/es directly
    mov ds, ax
    mov es, ax
    
    ; setup stack
    mov ss, ax
    mov sp, 0x7C00                                  ; set stack from 0x7C00, stack grows downwards from there

    ; This realigns CodeSegment:InstructionPointer to ensure proper execution, 
    ; in case BIOS started at a segment other than 0000.
    ; techincally ensuring that 
    push es                                         ; ealier it is 0x0000
    push word .after
    retf                                            ; get physical address regarding to point 0x0000 rather than just current cs


; ////////////////////////////////////// Logic and interpret disk  //////////////////////////////////
.after:

    ; read something from floppy disk
    ; BIOS should set DL to drive number
    mov [ebr_drive_number], dl

    ; show loading message
    mov si, msg_loading
    call puts


    ; Ask BIOS how many heads, sectors per track, cylinders this disk has
    push es                             ; save es segment register to stack (prevent overwritten)
    mov ah, 08h                         ; get drive parameter = disk geometry
    int 13h                             ; call bios disk service 
    jc floppy_error                     ; ah = 08h, int 13 returns to cf, jc (jump if carry check)
                                        ; will jump to floppy_error when cf is equal to 1 (error)

    pop es

; In physical disk hardware, cylinder does not exist, it is a mathematical tool
; A disk drive contains set of platters. 
;   Each platters contains 2 surfaces each surface has 1 head that can both read write
;       Each head contains set of tracks 
;           Each track contains set of sectors (typically 512 bytes)

; Cylinder is pretty much cut vertically through all of them (assuming all of platters having same radius)
; (ie track 5 on all heads forms cylinder 5)
; Cylinder techinically is to help read/write across all head at a specific sectors at the same time

    ; cx is 16 bit register
    ; cl is lower 8 of cx 
    ; ch is upper 8 of cx
    ; then store result
    and cl, 0x3F                        ; remove top 2 bits containing cylinder number (not related here)
    xor ch, ch                          ; clear ch 
    mov [bdb_sectors_per_track], cx     ; sector count

    inc dh
    mov [bdb_heads], dh                 ; head count

    ; read FAT12 root directory
    ; compute LBA of root directory = reserved + fats * sectors_per_fat
    ; note: this section can be hardcoded
    mov ax, [bdb_sectors_per_fat]
    mov bl, [bdb_fat_count]
    xor bh, bh
    mul bx                              ; ax = (fats * sectors_per_fat)
    add ax, [bdb_reserved_sectors]      ; ax = LBA of root directory
    push ax

    ; compute size of root directory = (32 * number_of_entries) / bytes_per_sector
    mov ax, [bdb_dir_entries_count]
    shl ax, 5                           ; ax *= 32
    xor dx, dx                          ; dx = 0
    div word [bdb_bytes_per_sector]     ; number of sectors we need to read

    test dx, dx                         ; if dx != 0, add 1
    jz .root_dir_after
    inc ax                              ; division remainder != 0, add 1
                                        ; this means we have a sector only partially filled with entries






.root_dir_after:

    ; read root directory into memory
    mov cl, al                          ; cl = number of sectors to read = size of root directory
    pop ax                              ; ax = LBA of root directory
    mov dl, [ebr_drive_number]          ; dl = drive number (we saved it previously)
    mov bx, buffer                      ; es:bx = buffer
    call disk_read

    ; search for kernel.bin
    xor bx, bx
    mov di, buffer

.search_kernel:
    mov si, file_kernel_bin             ; search for kernel file bin: "file_kernel_bin"
    mov cx, 11                          ; compare up to 11 characters
    push di
    repe cmpsb
    pop di
    je .found_kernel

    add di, 32
    inc bx
    cmp bx, [bdb_dir_entries_count]
    jl .search_kernel

    ; kernel not found
    jmp kernel_not_found_error

.found_kernel:                          ; when found the kernel, get starting clusters from directory entry

    ; di should have the address to the entry
    mov ax, [di + 26]                   ; first logical cluster field (offset 26)
    mov [kernel_cluster], ax

    ; load FAT from disk into memory
    mov ax, [bdb_reserved_sectors]      ; read FAT
    mov bx, buffer
    mov cl, [bdb_sectors_per_fat]
    mov dl, [ebr_drive_number]
    call disk_read

    ; read kernel and process FAT chain
    mov bx, KERNEL_LOAD_SEGMENT
    mov es, bx
    mov bx, KERNEL_LOAD_OFFSET

; Follow FAT chain to load all clusters of the file
.load_kernel_loop:
    
    ; Read next cluster
    mov ax, [kernel_cluster]
    
    ; not nice :( hardcoded value
    add ax, 31                          ; first cluster = (kernel_cluster - 2) * sectors_per_cluster + start_sector
                                        ; start sector = reserved + fats + root directory size = 1 + 18 + 134 = 33
    mov cl, 1
    mov dl, [ebr_drive_number]
    call disk_read

    add bx, [bdb_bytes_per_sector]

    ; compute location of next cluster
    mov ax, [kernel_cluster]
    mov cx, 3
    mul cx
    mov cx, 2
    div cx                              ; ax = index of entry in FAT, dx = cluster mod 2

    mov si, buffer
    add si, ax
    mov ax, [ds:si]                     ; read entry from FAT table at index ax

    or dx, dx
    jz .even

.odd:
    shr ax, 4
    jmp .next_cluster_after

.even:
    and ax, 0x0FFF

.next_cluster_after:
    cmp ax, 0x0FF8                      ; end of chain
    jae .read_finish

    mov [kernel_cluster], ax
    jmp .load_kernel_loop

; When read is finished, jump to the already loaded kernel
.read_finish:
    
    ; jump to our kernel
    mov dl, [ebr_drive_number]          ; boot device in dl

    mov ax, KERNEL_LOAD_SEGMENT         ; set segment registers
    mov ds, ax
    mov es, ax

    jmp KERNEL_LOAD_SEGMENT:KERNEL_LOAD_OFFSET

    jmp wait_key_and_reboot             ; should never happen

    cli                                 ; disable interrupts, this way CPU can't get out of "halt" state
    hlt


;
; Error handlers
;

floppy_error:
    mov si, msg_read_failed
    call puts
    jmp wait_key_and_reboot

kernel_not_found_error:
    mov si, msg_kernel_not_found
    call puts
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 16h                     ; wait for keypress
    jmp 0FFFFh:0                ; jump to beginning of BIOS, should reboot

.halt:
    cli                         ; disable interrupts, this way CPU can't get out of "halt" state
    hlt


;
; Prints a string to the screen
; Params:
;   - ds:si points to string
;
puts:
    ; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si    
    ret

;
; Disk routines
;

;
; Converts an LBA address to a CHS address
; Parameters:
;   - ax: LBA address
; Returns:
;   - cx [bits 0-5]: sector number
;   - cx [bits 6-15]: cylinder
;   - dh: head
;

lba_to_chs:

    push ax
    push dx

    xor dx, dx                          ; dx = 0
    div word [bdb_sectors_per_track]    ; ax = LBA / SectorsPerTrack
                                        ; dx = LBA % SectorsPerTrack

    inc dx                              ; dx = (LBA % SectorsPerTrack + 1) = sector
    mov cx, dx                          ; cx = sector

    xor dx, dx                          ; dx = 0
    div word [bdb_heads]                ; ax = (LBA / SectorsPerTrack) / Heads = cylinder
                                        ; dx = (LBA / SectorsPerTrack) % Heads = head
    mov dh, dl                          ; dh = head
    mov ch, al                          ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah                           ; put upper 2 bits of cylinder in CL

    pop ax
    mov dl, al                          ; restore DL
    pop ax
    ret


;
; Reads sectors from a disk
; Parameters:
;   - ax: LBA address
;   - cl: number of sectors to read (up to 128)
;   - dl: drive number
;   - es:bx: memory address where to store read data
;
disk_read:

    push ax                             ; save registers we will modify
    push bx
    push cx
    push dx
    push di

    push cx                             ; temporarily save CL (number of sectors to read)
    call lba_to_chs                     ; compute CHS
    pop ax                              ; AL = number of sectors to read
    
    mov ah, 02h
    mov di, 3                           ; retry count

.retry:
    pusha                               ; save all registers, we don't know what bios modifies
    stc                                 ; set carry flag, some BIOS'es don't set it
    int 13h                             ; carry flag cleared = success
    jnc .done                           ; jump if carry not set

    ; read failed
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry

.fail:
    ; all attempts are exhausted
    jmp floppy_error

.done:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax                             ; restore registers modified
    ret


;
; Resets disk controller
; Parameters:
;   dl: drive number
;
disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc floppy_error
    popa
    ret


msg_loading:            db 'Loading...', ENDL, 0
msg_read_failed:        db 'Read from disk failed!', ENDL, 0
msg_kernel_not_found:   db 'STAGE2.BIN file not found!', ENDL, 0
file_kernel_bin:        db 'STAGE2  BIN'
kernel_cluster:         dw 0

KERNEL_LOAD_SEGMENT     equ 0x2000
KERNEL_LOAD_OFFSET      equ 0


times 510-($-$$) db 0
dw 0AA55h

buffer: