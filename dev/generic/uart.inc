uart:
.send_byte:
push dx
mov dx,0x3F8
out dx,al
mov dx,0x3FD
@@:
in al,dx
bt ax,5
jnc @b
pop dx
ret

.print:
;si/esi - string
cld
@@:
lodsb
test al,al
jz @f
call .send_byte
jmp @b
@@:
ret