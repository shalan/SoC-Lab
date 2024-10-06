volatile unsigned int* gpio_data = (volatile unsigned int *) 0x40000000;
volatile unsigned int* gpio_oe = (volatile unsigned int *) 0x40000004;
volatile unsigned int* ram_word = (volatile unsigned int *) 0x20000400;

int main(){
    unsigned short *sp = ram_word;
    unsigned char *cp = ram_word;

    // configure the GPIO as an output
    *gpio_oe = 0xFFFFFFFF;

    *ram_word = 0xAABBCCDD;
    *cp++ = 0xFF;
    *cp++ = 0x11;
    *cp++ = 0x22;
    *cp++ = 0x33;
    if(*ram_word != 0x332211FF)
        *gpio_data = 0x0;
    else
        *gpio_data = 0xF00FE00E;
    
    return 0;
}