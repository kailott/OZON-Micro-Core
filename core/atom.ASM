;ATOM memory manager
;Create for Ozon Micro Core
;Author Kailot2
;GPL V2.0 2015
;Инициализация менеджера памяти
Atom:
.init:
;Выделим память под катлог страниц
call Physical_Memory.Get_Free
mov esi,eax
or eax,0x10B   ;Атрибуты
mov [esi],eax  ;Теперь с адреса 0x0 у нас будут таблицы страниц
push esi    ;Сохраним адрес каталога страниц для дальнейшего использования
mov eax,start	      ;Выясним по какому адресу будет транислироваться ядро
;Нужно выяснить номер элемента каталога , и создать таблицу страниц
;И потом заполнить эту таблицу линейными адресами
shr eax,20
and eax,0xFFC
add esi, eax	;//Получили смещение относительно корневого каталога
push esi
call Physical_Memory.Get_Free
pop esi
push eax
or eax,0x10B ;Атрибуты
mov [esi],eax
pop eax
mov esi,eax
mov eax,start
or eax,0x10B
mov ecx,0x400
@@:
mov [esi],eax
add eax,0x1000
add esi,4
loop @b
;Теперь можно включать страничную трансляцию =)
pop esi
mov eax,esi
mov cr3,eax
mov eax,cr4
or eax,0x80	;Разрешаем глобальные страницы
mov cr4,eax
;И включаем страничное преобразование
mov eax,cr0
or eax,0x80000000
mov cr0,eax
;Теперь сделаем аллокацию участка памяти
;Предназначенного для работы с Apic
ret

;Процедура монтирует страницу с физическим адресом phaddr
;к виртуальному адресу logaddr
;В случае успеха возвращает ноль
proc Reloc c uses esi edi ebp ebx ecx edx, phaddr:dword ,logaddr:dword
;Для начала нужно проверить , существует ли таблица страниц для заданной области
mov esi,[logaddr]
shr esi,0x14
and esi,0xFFC
mov eax,[esi]
;push eax
and eax,1
jnz @f
;Если таблица страниц не существует
;mov eax,[phaddr]
;shr eax,20
;and eax,0xFFC
;Индекс в каталоге и является адресом табличной записи
;Нужно выделить память под каталог страниц =)
push esi
call Physical_Memory.Get_Free
;И записать его в каталог
pop esi
;push eax
or eax,0x10B	;Атрибут
mov [esi],eax
@@:
;Теперь по индексу высчитаем адрес содержимого страницы
;Для этого индекс нужно умножить на 1024
shl esi, 0xA	  ; =)
;и теперь вычислим индекс в таблице
mov eax,[logaddr]
shr eax,0xA
and eax,0xFFC
;shl eax,2     ;EAX * 4
add esi,eax
mov eax,[phaddr]
or eax,0x10B	;Атрибут страницы
mov [esi],eax
xor eax,eax
ret
endp

;Монтирует свободный блок памяти к виртуальному адресу logaddr
proc Alloc c uses esi edi ebp ebx ecx edx, logaddr:dword
call Physical_Memory.Get_Free
ccall Reloc ,eax,logaddr
ret
endp

;Освобождает связанный с логическим адресом logaddr
;физический блок памяти
;В случае успешного завершения возвращает ноль
proc Free c uses esi edi ebp ebx ecx edx, logaddr:dword
;Для начала нужно проверить , существует ли таблица страниц для заданной области
mov esi,[logaddr]
shr esi,0x14
and esi,0xFFC
mov eax,[esi]
;push eax
and eax,1
jnz @f
;Если таблица страниц не существует
;Возвращаем не ноль
mov eax,0xFFFFFF
ret
@@:
;Теперь по индексу высчитаем адрес содержимого страницы
;Для этого индекс нужно умножить на 1024
shl esi, 0xA	  ; =)
;и теперь вычислим индекс в таблице
mov eax,[logaddr]
shr eax,0xA
and eax,0xFFC
;shl eax,2     ;EAX * 4
add esi,eax
mov eax,[esi]
push esi
call  Physical_Memory.Def_Free
pop esi
mov [esi],dword 0
xor eax,eax
ret
endp




