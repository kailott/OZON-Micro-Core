;this is main file of Ozon OS Core
use64
org   0xffff880000000000
include '../include/errorno.def'

label MAIN_ENTRY
include '../init/init.asm'
label kernel
.main:




call panic

include '../dev/generic/uart.inc'
include './panic.inc'
