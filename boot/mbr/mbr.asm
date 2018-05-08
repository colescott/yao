[BITS 16]
[ORG 0x7c00]

; Memory layout:
; 0x7c00 stack, growing down
; 0x7c00 to 0x7e00 - MBR
;   0x7c00 to 0x7dc0 - MBR boot code (this file)
;     code:
;       _start - clear interrupts, setup the stack
;       main - calls fetchE820Map, exits with hello world string
;       fetchE820map - uses int 15h, eax=e820h to fetch a memory map from the BIOS, stored in the heap area
;       exit - prints null terminated in si, then halt()s
;       halt - infinite loop
;     strings (null terminated):
;       hello_world_msg, e820_error_msg
;   0x7dc0 to 0x7e00 - MBR partition table (64 bytes, 4x 16 byte partition entries)
; 0x7e00 heap, growing upwards

_start:
; clear interrupts
    cli
; Set Stack Segment to 0
    xor ax, ax
    mov ss, ax
; Set Stack Pointer to 0x7c00 (stack will grow down below the start of the MBR)
    mov ax, 0x7c00
    mov sp, ax
    ; falls into main
main:
    call fetchE820Map
    mov si, hello_world_msg
    jmp exit

; fetchE820Map(); fetches memory map and stores it in heap area
fetchE820Map:
    pusha
; set [es:di] to [0:AFTER_MBR]
    xor ax, ax
    mov es, ax
    mov di, AFTER_MBR
; setup 32-bit variables that the BIOS expects
    xor ebx, ebx
    mov edx, 0x534D4150
; eax = e820h is the specific BIOS function we want to call
    mov eax, 0xE820
; ecx is maximum length of memory entry record (20 byte record length is standard, 24 could exist)
    mov ecx, 24
; call into the bios interrupt 0x15, function e820h
    int 0x15
; if the carry flag is set on the first record, it failed
    jc .fail
; magic number in eax means it succeeded
    cmp eax, 0x534D4150
    jne .fail
    jmp .cleanup
.loop:
; we have to manually increment di to point to the next to point to a new location in memory to store the next record
    add di, 24
; just setting eax and ecx to the same values as before for the same reasons
    mov eax, 0xE820
    mov ecx, 24
; call interrupt, this time in a loop
    int 0x15
; carry flag, or ebx being set to zero means we're done
    jc .done
    cmp ebx, 0
    je .done
.cleanup:
; cleanup record to be ACPI compliant
    mov [es:di + 20], dword 1
    jmp .loop
.done:
; restore registers and return to calling function
    popa
    ret
.fail:
; print out error message and exit, happens when first call to BIOS fails
    mov si, e820_error_msg
    jmp exit

; exit(si=msg) does not return; writes null terminated string pointed to by [0:si] in white on blue text to the VGA text buffer, then halt()
exit:
; es:di = 0xb800 : 0
    mov bx, 0xb800
    mov es, bx
    xor di, di
; ds:si = 0:msg
    xor bx, bx
    mov ds, bx
.loop:
; al = next letter from string
    lodsb
; if al == 0, that's the null byte so we're done
    cmp al, 0
    je .done
; set the background and foreground color (ah)
    mov ah, 0x1f ; 0x1f -> white on blue
; store letter and attributes (fg / bg color) in VGA text buffer (starts at 0x8b000 / 0xb800:0x0000)
    stosw
    jmp .loop
.done:
    ; falls into halt()

; halt(); infinite loop without hogging CPU
halt:
    hlt
    jmp halt

; strings:
; db = declare byte, can be used with multiple operands to declare multiple bytes
hello_world_msg: db 'Hello, World!', 0
e820_error_msg: db 'Getting e820 memory map failed!', 0

; pad MBR to correct length (448 bytes)
; $$ = address of beginning of program
; $ = address of current position
; ($-$$) = offset from beginning of file (length in bytes of all code up to this point)
times 446 - ($-$$) db 'Z'

; < MBR partitions goes here >

AFTER_MBR EQU ($$ + 512) ; 0x7e00
