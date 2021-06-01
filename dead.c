#include "printf.h"

void dead(unsigned int deadcode)
{
	set_std_color(0x4);
	printf("Critical fault of %x\n",0xDEADDEAD);
	printf("Section %x\n", deadcode);
	printf("processor halt!");
	while(1)
	{
		__asm__("hlt;");
	}
}
