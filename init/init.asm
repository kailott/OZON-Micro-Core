;OZON OS kernel initialization
init:
call @f
@@:
pop rax
sub rax,(@b-init) ;Calculation of the true load address
mov rbp,rax
and rax,0xFFFF	  ;Is the address not 4k aligned?
jz @f
mov rbx,rbp
add rbx,panic - MAIN_ENTRY
mov rax,BAD_IMAGE_ADDRESS
call rbx
@@:






