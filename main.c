
//typedef unsigned int size_t;

//typedef enum{false, true} bool;
#define cur_ver 0x000001

#include "dmm.h"
#include "printf.h"
#include "dead.h"
#include "page_alloc.h"
extern unsigned int EOF;


typedef struct {
        unsigned long long base; //������� ���������� ����� �������
        unsigned long long length; //������ ������� � ������
        unsigned long type; // ��� �������
        unsigned long acpi_attrs; //����������� �������� ACPI
} smap; 


int kernel_main(smap *tsmap)
{
	

		
    //������������� ��������� ����
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
