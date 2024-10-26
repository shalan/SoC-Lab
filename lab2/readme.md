# LAB 2 : Tiny SoC
In this experiment, we are creating a simple AHB lite based SoC that contains:
- One Master: [Hazard2](https://github.com/Wren6991/Hazard2) CPU, a simple and small 2-stage piplined RV32I CPU
- Three Slaves: 
    - A 32-bit GPIO @ `0x40000000`
    - 8 kBytes Program RAM @ `0x00000000`
    - 8 kBytes Data RAM @ `0x20000000`
- A 4-port AHB lite bus splitter with a bus multiplexor and decoder. The fourth port is unused.

## A Simple General Purpose I/O (GPIO) Peripheral
GPIO stands for General-Purpose Input/Output. It is a generic pin on an SoC whose behavior—whether input or output—is controllable by the user at runtime. GPIOs are commonly used to interface with other hardware components, such as sensors, LEDs, buttons, and more.

The simplest GPIO has two registers
| Address Offset | Register Name | Access Type | Description                                      |
|----------------|---------------|-------------|--------------------------------------------------|
| `0x00`         | `DATA`   | Read/Write  | Data Register for GPIO pins                      |
| `0x04`         | `DIR`    | Read/Write  | Direction Register (1: Output, 0: Input)         |

## Developing Software for the TinySoC in C
### The Startup code
Check the file [crt.s](crt.s):
- **Register Initialization:** Clears all general-purpose registers to prevent unpredictable behavior during simulation.
- **Stack Setup:** Initializes the stack pointer to the top of the stack, necessary for function calls and local variables.
- **Data Section Initialization:** Copies the .data section from ROM to RAM so that initialized global and static variables have the correct values at runtime.
- **BSS Section Initialization:** Zeros out the .bss section in RAM, ensuring that uninitialized global and static variables start with zero.
- **Transfer to main:** Begins execution of the main program logic.
- **Fallback Loop:** Provides a safe state if main unexpectedly returns, preventing the program from running into undefined memory.
### The Linker Script
This linker script defines how the linker should map sections from the compiled object files into memory addresses for a RISC-V embedded system. It specifies the memory layout and provides necessary symbols for the startup code to initialize the system correctly.

#### Physical Memory Definitions
```
MEMORY
  {
    PRAM  (x)  : ORIGIN = 0, LENGTH = 8K
    DRAM  (wx) : ORIGIN = 0x20000000, LENGTH = 8K
  }
```
Defines the memory regions available for code and data placement.

- PRAM:
    - *Name:* PRAM (Program RAM)
    - *Attributes:* (x) - Executable
    - *ORIGIN:* `0x00000000` - Start address
    - *LENGTH:* 8K (8192 bytes)
    - *Usage:* Stores the .text section (code) and read-only data.

- DRAM:
    - *Name:* DRAM (Data RAM)
    - *Attributes: (wx) - Writable and executable
    - *ORIGIN:* `0x20000000`
    - *LENGTH:* 8K (8192 bytes)
    - *Usage:* Stores the .data and .bss sections (initialized and uninitialized data) and the stack.

```
.text :
{
    . = ALIGN(4);
    *(.text .text*)           /* .text sections (code) */
    *(.rodata .rodata*)       /* .rodata sections (constants, strings, etc.) */
    *(.srodata .srodata*)     /* Small read-only data sections */
    . = ALIGN(4);
    _sidata = .;
} >PRAM
```

```
.data : AT(_sidata)
{
    . = ALIGN(4);
    _sdata = .;             /* Start address of .data in RAM */
    . = ALIGN(4);
    *(.data .data*)         /* .data sections (initialized data) */
    *(.sdata .sdata*)       /* Small data sections */
    __global_pointer$ = . + 0x800;
    . = ALIGN(4);
    _edata = .;             /* End address of .data in RAM */
} > DRAM
```

```
.bss :
{
    . = ALIGN(4);
    _sbss = .;              /* Start address of .bss in RAM */
    *(.bss .bss.*)
    *(.sbss .sbss.*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;              /* End address of .bss in RAM */
} >DRAM

```
### Compiling
### Loading the binary image into the SoC Program RAM (PRAM)
