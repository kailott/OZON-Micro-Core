format ELF
section '.text' writeable executable
org 0x400000
include 'struct.inc'  ;/ ������������ ��������� � ����������� ���� virtual
include 'APIC_DEFS.inc' ;/����������� ��� ������ � APIC
include 'macro/proc32.inc' ;/ ����������� ����������� �������
public start
public Physical_Memory.Get_Free
public Physical_Memory.Def_Free
public Physical_Memory.Def_Used
public _pdt_based
public _iowin
public _apicwin
public PANIC
start:
cmp eax,0x2BADB002		;����������� ���������?
jne no_compatible_loader	;

jmp begin
align 4
DEFINE magic 0x1BADB002
DEFINE flags 0x1
dd magic
dd flags
dd -(magic+flags)
label begin
;�������� ���������� ���������� ��� ������
mov [MI_Base_Addr],ebx
;������������� GDT
lgdt [GDTR]
jmp far 0x8:next
next:
;������������� ���������� ���������
mov ax,0x10
mov ds,ax
mov es,ax
mov gs,ax
mov fs,ax
;������������� �����
mov eax,_STACK_LVL_0
mov esp,eax
;������ ������� �����
mov edi,0xB8000
mov eax,0x0F000F00
mov ecx,(160*40)/4
rep stosd
;������������� ��������� ���������� ������
mov esi,[MI_Base_Addr]
call Physical_Memory.init
;�������������� APIC
;��� ������ �������� ������� IDTR
lidt fword [IDTR]
;������ ��������� Local APIC
mov dword [APIC_LVT_Timer_REG_DEF],((1 shl 17) or 0x20)
mov dword [APIC_Timer_Divide_Configuration_REG_DEF],0
mov dword [APIC_Timer_Initial_Count_REG_DEF],0x00080
mov [LOCAL_APIC],APIC_EOI_REG_DEF
;//������������� IO APIC
mov eax,1
and ebx,0xFF000000
mov dword [IOAPIC_IOREGSEL_REG_DEF],IOAPIC_IOAPICID
mov dword [IOAPIC_IOWIN_REG_DEF] ,0x2000000
mov dword [IOAPIC_IOREGSEL_REG_DEF],IOAPIC_IOREDTBL1_hi
mov dword [IOAPIC_IOWIN_REG_DEF], ebx
mov dword [IOAPIC_IOREGSEL_REG_DEF], IOAPIC_IOREDTBL1_low
mov dword [IOAPIC_IOWIN_REG_DEF], 21h

sti ;
;������ ����� ���������������� �������� ����������� ������
;ccall [oxygen.init] ;//������������� ��������� ����������� ������
;mov edx,cr3
;call __outhex
;call __ln
;�������� ���������� ���������
;mov eax,0x400000 ;�������� ����� �������� ������� � ������� cr3
;mov cr3,eax
;mov eax,cr4
;or eax,0x90	 ;��������� ���������� � ����������� ��������
;mov cr4,eax
;� �������� ���������� ��������������
;mov eax,cr0
;or eax,0x80000000
;mov cr0,eax


;mov esi,PAGING_SET
;call __printf	 ;������





jmp $
;PAGING_SET db 'PG activity',0


;extrn init
;oxygen.init dd init








;���� ���� ���������� ������������� �����������
no_compatible_loader:
mov eax,0xA
call PANIC;
jmp $





;����������� ������
;�-�� kernel panic
PANIC:
;��������� ����������
cli
;�������� ��������� �����
push eax
;mov dx,0x3C0
;mov al,0x10 or 0100000b
;out dx,al
;inc dx
call __ln
call __printf	;������� ������� PANIC
mov esi,__FATALITY
call __printf	;������
pop edx
call __outhex	;� ��� ������
;mov al,0xA
;call __putchar
;mov al,0xD
;call __putchar
call __ln
mov esi,__FATALADDR
call __printf	;������
pop edx
call __outhex	;� ����� �������������
jmp $
__PANIC     db '>>>>>>KERNEL PANIC<<<<<<',0xA,0xD,0
__FATALITY  db '>>>>>>#FATAL ERROR AT 0x',0
__FATALADDR db '>>>>>>#OFFSET OF      0x',0







UTILS:
;edx = hex
__outhex:
push ebx
push ecx
push eax
mov cl,28
mov ebx,__ascii
@@:
mov eax,edx
shr eax,cl
and eax,0xF
xlatb
call __putchar
cmp cl,0
je __outhexend
sub cl,0x4
jmp @b
__outhexend:
pop eax
pop ecx
pop edx
ret
__ascii db  '0123456789ABCDEF',0
;AL = char
__putchar:
push edi
cmp al,0Ah
je .nextstr
cmp al,0Dh
je .retr
mov edi,[CurPos]
mov ah,[TextColor]
stosw
add [CurPos],2
jmp .end
.nextstr:
add [CurPos],080*2
jmp .end
.retr:
;��� - �� ����� ������� =)
mov eax,[CurPos]
sub eax,0xB8000
xor edx,edx
mov ebx,0xA0
div ebx
sub [CurPos],edx
;jmp .end
.end:
pop edi
ret

__ln:
mov al,0xA
call __putchar
mov al,0xD
call __putchar
ret
__printf:
;esi - str
@@:
lodsb
cmp al,0
je @f
call __putchar
jmp @b
@@:
ret
CurPos dd 0xB8000
TextColor db 0xA




include 'INTXX.asm'	;/��������� ����������
include 'RAM.asm'




section '.data' writeable
MI_Base_Addr dd ?
LOCAL_APIC   dd ?

section '.gdt' writeable
GDT:
NULL_descr	db		8 dup(0)
RING0_CODE     SEG_DESCR	0xFFFF,0,0,0x9A,0xCF,0	  ;8
RING0_DATA     SEG_DESCR	0xFFFF,0,0,0x92,0xCF,0	  ;16
MAIN_TSS       SEG_DESCR	0x80,0,0,0x89,0,0	  ;24
RING1_CODE     SEG_DESCR	0xFFFF,0,0,0xBA,0xCF,0	  ;32
RING1_DATA     SEG_DESCR	0xFFFF,0,0,0xB2,0xCF,0	  ;40
RING2_CODE     SEG_DESCR	0xFFFF,0,0,0xDA,0xCF,0
RING2_DATA     SEG_DESCR	0xFFFF,0,0,0xD2,0xCF,0
RING3_CODE     SEG_DESCR	0xFFFF,0,0,0xFA,0xCF,0
RING3_DATA     SEG_DESCR	0xFFFF,0,0,0xF2,0xCF,0
GDTR:
.size dw $-GDT-1
.base dd GDT
;END GDT SECTION
section '.idt' writeable
include 'IDT.asm'	;/������� ��������
;END IDT SECTION
section '.bss' writeable ;\������ �������������������� ������
rb 0x1000	    ;\ ���� �������� ������
label _STACK_LVL_0  ;\
_bbitm	rb 0x1000*0x20	    ;\���������� ��� ����� ������
label _pdt_based       ;\������ ��� ������� � ������� �������
rb 0x1000 * 3
label _iowin
label _apicwin

