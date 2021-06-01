
//typedef unsigned int size_t;

//typedef enum{false, true} bool;
#define cur_ver 0x000001

#include "dmm.h"
#include "printf.h"
#include "dead.h"
#include "page_alloc.h"
extern unsigned int EOF;


typedef struct {
        unsigned long long base; //Базовый физический адрес региона
        unsigned long long length; //Размер региона в байтах
        unsigned long type; // Тип региона
        unsigned long acpi_attrs; //Расширенные атрибуты ACPI
} smap; 


int kernel_main(smap *tsmap)
{
	

		
    //Инициализация менеджера кучи
    if(!dmalloc_init(0x600000)) 	dead(0xDEADFACE);

	printf("%x\n", EOF);
    printf("Version %x\n", cur_ver);
    
   	//display(79,2).code = 'D';
    // print_hex((unsigned int) dmalloc(4096 ));
    // print_char('\n');
    
	while (1)
	{
	};
}
