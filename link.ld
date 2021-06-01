ENTRY(_start)

SECTIONS {
 	.text 0x400000 : {
		*(.prolog)
		*(.text)
		*(.code)
		*(.rdata)
		*(.rodata*)
		*(.data)
		*(.bss)
		*(.epilog)
	}
 __end = . ;
} 