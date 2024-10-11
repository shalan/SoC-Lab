# LAB 2 : Tiny SoC
In this experiment, we are creating a simple AHB lite based SoC that contains:
- One Master: Hazard 2 CPU, a simple and small 2-stage piplined RV32I CPU
- Three Slaves: 
    - A 32-bit GPIO @ `0x40000000`
    - 8 kBytes Program RAM @ `0x00000000`
    - 8 kBytes Data RAM @ `0x20000000`
- A 4-port AHB lite bus splitter with a bus multiplexor and decoder. The fourth port is unused.

## A Simple General Purpose I/O (GPIO) Peripheral

## Developing Software for TinySoC in C
### The Startup code
### The Linker Script
### Compiling
### Loading the binary image into the SoC Prohgram RAM
