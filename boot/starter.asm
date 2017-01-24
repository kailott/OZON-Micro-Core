;xStarter module for Ozon OS
;Copyright © 2016-2017 Kailot II. All rights reserved.
;Author: Kailot II
format	ELF executable
DEFINE x64_virtual_base 0xFFFFFFFFC0000000
DEFINE my_virtual_base	0x100000
entry	start
segment readable executable
include 'macro/proc32.inc'
start:
;Multiboot header
jmp    @f
align  4
DEFINE magic 0x1BADB002
DEFINE flags 0x3  and (1 shl 16)
dd magic
dd flags
dd -(magic+flags)
@@:
;Save pointer to multiboot informat
mov [multiboot_ptr],ebx
;load main GDT
lgdt fword [GDTR]
mov ax,0x10
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,AP_STACK
add eax,0x100
mov [stack_ptr],eax

mov esp,eax
;Clear screen
mov edi,0xB8000
xor eax,eax
mov ecx,(80*2)*24 ;visible memory size
rep stosd
;print msg_1
mov ax,(0xA shl 8)
mov esi,msg_1
call print
;print msg_2
mov ax,(0xA shl 8)
mov esi,msg_2
call print
;Check APIC support
mov eax,1
cpuid
test edx,1 shl 9
jnz @f
APIC_not_support:
mov ax,(0xC shl 8)
mov esi, err_3
call print
mov ax,(0xC shl 8)
mov esi, err_2
call print
@@:
;
call enable_smp
;print msg_3
mov ax,(0xA shl 8)
mov esi,msg_3
call print
mov ebx,[multiboot_ptr]
;Find addition "kernel64"
;Chek flags
mov eax,[ebx] ;Multiboot info flags
test eax, 1 shl 3 ; Add load flags
jnz @f
no_mod_load:
mov ax,(0xC shl 8)
mov esi, err_1
call print
hlt
jmp $
;Chek mod count
@@:
mov edx,[ebx+0x14]
test edx,edx
jz no_mod_load
;Ok, module load , find main module
mov eax,[ebx+0x18]
;While
@@: ; EAX = pointer on mods structure array
;Normale & print mod name
mov esi,[eax+8]
call mod_name_definition
push eax
push esi
mov eax,0xB shl 8
call print
pop esi
pop eax
;comparate string
mov ecx,[x64_name_size]
mov edi,x64_name
rep cmpsb
jz @f
add eax,0x10
dec edx
jz  no_mod_load
jmp @b
@@:
push eax
mov eax,0xA shl 8
mov esi,msg_4
call print
pop eax
;Main module find , save base & size
mov ebx,[eax]
mov [x64_base],ebx
mov ebx,[eax+4]
mov [x64_size],ebx
;Так как в этом режиме у нас есть доступ почти ко всей памяти
;Инициализацию менеджеров памяти лучше провести здесь




;mov ebx,[multiboot_ptr]   '
;mov eax, __my_memory_map
;ccall llmm,[multiboot_ptr],eax
;call hydrogen.init




;mov eax,dword [llmm_data.phy_memory_size]
;mov [msg_7_app],eax
;mov eax,dword [llmm_data.phy_memory_size+4]
;mov [msg_7_app+4],eax
;mov ax,(0xA shl 8)
;mov esi,msg_7
;call print


;@@:
;
;mov eax,[ __free_memory_area_list]
;ccall get_used_area,[multiboot_ptr]
;cmp ecx,0
;je @f
;mov dword [msg_8_app], eax
;mov ax,(0xA shl 8)
;mov esi,msg_8
;call print
;jmp @b
;@@:



mov [_PML4+ (((my_virtual_base shr 39) and 0x1FF) * 8 )], dword _M_PDPE or 3
;mov dword [_PML4] , _PML4 or 3


mov [_M_PDPE + (((my_virtual_base shr 30) and 0x1FF) * 8 )], dword _M_PDE or 3



mov [_M_PDE + (((my_virtual_base shr 21) and 0x1FF) * 8 )], dword _M_PTE or 3


;mov eax,[x64_base]
;and eax, 0xFFFFF000
;or eax,3



;mov [_M_PTE + (((my_virtual_base shr 12) and 0x1FF) * 8 )], dword my_virtual_base or 3
;mov [_M_PTE + ((((my_virtual_base + 0x1000) shr 12) and 0x1FF) * 8 )], dword (my_virtual_base + 0x1000) or 3
mov esi,_M_PTE + (((my_virtual_base shr 12) and 0x1FF) * 8 )
mov eax,dword my_virtual_base or 3
mov ecx,511
@@:
mov [esi], dword eax
add eax,0x1000
add esi,8
loop @b





mov [_M_PTE + ((((my_virtual_base - 0x1000) shr 12) and 0x1FF) * 8 )], dword 0xB8000 or 3




switch_to_long_mode:




xchg bx,bx

mov ecx, 0x1B
rdmsr
bt eax, 8
jnc @f

lock bts dword [spin],1
@@:
bt [spin],1
jnc @b








lock btr dword [spin],1
mov eax,[ 0xFEE00000 + 0x0020]
shr eax,28
and eax,0xF
mov ebx,ascii_trans
xlatb
mov [msg_5_app], byte al
mov eax,[ 0xFEE00000 + 0x0020]
shr eax,24
and eax,0xF
xlatb
mov [msg_5_app+1], byte al
mov esi,msg_5
mov eax, 0xD shl 8
call print

mov eax, 80000000h ; Extended-function 8000000h.
cpuid ; Is largest extended function
cmp eax, 80000000h ; any function > 80000000h?
jbe no_long_mode ; If not, no long mode.
mov eax, 80000001h ; Extended-function 8000001h.
cpuid ; Now EDX = extended-features flags.
bt edx, 29 ; Test if long mode is supported.
jnc no_long_mode ; Exit if not supported.

lock bts dword [spin],1
@@:






;Create MMU Table
mov ecx, 0xC0000080 ; EFER
rdmsr
bts eax,8  ; EFER.LME = 1
wrmsr


;Enable PAE
mov eax,cr4
bts eax,5
mov cr4,eax


mov eax,_PML4
mov cr3,eax
mov eax, cr0

bts eax, 31 ; PG = 1
mov cr0, eax
lock bts dword [spin],1

jmp 24:LONG_MODE_ENTRY_POINT

no_long_mode:

mov esi,err_4
mov eax, 0xC shl 8
call print
lock bts dword [spin],1

jmp $



use64
LONG_MODE_ENTRY_POINT:
mov ax, ds  ; reload all segment registers
mov ds, ax
mov ss, ax
mov es, ax

mov rax,_K_PDPE  or 3
mov [_PML4+ (((x64_virtual_base shr 39) and 0x1FF) * 8 )], rax
mov rax,_K_PDE or 3
mov [_K_PDPE + (((x64_virtual_base shr 30) and 0x1FF) * 8 )], rax

mov rax,_K_PTE or 3
mov [_K_PDE + (((x64_virtual_base shr 21) and 0x1FF) * 8 ) ], rax

xor rax,rax
mov eax,[x64_base]
or al,3
mov [_K_PTE + (((x64_virtual_base shr 12) and 0x1FF) * 8 ) ], rax

mov rsi,x64_virtual_base



;@@:
;bt [x64_spin],0
;jnc @b
;lock btr dword [x64_spin],0
;jnc @b

;mov rsi,[screen_x64]
;mov rax,'O5Z5O5N5';
;mov [rsi],rax
;add [screen_x64],8
;mov rax,[rsi]
;mov [ my_virtual_base - 0x1000] ,rax
;lock bts dword [x64_spin],0
;jmp $
;push []

;xor rax,rax
;push rax
;mov rax,0
;mov eax,_PML4
;push rax
;mov [kernel_data.c_kernel_pml4],rax
;mov eax,_K_PDE
;mov [kernel_data.c_kernel_pde],rax
;mov eax,_K_PDPE
;mov [kernel_data.c_kernel_pdpe],rax
;mov eax,_K_PTE
;mov [kernel_data.c_kernel_pte],rax
;xor rax,rax
;mov eax,[multiboot_ptr]
;mov [kernel_data.c_multiboot_info],rax

jmp tword [@f]
@@:
dq  x64_virtual_base
dw  24

x64_spin dd 0xFFFFFFFF
screen_x64 dq my_virtual_base - 0x1000



use32

;jmp $


mod_name_definition:
;in  :
;    esi - pointer to path
;out :
;    esi - pointe  to name
push eax
push ebx
mov ebx,esi
cld
@@:
   lodsb
   test al,al
   jnz @b
   sub esi,2
@@:
   std
   lodsb
   cmp al,'/'
   je @f
   cmp al,'\'
   je @f
   test al,al
   jz @f
   cmp esi,ebx
   je @f
jmp @b
@@:
cld
add esi,2
pop ebx
pop eax
ret






print:
;mov esi,msg_3
mov edi,[current_txt_ptr]
;mov ax,(0xA shl 8) ;Easy green color
@@:
lodsb
stosw
cmp al,'#'
je @f
test al,al
jnz @b
add [current_txt_ptr], 80*2
ret
@@:

;Печатаем 64b число на дисплей
;esi - указывает на число
long_hex_print:
add esi,7
mov ebx,ascii_trans
mov ecx, 8
@@:
std
lodsb
cld
mov dl,al

ror al,4
and al,0xF

xlatb

stosw

mov al,dl
and al,0xF
xlatb

stosw

loop @b
add [current_txt_ptr], 80*2
ret
;jmp print





include 'smp.asm'



;section ".data" writable
;GDT
GDT:
	NULL_descr	db		8 dup(0)
	CODE32_descr	db		0FFh,0FFh,00h,00h,00h,10011010b,11001111b,00h
	DATA_descr	db		0FFh,0FFh,00h,00h,00h,10010010b,11001111b,00h
	CODE64_descr	db		00h, 00h,00h,00h, 00h,10011000b,00100000b,00h
	GDT_size	 =		$-GDT

label GDTR fword
		dw		GDT_size-1		
		dd		GDT
;DATA
x64_base	dd	0x0
x64_size	dd	0x0
;x64_jump_addr:
;x64_virt_addr	 dq	 0xFFFFC0000000
;		 dw	 24
multiboot_ptr	dd	0x0
stack_ptr	dd	0x0
cpu_count	dd	0x0
spin		dd	0x1
		dd	_PML4
current_txt_ptr dd	0xB8000
;STRING
x64_name	db	'kernel64'
x64_name_size	dd	$ - x64_name
msg_1:		db	'xStarter v0.01',0
msg_2:		db	'AP processors awakening',0
msg_3:		db	'Please, wait',0
msg_4:		db	'Kernel module found',0
msg_5:		db	'INIT CPU ID  = '
msg_5_app:	dw	0x2020
		db	0
msg_6:		db	'TOTAL CPU = '
msg_6_app:	dw	0x2020
		db	0
msg_7:		db	'All memory init: #'
msg_7_app:	dq	0x123456789ABCDEF0
		db	0
msg_8:		db	'Memory area list base of #'
msg_8_app:	dq	0x0
		db	0
err_1:		db	'FATAL : Additions not loaded.',0
err_2:		db	'Proc halt!',0
err_3:		db	'FATAL : APIC not supported',0
err_4:		db	'No x64 mode support!',0

ascii_trans	db	'0123456789ABCDEF',0
;Non-init data
AP_STACK:
rb 0x1000
;
segment readable writeable
align 0x1000

_PML4:
rb 0x1000
_K_PDPE:
rb 0x1000
_M_PDPE:
rb 0x1000
_K_PDE:
rb 0x1000
_M_PDE:
rb 0x1000
_K_PTE:
rb 0x1000
_M_PTE:
rb 0x1000
db 0x30

label EOF

