;Ozon Micro Core
;Author Kailot2
;GPL V2.0 2015
format ELF
section '.text' writeable executable
org 0x800000
include 'struct.inc'  ;/ Используемые структуры и определения типа virtual
include 'APIC_DEFS.inc' ;/Определения для работы с APIC
include 'macro/proc32.inc' ;/ Определения стандартных вызовов
public start
public Physical_Memory.Get_Free
public Physical_Memory.Def_Free
public Physical_Memory.Def_Used
public _pdt_based
public _iowin
public _apicwin
public PANIC
start:
cmp eax,0x2BADB002		;Совместимый загрузчик?
jne no_compatible_loader	;

jmp begin
align 4
DEFINE magic 0x1BADB002
DEFINE flags 0x1
dd magic
dd flags
dd -(magic+flags)
label begin
;Сохраним Информацию переданную нам грабом
mov [MI_Base_Addr],ebx
;Инициализация GDT
lgdt [GDTR]
jmp far 0x8:next
next:
;Инициализация сегментных регистров
mov ax,0x10
mov ds,ax
mov es,ax
mov gs,ax
mov fs,ax
;Инициализация стека
mov eax,_STACK_LVL_0
mov esp,eax
;Просто очистим экран
mov edi,0xB8000
mov eax,0x0F000F00
mov ecx,(160*40)/4
rep stosd
;Инициализация менеджера физической памяти
mov esi,[MI_Base_Addr]
call Physical_Memory.init
;Инициализируем APIC
;Для начала загрузим регистр IDTR
lidt fword [IDTR]
;Теперь настройка Local APIC
mov dword [APIC_LVT_Timer_REG_DEF],((1 shl 17) or 0x20)
mov dword [APIC_Timer_Divide_Configuration_REG_DEF],0
mov dword [APIC_Timer_Initial_Count_REG_DEF],0x00080
mov [LOCAL_APIC],APIC_EOI_REG_DEF
;//Инициализация IO APIC
mov eax,1
and ebx,0xFF000000
mov dword [IOAPIC_IOREGSEL_REG_DEF],IOAPIC_IOAPICID
mov dword [IOAPIC_IOWIN_REG_DEF] ,0x2000000
mov dword [IOAPIC_IOREGSEL_REG_DEF],IOAPIC_IOREDTBL1_hi
mov dword [IOAPIC_IOWIN_REG_DEF], ebx
mov dword [IOAPIC_IOREGSEL_REG_DEF], IOAPIC_IOREDTBL1_low
mov dword [IOAPIC_IOWIN_REG_DEF], 21h

;sti ;

;Теперь нужно инициализировать менеджер виртуальной памяти
;ccall [ext.init] ;//Инициализация менеджера виртуальной памяти
;mov edx,cr3
;call __outhex
;call __ln
;включаем страничную адресацию
;mov eax,0x400000 ;Загрузим адрес Каталога страниц в регистр cr3
;mov cr3,eax
;mov eax,cr4
;or eax,0x90	 ;Разрешаем глобальные и расширенные страницы
;mov cr4,eax
;И включаем страничное преобразование
;mov eax,cr0
;or eax,0x80000000
;mov cr0,eax


;Теперь сделаем alloc фреймбуфера
;Куда нибудь в район 4 мегабайта
;Go
;Каталог страниц размещается по адресу 0x0 (теперь)
;Высчитаем индекс в каталоге
call Atom.init
ccall Reloc,0xB8000,0x400000
;mov eax,0x400000
;shr eax,20
;and eax,0xFFC
;Индекс в каталоге и является адресом табличной записи
;Нужно выделить память под каталог страниц =)
;push eax
;call Physical_Memory.Get_Free
;И записать его в каталог
;pop esi
;push eax
;or eax,0x10B	 ;Атрибут
;mov [esi],eax
;;Теперь по индексу высчитаем адрес содержимого страницы
;Для этого индекс нужно умножить на 1024
;shl esi, 0xA	   ; =)
;;И первым эллементов впишем туда фреймбуфер
;mov [esi],dword 0xB8000 or 0x10B
;Теперь поменяем CurPos на 0x400000
;И попробуем что нибудь вывести
mov [CurPos],0x400000
mov esi,PAGING_SET
call __printf

jmp $

PAGING_SET db 'PG activity',0


;Если ядро загруженно несовместимым загрузчиком
no_compatible_loader:
mov eax,0xA
call PANIC;
jmp $





;Критическая ошибка
;А-ля kernel panic
PANIC:
;Запрещаем прерывания
cli
;Включаем текстовый режим
push eax
;mov dx,0x3C0
mov eax,cr0
xor eax,0x80000000
mov cr0,eax
mov [CurPos],0xB8000
;mov al,0x10 or 0100000b
;out dx,al
;inc dx
call __ln
call __printf	;выводим строчку PANIC
mov esi,__FATALITY
call __printf	;Строку
pop edx
call __outhex	;И код ошибки
;mov al,0xA
;call __putchar
;mov al,0xD
;call __putchar
call __ln
mov esi,__FATALADDR
call __printf	;Строку
pop edx
call __outhex	;И адрес возникновения
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
;Что - то очень сложное =)
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




include 'INTXX.asm'	;/Обработка прерывания
include 'RAM.asm'
include 'Atom.asm'




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
include 'IDT.asm'	;/Таблица векторов
;END IDT SECTION
section '.bss' writeable ;\Секция неинициализированных данных
rb 0x1000	    ;\ Стек нулевого кольца
label _STACK_LVL_0  ;\
_bbitm	rb 0x1000*0x20	    ;\Резервация под карту памяти
label _pdt_based       ;\Резерв под Каталог и таблицу страниц
rb 0x1000 * 3
label _iowin
label _apicwin

