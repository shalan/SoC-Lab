# LAB 3 : TinySoC with a UART Transmitter
In this lab, we extend the Tiny SoC by adding a UART transmitter as a fourth AHB lite slave at address `0x5000_0000`. 

## The UART Transmitter


## UART Transmitter AHB Lite Interface
As a slave, it provides 4 registers

|register|Offset|Function|
|--------|------|--------|
|Control|0x00| bit 0: Enable<br>bit 1: Start|
|Baud Divisor| 0x04||
|Status|0x08| bit 0: Ready|
|Data|0x0C| |

## Modifications to TinySoC
- `uart_tx.v` : The UART Transmitter (new).
- `uart_tx_tb.v` : A testbench for the UART Transmitter (new).
- `ahbl_uart_tx.v` : The AHB lite bus interface for the UART Transmitter (new).
- `Hzard2_SoC.v` : Create an instance of the UART transmitter and connect it to the fourth SPlitter port. Also, added the port `UART_TX`
- `Hazard2_SoC_tb.v` : Added a serial terminal to display the transmitted messgaes.


