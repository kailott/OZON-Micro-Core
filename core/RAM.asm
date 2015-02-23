;�������� ���������� ������ Ozon MikroCore
;����� - kailot2
virtual at esi
memory_map_unit:
.size dd ?
.start_addr dq ?
.end_addr   dq ?
.type	    dd ?
end virtual

Physical_Memory:
.bitmap_base_addr dd _bbitm				   ;���� ������� ������ � ������� ����� ��������� ������� �����
.bitmap_limit	  dd .bitmap_base_addr+0x1000*0x20	   ;����� ���� �������
.memory_size	  dd ?					   ;������ ����������� ������
.bitmap_size	  dd ?					   ;������ ������� ����� � ������
.memory_map_base  dd ?					   ;����� ����� ������ ��������������� �����������
.memory_map_size  dd ?					   ;� �� ������

.init:
;������������� ����� ������
;������� ��������� ����� ������ ����������� ������
;ESI - ��������� �� ��������� Multiboot Information
mov eax,[MI.mem_lower]
add eax,[MI.mem_upper]
mov [.memory_size],eax
;� �������� ��������� ����
mov eax,[MI.mmap_addr]
mov [.memory_map_base],eax
mov eax,[MI.mmap_length]
mov [.memory_map_size ], eax


mov ecx,[.memory_size]
call   .Create_bitmap
mov [.bitmap_size],eax
xor eax,eax
mov ecx,0x100000	;������ ��������� �������
call .def_not_aviable

mov eax,0x400000
mov ecx,0x800000	;������ ��������� �������
call .def_not_aviable


;������� ������ ����� ������ ��������������� ���
mov esi,[.memory_map_base]	 ;����� ����� ������
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


;�������� ������ ������� ��� �����������
;EAX = ������ ������������ ��������
;ECX = �����
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









;������������� ����� ������
;� ecx ����� ������ � ����������
;� eax ���������� ����� ����� � ������
.Create_bitmap:
;��������� ������� ���� ��� ������������
;Bitmap_size = ((ecx / 4) / 8)+1 = ������ ����� ������ � ������
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

;�������� ����� ��������� �������� � �������� � ��� �������
.Get_Free:
push esi
;��������� ����� � ������� ����� ���� � ����� ������� �����
mov esi,[.bitmap_base_addr]
@@:
lodsb
xor al,0xFF	;���� ���������?
jnz @f		;���� ���������� �� ���� ����
cmp esi,[.bitmap_limit]     ;�������� �����
jae ._nonfree
jmp @b
@@:
;�����, ��� ��� lodsb ����������� esi ��
dec esi
;������ ����������� � ����� ����� � ���������
;1 ���� �������� 8*4 ���������
mov eax,esi
sub eax,[.bitmap_base_addr]
;������ � ��� ����� ����� � �����
;������� �������� �� 4 ����� �� 8
shl eax,2	  ;�� 4
shl eax,3	  ;�� 8
mov ebx,eax	;��������
;xor ax,ax
;xor ecx,ecx
;�������� ����
lodsb
;������ ����� ����
not ax	 ;��� ��� bfs ���� ������ ������������� � ������� ���
bsf cx,ax
;� �L ����� ����
;������� ��� ��� �������
dec esi
;push cx     ;������� bts ������������� ������ ������� ��� ����� �� ������ (���� ������)
and cx,0x800F
bts [esi],cx
;pop cx
;inc cl
;� �������� �� 4
shl ecx,2
add ebx,ecx	;����� ��������, ���� � ����������
;����� ��������� � �������� �����
;��� ����� ������� �� 0�400
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
;��������� ����� � ������
;EAX = �������� �����
;��� �� �������� ����� ����� � ������� ����� �����
shr eax,10	 ;��������� �� 0�400
;������� ����� � ����������
;������� �� 4
shr eax,2	;�������� �������� � ������
;��������� 3 ���� = ����� ���� � �����
;�������� ���
mov ecx,0111b
and ecx,eax
;������ ������� ��� �� 8
shr eax,3
;�������� ��������
mov esi,[.bitmap_base_addr]
;mov edx,esi
;add edx,PHBitMapSize
mov edx,[.bitmap_limit]
add esi,eax
cmp esi,edx
jae .ValOutRange
;��� ��� btr ��������� ������ ����� ��� ��������
and cx,0x800F
btr [esi],cx	;������� ���
;���
pop esi
ret


.Def_Used:
push esi
;��������� ����� � ������
;EAX = �������� �����
;��� �� �������� ����� ����� � ������� ����� �����
shr eax,10	 ;��������� �� 0�400
;������� ����� � ����������
;������� �� 4
shr eax,2	;�������� �������� � ������
;��������� 3 ���� = ����� ���� � �����
;�������� ���
mov ecx,0111b
and ecx,eax
;������ ������� ��� �� 8
shr eax,3
;�������� ��������
mov esi,[.bitmap_base_addr]
;mov edx,esi
;add edx,PHBitMapSize
mov edx,[.bitmap_limit]
add esi,eax
cmp esi,edx
jae .ValOutRange
;��� ��� btr ��������� ������ ����� ��� ��������
and cx,0x800F
bts [esi],cx	;��������� ���
;���
pop esi
ret
.ValOutRange:
mov eax,0xFFFFFFFF
pop esi
ret







