# LAB 6 : Developing a Simple Accelerator for TinySoC

The Hazard2 CPU supports only the base RV32I instruction set, which means it does not support integer multiplication or division instructions. Therefore, when compiling programs for this CPU, we use the `-march=rv32i` switch with GCC to specify the instruction set architecture.

If your program uses integer multiplication, the compiler will emit a call to the library function `__mulsi3`. This function is provided by the GCC library (`libgcc`), and you need to link it by passing the `-lgcc` switch to GCC. The `__mulsi3` function performs multiplication using the classic add-and-shift algorithm, which consumes many CPU cycles and can slow down your application.

If your application performs a lot of integer multiplications, it is advisable to replace the Hazard2 CPU with another CPU that supports the **M extension** (e.g., implements **RV32IM**). The M extension adds hardware multiply and divide instructions, significantly improving performance for arithmetic-heavy applications.

Another solution is to develop a hardware multiplication unit that can be attached to the **AHB-Lite bus**. This unit would perform multiplication operations in hardware, effectively serving as a custom implementation of the `__mulsi3` function, and would accelerate multiplication operations without changing the CPU core.

In this lab, you will follow the second approach to create a hardware accelerator for integer multiplication to improve the performance.