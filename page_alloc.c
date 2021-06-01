//Менеджер физической памяти
//Отдает память страницами по 4Кб 
/*
       pool	
   |  0x1000
   |  0x2000	| used space
   |  0x3000   <---PTR
   |  0x4000   / free space
   |  0x5000
*/ 
#include "dmm.h"
#define memory_size 0x1000 * 0x2000 //32 Mb 

void page_alloc_init(void)
{
	unsigned int *pool;
	unsigned int pool_size;
	pool_size = (memory_size / 4096) * 4 
	pool = dmalloc(pool_size);
	
	
}
