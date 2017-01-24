;this is main file of Ozon OS Core
use64
org   0xFFFFFFFFC0000000
;include '../include/errorno.def'
;label MAIN_ENTRY
;include '../init/init.asm'
label kernel
.main:



jmp $
call panic
include '../mm/mm.asm'
include '../dev/generic/uart.inc'
include './panic.inc'
include './data.inc'
include './non-init_data.inc'
