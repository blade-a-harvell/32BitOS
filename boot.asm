[BITS 16]
org 0x7C00

start:
    ; Set up the stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Disable interrupts
    cli

    ; Set video mode 0x13 (320x200, 256 colors)
    mov ax, 0x0013
    int 0x10

    ; Enter protected mode
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:init_pm

[BITS 32]
init_pm:
    ; Set up the segments
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Initialize the stack pointer
    mov esp, 0x90000

    ; Draw a pixel at (100, 100)
    mov eax, 0xA0000       ; Start of VGA video memory
    mov edi, eax
    add edi, (100 * 320 + 100) ; Calculate position
    mov byte [edi], 15     ; Color white

    ; Hang the system
hang:
    hlt
    jmp hang

[BITS 16]
gdt_start:
    dw 0x0000
    dw 0x0000
    db 0x00
    db 0x00
    db 0x00
    db 0x00

gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00

gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

times 510-($-$$) db 0
dw 0xAA55
