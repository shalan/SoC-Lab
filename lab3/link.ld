MEMORY
  {
    PRAM  (x)  : ORIGIN = 0, LENGTH = 8K
    DRAM  (wx) : ORIGIN = 0x20000000, LENGTH = 8K
  }

SECTIONS
{
    .text :
    {
        . = ALIGN(4);
        *(.text .text*)           /* .text sections (code) */
        *(.rodata .rodata*)         /* .rodata sections (constants, strings, etc.) */
        *(.srodata .srodata*)         /* .rodata sections (constants, strings, etc.) */
        . = ALIGN(4);
        _sidata = .;
    } >PRAM

    /*  
        This is the initialized data section
        The program executes knowing that the data is in the RAM
        but the loader puts the initial values in the FLASH (inidata).
        It is one task of the startup to copy the initial values from FLASH to RAM. 
    */
    .data : AT(_sidata)
    {
        . = ALIGN(4);
        _sdata = .;        /* create a global symbol at data start; used by startup code in order to initialise the .data section in RAM */
        . = ALIGN(4);
        *(.data .data*)           /* .data sections */
        *(.sdata .sdata*)           /* .data sections */
        __global_pointer$ = . + 0x800;
        . = ALIGN(4);
        _edata = .;        /* define a global symbol at data end; used by startup code in order to initialise the .data section in RAM */
    } > DRAM

    /* Uninitialized data section */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;         /* define a global symbol at bss start; used by startup code */
        *(.bss .bss.*)
        *(.sbss .sbss.*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;         /* define a global symbol at bss end; used by startup code */
    } >DRAM

    _stack = ORIGIN(DRAM) + LENGTH(DRAM) ;

}