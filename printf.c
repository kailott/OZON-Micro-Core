
//#include <system.h>
#include "printf.h"
//#include <vga.h>
#define display(c, r) (display[(r)*80 + (c)])
#include <stdarg.h>
symbol *display = (void*)0xb8000;




int curr_x = 0, curr_y = 0;
char std_color = 0xA;
//uint8_t curr_color = DEFAULT_COLOR;



void set_std_color(char color)
{
	std_color = color;
}

void print_string(char* str) {
	int i = 0;
	while(str[i])
		{
		print_char(str[i]);
		i++;
		}
} 

const char digits[] = "0123456789ABCDEF";
static char num_buffer[65];

char *int_to_str(size_t value, unsigned char base) {
	size_t i = sizeof(num_buffer) - 1;
	num_buffer[i--] = '\0';
	do {
		num_buffer[i--] = digits[value % base];
		value = value / base;
	} while (value);
	return &num_buffer[i + 1];
}





void printf(char *fmt, ...) {
	char tmp;
	va_list args;
	va_start(args, fmt);
	while (*fmt) {
		if (*fmt == '%') {
			fmt++;
			size_t arg = va_arg(args, size_t);
			switch (*fmt) {
				case '%':
					print_char('%');
					break;
				case 'c':
					print_char(arg);
					break;
				case 's':
					print_string((char*)arg);
					break;
				case 'b':
					print_string(int_to_str(arg, 2));
					break;
				case 'o':
					print_string(int_to_str(arg, 8));
					break;
				case 'd':
					print_string(int_to_str(arg, 10));
					break;
				case 'x':
					tmp = std_color;
					std_color = 0xC; //RED CGA COLOR
					print_char('0');
					print_char('x');
					print_string(int_to_str(arg, 16));
					std_color = tmp;
					break;
			}
		} else {
			print_char(*fmt);
		}
		fmt++;
	}
	va_end(args);
} 



void print_char(char c) {
   // scroll();
    if(c == '\n') {
        curr_x = 0;
        curr_y++;
    }
    else if(c == '\t') {
        int i;
        for(i = 0; i < 4; i++)
            print_char(' ');
    }
    else if(c >= ' ') {
        display(curr_x, curr_y).code = c;
        display(curr_x, curr_y).color = std_color;

        curr_x++;
        if(curr_x == 80) {
            curr_x = 0;
            curr_y++;
        }
    }
   // update_cursor();
}


void print_hex(unsigned int hex)
{
	char chars[] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
	print_char('0');
	print_char('x');
	for (int i = 28 ; i>=0 ; i= i-4) print_char(chars[(hex>>i) & 0xF ] );
	
}




int is_format_letter(char c) {
    return c == 'c' ||  c == 'd' || c == 'i' ||c == 'e' ||c == 'E' ||c == 'f' ||c == 'g' ||c == 'G' ||c == 'o' ||c == 's' || c == 'u' || c == 'x' || c == 'X' || c == 'p' || c == 'n';
}

/*
 * Both printf and sprintf call this function to do the actual formatting
 * The only difference of printf and sprintf is, one writes to screen memory, and another writes to normal memory buffer
 * vsprintf should keeps track of current mem pointer to place next character(for printf, print_char alread keeps track of current screen posistion, so this is only true for sprintf)
 * *//*
void vsprintf(char * str, void (*putchar)(char), const char * format, va_list arg) {
    unsigned int pos = 0;
    char buf[512];
    char width_str[10];
    unsigned int uval;
    unsigned int size = 8;
    unsigned int i;
    int size_override = 0;
    memset(buf, 0, 512);

    while((c = *format++) != 0) {
        sign = 0;

        if(c == '%') {
            c = *format++;
            switch(c) {
                // Handle calls like printf("%08x", 0xaa);
                case '0':
                    size_override = 1;
                    // Get the number between 0 and (x/d/p...)
                    i = 0;
                    c = *format;
                    while(!is_format_letter(c)) {
                        width_str[i++] = c;
                        format++;
                        c = *format;
                    }
                    width_str[i] = 0;
                    format++;
                    // Convert to a number
                    size = atoi(width_str);
                case 'd':
                case 'u':
                case 'x':
                case 'p':
                    if(c == 'd' || c == 'u')
                        sys = 10;
                    else
                        sys = 16;

                    uval = ival = va_arg(arg, int);
                    if(c == 'd' && ival < 0) {
                        sign= 1;
                        uval = -ival;
                    }
                    itoa(buf, uval, sys);
                    unsigned int len = strlen(buf);
                    // If use did not specify width, then just use len = width
                    if(!size_override) size = len;
                    if((c == 'x' || c == 'p' || c == 'd') &&len < size) {
                        for(i = 0; i < len; i++) {
                            buf[size - 1 - i] = buf[len - 1 - i];
                        }
                        for(i = 0; i < size - len; i++) {
                            buf[i] = '0';
                        }
                    }
                    if(c == 'd' && sign) {
                        if(str) {
                            *(str + *pos) = '-';
                            *pos = *pos + 1;
                        }
                        else
                            (*putchar)('-');
                    }
                    if(str) {
                        strcpy(str + *pos, buf);
                        *pos = *pos + strlen(buf);
                    }
                    else {
                        char * t = buf;
                        while(*t) {
                            putchar(*t);
                            t++;
                        }
                    }
                    break;
                case 'c':
                    if(str) {
                        *(str + *pos) = (char)va_arg(arg, int);
                        *pos = *pos + 1;
                    }
                    else {
                        (*putchar)((char)va_arg(arg, int));
                    }
                    break;
                case 's':
                    if(str) {
                        char * t = (char *) va_arg(arg, int);
                        strcpy(str + (*pos), t);
                        *pos = *pos + strlen(t);
                    }
                    else {
                        char * t = (char *) va_arg(arg, int);
                        while(*t) {
                            putchar(*t);
                            t++;
                        }
                    }
                    break;
                default:
                    break;
            }
            continue;
        }
        if(str) {
            *(str + *pos) = c;
            *pos = *pos + 1;
        }
        else {
            (*putchar)(c);
        }

    }
}*/

/*
 * Simplified version of printf and sprintf
 *
 * printf is sprintf is very similar, except that sprintf doesn't print to screen
 * */

/*void printf(const char * s, ...) {
    va_list ap;
    va_start(ap, s);
    vsprintf(NULL, print_char, s, ap);
    va_end(ap);
}
*/
/*
This has been moved to string.c
void sprintf(char * buf, const char * fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    vsprintf(buf, NULL, fmt, ap);
    va_end(ap);
}
*/
