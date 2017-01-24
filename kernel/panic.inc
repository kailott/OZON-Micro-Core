;Critical error code Ozon OS Core
panic:
;cmp eax,BAD_IMAGE_ADDRESS
jne @f
mov rsi,rbp
mov rax,rbp
;add rax,uart.print - MAIN_ENTRY
;mov rsi,S_BAD_IMAGE_ADDRESS - MAIN_ENTRY
call rax
jmp $
@@:

.halt:
mov rsi,main_panic_str
call uart.print
jmp $

main_panic_str db 'A kernel critical error has occurred. Execution halted.',0xA,0xD,0
S_BAD_IMAGE_ADDRESS db 'BAD IMAGE ADDRESS',0xA,0xD,0