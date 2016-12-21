global start

section .text
bits 32    ; boot into protected mode from grub
start:
    ; Point the first entry of the level 4 page table to the first entry in the
    ; p3 table
    mov eax, p3_table
    or eax, 0b11    			   ; set read and write bits in our page table
    mov dword [p4_table + 0], eax  ; set this value at for the p4 table

    ; Point the first entry of the level 3 page table to the first entry in the
    ; p2 table
    mov eax, p2_table
    or eax, 0b11
    mov dword [p3_table + 0], eax

    ; point each page table level two entry to a page
    mov ecx, 0         ; counter variable
.map_p2_table:
	mov eax, 0x200000  ; 2MiB
	or eax, 0b10000011 ; add all addresses to the p2 table, in increments of 8
    mov [p2_table + ecx * 8], eax 
    inc ecx            ; increment counter variable
    cmp ecx, 512       ; set compare flag, loop 512 times
    jne .map_p2_table  ; move to a section based on compare flag
	
	; move page table address to cr3
    mov eax, p4_table
    mov cr3, eax

    ; enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; set the long mode bit in memory specific registers (msr)
    mov ecx, 0xC0000080
    rdmsr          
    or eax, 1 << 8
    wrmsr

    ; enable paging
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax     ; set bits 31 and 16

	; print hello world to the console to signify that this worked
    mov word [0xb8000], 0x0248 ; H
    mov word [0xb8002], 0x0265 ; e
    mov word [0xb8004], 0x026c ; l
    mov word [0xb8006], 0x026c ; l
    mov word [0xb8008], 0x026f ; o
    mov word [0xb800a], 0x022c ; ,
    mov word [0xb800c], 0x0220 ;
    mov word [0xb800e], 0x0277 ; w
    mov word [0xb8010], 0x026f ; o
    mov word [0xb8012], 0x0272 ; r
    mov word [0xb8014], 0x026c ; l
    mov word [0xb8016], 0x0264 ; d
    mov word [0xb8018], 0x0221 ; !
    hlt

section .bss
align 4096

p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096

section .rodata
gdt64:
    dq 0   ; define quad word 0 
.code: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53)
.data: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41)
.pointer:
    dw .pointer - gdt64 - 1
    dq gdt64

lgdt [gdt64.pointer]

; update selectors
mov ax, gdt64.data
mov ss, ax
mov ds, ax
mov es, ax

; jump to long mode!
jmp gdt64.code:long_mode_start

section .text
bits 64
long_mode_start:
    mov rax, 0x2f592f412f4b2f4f
    mov qword [0xb8000], rax
    hlt

