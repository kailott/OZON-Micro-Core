format ELF

public _start
public _EOF
extrn _kernel_main
extrn __end

section ".prolog" executable

_start:
     ;  movzx edx, dl
     ;   push edx
     ;   push esi
     ;   push ebx

        xchg bx,bx
        lgdt [gdtr]
        jmp 0x8:@f
        @@:
        mov ax,0x10
        mov ds,ax
        mov es,ax
        mov ss,ax
        mov fs,ax
        mov gs,ax
        mov ebp,0x200000
        mov esp,0x200000
        mov edi,0xb8000
        mov ecx,0x1000
        mov al,0x0
        rep stosb
        push 0x400000 - 0x1000
        mov eax,__end
        call _kernel_main
@@:
        ;cli
        ;hlt
        jmp @b

section ".data" writable

gdt:
GDT:
        NULL_descr      db              8 dup(0)
        CODE32_descr    db              0FFh,0FFh,00h,00h,00h,10011010b,11001111b,00h
        DATA_descr      db              0FFh,0FFh,00h,00h,00h,10010010b,11001111b,00h
        GDT_size        equ             $-GDT
gdtr:
        dw $ - gdt
        dd gdt
section ".epilog" writable
_EOF dd $