; _______   _______  ___________ _____ _____ _____ _   _
;|  ___\ \ / /	__ \|  ___| ___ \_   _|_   _|  _  | \ | |
;| |__	\ V /| /  \/| |__ | |_/ / | |	| | | | | |  \| |
;|  __| /   \| |    |  __||  __/  | |	| | | | | | . ` |
;| |___/ /^\ \ \__/\| |___| |	  | |  _| |_\ \_/ / |\	|
;\____/\/   \/\____/\____/\_|	  \_/  \___/ \___/\_| \_/
EXCEPTION:
;//Ошибка деления
.INT_0:
mov eax,0
call PANIC
;//Исключение отладки
.INT_1:
mov eax,1
call PANIC
;//Немаскируемое прерывание
.INT_2:
mov eax,1
call PANIC
;//INT 3
.INT_3:
mov eax,3
call PANIC
;//Переполнение
.INT_4:
mov eax,4
call PANIC
;//Нарушение границ массива
.INT_5:
mov eax,5
call PANIC
;//Недопустимый код команды
.INT_6:
mov eax,6
call PANIC
;//Сопроцессор недоступен
.INT_7:
mov eax,7
call PANIC
;//Двойное нарушение
.INT_8:
IRETD
mov eax,8
call PANIC
;//Выход сопроцессора из сегмента
.INT_9:
mov eax,9
call PANIC
;//Недопустимый TSS
.INT_10:
mov eax,0xA
call PANIC
;//Отсутствие сегмента
.INT_11:
mov eax,0xB
call PANIC
;//Ошибка обращения к стеку
.INT_12:
mov eax,0xC
call PANIC
;//Общая защита
.INT_13:
mov eax,0xD
call PANIC
;//Страничное нарушение
.INT_14:
mov eax,0xE
call PANIC
;//Не пользуется
.INT_15:
;//Ошибка сопроцессора
.INT_16:
mov eax,0x10
call PANIC
;//Ошибка выравнивания
.INT_17:
mov eax,0x11
call PANIC
; ___________ _____  ____________ _____ _____  _____ _____ _____ _____ _   _ _____
;|_   _| ___ \	_  | | ___ \ ___ \  _  /  __ \|  ___/  ___/  ___|_   _| \ | |  __ \
;  | | | |_/ / | | | | |_/ / |_/ / | | | /  \/| |__ \ `--.\ `--.  | | |  \| | |  \/
;  | | |    /| | | | |	__/|	/| | | | |    |  __| `--. \`--. \ | | | . ` | | __
; _| |_| |\ \\ \/' / | |   | |\ \\ \_/ / \__/\| |___/\__/ /\__/ /_| |_| |\  | |_\ \
; \___/\_| \_|\_/\_\ \_|   \_| \_|\___/ \____/\____/\____/\____/ \___/\_| \_/\____/
IRQ:
macro EOI
{
mov dword [APIC_EOI_REG_DEF], 0 ;EOI
pop eax
}
;//Системный таймер
.IRQ_0:
push eax
inc byte [0xb8000+(79*2)]
EOI
IRETD

;//Клавиатура
.IRQ_1:
push eax
pushad
push [CurPos]
xor edx,edx
in  al,0x60
mov dl,al
and al,0x80
jnz @f
call __outhex
@@:
pop [CurPos]
popad
EOI
IRETD
;// Каскадирование
.IRQ_2:
push eax
EOI
IRETD
;//порты COM3, COM4
.IRQ_3:
push eax
EOI
IRETD
;//порты COM1, COM2
.IRQ_4:
push eax
EOI
IRETD
;//порт LPT2
.IRQ_5:
push eax
EOI
IRETD
;//контроллер FDC
.IRQ_6:
push eax
EOI
IRETD
;//порт LPT1
.IRQ_7:
push eax
EOI
IRETD
;//Часы реального времени
.IRQ_8:
push eax
EOI
IRETD
;//полумышь (ps/2)
.IRQ_12:
push eax
EOI
IRETD