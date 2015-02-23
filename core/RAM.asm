;Менеджер физической памяти Ozon MikroCore
;Автор - kailot2
virtual at esi
memory_map_unit:
.size dd ?
.start_addr dq ?
.end_addr   dq ?
.type	    dd ?
end virtual

Physical_Memory:
.bitmap_base_addr dd _bbitm				   ;База области памяти в которой будет размещена битовая карта
.bitmap_limit	  dd .bitmap_base_addr+0x1000*0x20	   ;Лимит этой области
.memory_size	  dd ?					   ;Размер оперативной памяти
.bitmap_size	  dd ?					   ;Размер битовой карты в байтах
.memory_map_base  dd ?					   ;Адрес карты памяти предоставленной Загрузчиком
.memory_map_size  dd ?					   ;И ее размер

.init:
;Инициализация карты памяти
;Сначала посчитаем общий размер оперативной памяти
;ESI - указывает на структуру Multiboot Information
mov eax,[MI.mem_lower]
add eax,[MI.mem_upper]
mov [.memory_size],eax
;И заполним остальные поля
mov eax,[MI.mmap_addr]
mov [.memory_map_base],eax
mov eax,[MI.mmap_length]
mov [.memory_map_size ], eax


mov ecx,[.memory_size]
call   .Create_bitmap
mov [.bitmap_size],eax
xor eax,eax
mov ecx,0x100000	;Размер системной области
call .def_not_aviable

mov eax,0x400000
mov ecx,0x800000	;Размер системной области
call .def_not_aviable


;Сделаем разбор карты памяти предоставленной нам
mov esi,[.memory_map_base]	 ;Адрес карты памяти
.parse:
cmp [memory_map_unit.type],01
je @f
jb .parse_end
mov eax,dword [memory_map_unit.start_addr]
mov ecx,dword [memory_map_unit.end_addr]
call .def_not_aviable
@@:
mov eax,[memory_map_unit.size]
add eax,4
add esi,eax
.parse_end:
ret


;Пометить группу страниц как недоступные
;EAX = Начало недоступного сегмента
;ECX = Конец
.def_not_aviable:
and eax,0xFFFFF000
add ecx,0x1000
@@:
push ecx
push eax
call   .Def_Used
pop eax
pop ecx
add eax,0x1000
cmp eax,ecx
jb @b
ret









;Инициализация карты памяти
;В ecx объем памяти в килобайтах
;в eax возвращает объем карты в байтах
.Create_bitmap:
;Высчитаем сколько байт нам понадобиться
;Bitmap_size = ((ecx / 4) / 8)+1 = размер карты памяти в байтах
shr ecx,2	;ecx / 4
shr ecx,3	;ecx / 8
inc ecx
mov ebp,ecx
mov edi,[.bitmap_base_addr]
xor ax,ax
rep stosb
mov eax,ebp
add ebp,[.bitmap_base_addr]
mov [.bitmap_limit],ebp
ret

;Получить адрес свободной страницы и пометить её как занятую
.Get_Free:
push esi
;Сканируем карту в поисках байта хоть с одним нулевым битом
mov esi,[.bitmap_base_addr]
@@:
lodsb
xor al,0xFF	;Есть свободные?
jnz @f		;Если получились не одни нули
cmp esi,[.bitmap_limit]     ;Достигли конца
jae ._nonfree
jmp @b
@@:
;Нашли, так как lodsb увеличивает esi то
dec esi
;Теперь пересчитаем в номер байта в килобайты
;1 байт кодирует 8*4 килобайта
mov eax,esi
sub eax,[.bitmap_base_addr]
;Теперь в ЕАХ номер байта в карте
;сначала умножаем на 4 потом на 8
shl eax,2	  ;На 4
shl eax,3	  ;на 8
mov ebx,eax	;сохраним
;xor ax,ax
;xor ecx,ecx
;Загрузим байт
lodsb
;Найдем номер бита
not ax	 ;Так как bfs ищет первый установленный в еденицу бит
bsf cx,ax
;В СL номер бита
;Пометим его как занятый
dec esi
;push cx     ;Команда bts рассматривает второй операнд как число со знаком (Пздц коряво)
and cx,0x800F
bts [esi],cx
;pop cx
;inc cl
;И умножить на 4
shl ecx,2
add ebx,ecx	;Адрес страницы, пока в килобайтах
;Нужно перевести в линейный адрес
;Для этого умножим на 0х400
shl ebx,10
mov eax,ebx
;pop esi
;pop edx
;pop ecx
;pop ebx
pop esi
ret
._nonfree:
pop esi
;mov eax,0xFFFFFFFF
xor eax,eax
ret

.Def_Free:
push esi
;Расчитаем адрес в памяти
;EAX = линейный адрес
;Что бы получить номер байта в Битовой карте нужно
shr eax,10	 ;Разделить на 0х400
;Получим адрес в килобайтах
;Поделим на 4
shr eax,2	;Получили смешение в блоках
;Последние 3 бита = номер бита в байте
;Сохраним его
mov ecx,0111b
and ecx,eax
;теперь поделим еах на 8
shr eax,3
;Получили смещение
mov esi,[.bitmap_base_addr]
;mov edx,esi
;add edx,PHBitMapSize
mov edx,[.bitmap_limit]
add esi,eax
cmp esi,edx
jae .ValOutRange
;так как btr принимает второе число как знаковое
and cx,0x800F
btr [esi],cx	;сбросим бит
;все
pop esi
ret


.Def_Used:
push esi
;Расчитаем адрес в памяти
;EAX = линейный адрес
;Что бы получить номер байта в Битовой карте нужно
shr eax,10	 ;Разделить на 0х400
;Получим адрес в килобайтах
;Поделим на 4
shr eax,2	;Получили смешение в блоках
;Последние 3 бита = номер бита в байте
;Сохраним его
mov ecx,0111b
and ecx,eax
;теперь поделим еах на 8
shr eax,3
;Получили смещение
mov esi,[.bitmap_base_addr]
;mov edx,esi
;add edx,PHBitMapSize
mov edx,[.bitmap_limit]
add esi,eax
cmp esi,edx
jae .ValOutRange
;так как btr принимает второе число как знаковое
and cx,0x800F
bts [esi],cx	;Установим бит
;все
pop esi
ret
.ValOutRange:
mov eax,0xFFFFFFFF
pop esi
ret







