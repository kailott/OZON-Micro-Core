;SMP init code for Ozon OS
;Copyright © 2016-2017 Kailot II. All rights reserved.
;Author: Kailot II
INIT_IPI_command    equ 000C4500h
STARTUP_IPI_command equ 000C4600h or (0x1000 shr 12)
enable_smp:
mov ecx, 0x1B
rdmsr
bts eax, 11
wrmsr
mov esi, ap_proc_real_mode_init
mov edi, 0x1000
mov ecx,0x100
cld
rep movsb

mov  eax, INIT_IPI_command ;IPI
mov [0xFEE00300], eax
@@:
bt  dword [0xFEE00300],12
jc  @b
mov eax, 10000
call delay

mov  eax, STARTUP_IPI_command	;SIPI
mov [0xFEE00300], eax
@@:
bt  dword [0xFEE00300],12
jc  @b
mov eax, 200
call delay

mov  eax, STARTUP_IPI_command  ;SIPI
mov [0xFEE00300], eax
@@:
bt  dword [0xFEE00300],12
jc  @b

mov eax, 5000
call delay
ret

delay:
; input
;	EAX - microseconds

pushad

mov	ecx, eax
mov	eax, 1000000
xor	edx, edx
div	ecx
	
mov	ecx, eax
mov	eax, 1193182
xor	edx, edx
div	ecx
out	42h, al
xchg	al, ah
out	42h, al

.rep:
in	al,0x61
test	al, 20h
jz	.rep
popad
ret

;init ap-pocessor stack and seg register
ap_proc_protect_mode_init:
mov ax,0x10
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
inc [cpu_count]
@@:
bt [spin],0
jnc @b
lock btr dword [spin],0
jnc @b
add [stack_ptr],0x100
mov eax,[stack_ptr]
mov esp,eax
lock bts dword [spin],0

jmp   switch_to_long_mode


;Open A20, disable int & switch to Protect mode
ap_proc_real_mode_init:
use16
org 0
rm_start:
		mov		ax,cs
		mov		ds,ax
		mov		es,ax
		in		al,92h
		or		al,2
		out		92h,al

		lgdt		fword [RM_GDTR]

		cli
		in		al,70h
		or		al,80h
		out		70h,al

		mov		eax,cr0
		or		al,1
		mov		cr0,eax
		db		66h
		db		0EAh			
ENTRY_OFF	dd		ap_proc_protect_mode_init
		dw		0x8
RM_GDTR:
		dw GDT_size
		dd GDT

use32
org ap_proc_real_mode_init + (RM_GDTR - rm_start) + 6
ap_proc_real_mode_init_size	dd $ -	 ap_proc_real_mode_init