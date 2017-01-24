;Ozon Memory Manager




;RCX = size
;Return RSI - pointer to memory
_static_memory_allocate:
mov RSI,[_static_memory_pointer]
add [_static_memory_pointer],RCX
ret
;Allocate my memory aligned 4k
;RCX = size
;Return RSI - pointer to memory
_static_memory_allocate_4k:
mov RSI,[_static_memory_pointer]
and rsi,0xFFF
jz @f
mov RSI,[_static_memory_pointer]
add rsi,0x1000
and rsi,0xFFFFFFFFFFFFF000
mov rax,rsi
add rax,rcx
mov [_static_memory_pointer],rax
ret
@@:
mov RSI,[_static_memory_pointer]
add [_static_memory_pointer],RCX
ret



