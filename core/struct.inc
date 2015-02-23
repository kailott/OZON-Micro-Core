;align 8
STRUC IDT_Unit	offs,sel,type
{
.offs_l   dw  offs and 0xFFFF	   ;0
.sel	  dw  sel	   ;2
.cntr	  db  0 	;4
.dtype	  db  type	  ;5
.offs_h   dw ((offs shr 16) and 0xFFFF)      ;6
}

STRUC SEG_DESCR lim,base_l,base_m,attr_1,attr_2,base_h
{
.lim	  dw  lim	  ;0
.base_l   dw  base_l	  ;2
.base_m   db  base_m	  ;4
.attr_1   db  attr_1	  ;5
.attr_2   db  attr_2	  ;6
.base_h   db  base_h	  ;7
}

STRUC CALL_GATE offs,sel,type,count
{
.offs_l   dw  offs and 0xFFFF	   ;0
.sel	  dw  sel	  ;2
.cntr	  db  count	  ;4
.dtype	  db  type	  ;5
.offs_h   dw ((offs shr 16) and 0xFFFF)      ;6
}

virtual at esi
MI:
.flags dd ?
.mem_lower dd ?
.mem_upper dd ?
.boot_device dd ?
.cmdline dd ?
.mods_count dd ?
.mods_addr dd ?
.syms rb (40-28)+4
.mmap_length dd ?
.mmap_addr dd ?
.drives_length dd ?
.drives_addr dd ?
.congig_table dd ?
.boot_loader_name dd ?
.apm_table dd ?
.vbe_control_info dd ?
.vbe_mode_info dd ?
.vbe_mode dd ?
.vbe_interface_seg dw ?
.vbe_interface_off dw ?
.vbe_interface_len dw ?
end virtual
;Элемент таблицы загруженных модулей
virtual at esi
MODS:
.start dd ?    ;4
.end dd ?      ;8
.string dd ?   ;12
.reserved dd ? ;16
end virtual