# LAB 5 : Adding an XiP Flash Controller to TinySoC
In this lab, we will extend the TinySoC by incorporating an XiP flash controller that replaces the Program RAM. This modification allows the program to be changed without re-implementing the FPGA design; instead, the software can be updated by simply reprogramming the external flash memory. This approach is also beneficial for ASIC implementations, where external flash memories are used if the fabrication technology does not support embedded flash options.

Executing code directly from external flash memory can slow down the SoC's performance because the external flash is typically connected serially to the SoC using protocols like SPI. To mitigate this performance bottleneck, one method is to utilize multiple data lines to transfer data more quickly. Many flash memories support Quad I/O SPI (using four data lines), and some even support Octal I/O SPI (using eight data lines).

Despite the increased data lines with quad and octal SPI, fetching instructions from external flash remains relatively slow. To further enhance performance, we can implement a small read-only cache to exploit the program's locality, thereby reducing the frequency of slow flash memory accesses.

## The XiP Flash Controller
The controller utilizes the `EBh` (Quad I/O Fast Read) command, which allows the transfer of both address and data using four bits per clock cycle. This command also offers the option to omit sending the command byte for subsequent flash memory reads, thereby shortening the time required to read from the flash memory.

To handle soft system resets that do not involve power cycling, the controller first sends soft reset commands to the flash memory before attempting to read from it when the SoC exits reset. Specifically, it sends the `66h` (Reset Enable) command followed by the `99h` (Reset Memory) command. This sequence ensures that the flash memory is properly initialized and ready for operation after a soft reset.

***Notes***

1) The flash Q bit has to be set during the porogramming process.
2) The flash controller does is not runtime configurable.
3) The flash controller SCK (SPI Serial Clock) is set to be half the SoC clock.