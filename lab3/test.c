volatile unsigned int* gpio_data = (volatile unsigned int *) 0x40000000;
volatile unsigned int* gpio_oe = (volatile unsigned int *) 0x40000004;

volatile unsigned int* uart_ctrl = (volatile unsigned int *) 0x50000000;
volatile unsigned int* uart_bauddiv = (volatile unsigned int *) 0x50000004;
volatile unsigned int* uart_status = (volatile unsigned int *) 0x50000008;
volatile unsigned int* uart_data = (volatile unsigned int *) 0x5000000C;


void uart_init(int bauddiv){
    *uart_bauddiv = bauddiv;
    *uart_ctrl = 1;
}

void uart_putc(char c){
    while(*uart_status == 0);
    *uart_data = c;
    *uart_ctrl |= 2;
}

void uart_puts(char *s){
    for(int i=0; s[i]; i++)
        uart_putc(s[i]);
}

void exit(){
    *gpio_data = 0xF00FE00E;
}

int main(){
    *gpio_oe = 0xFFFFFFFF;  // configure the GPIO as an output

    uart_init(10);
    uart_puts("Hello World!\n");

    exit();
    return 0;
}