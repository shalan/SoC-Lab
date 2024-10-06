CROSS=riscv64-unknown-elf-
CFLAGS=-march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -O2 -Wall
LFLAGS=-Wl,--build-id=none,-Bstatic,-T,link.ld,--strip-debug
VFILES=Hazard2_SoC.f
TBFILES=Hazard2_SoC_tb.v

# Rule for simulation using iverilog
sim: test.vvp
	vvp test.vvp

# Compile Verilog files and testbench into a vvp file for simulation
test.vvp: $(VFILES) $(TBFILES) test.hex
	iverilog -f $(VFILES) -o test.vvp $(TBFILES)

# Generate test.hex file from test.elf
test.hex: test.elf
	$(CROSS)objdump -D test.elf > test.asm
	$(CROSS)objcopy --verilog-data-width=4 -O verilog test.elf test.hex

# Compile the C code into a RISC-V ELF executable
test.elf: link.ld crt.s test.c
	$(CROSS)gcc $(CFLAGS) $(LFLAGS) -o test.elf crt.s test.c

# A pseudo target to ensure hex files are generated before simulation
hex: test.hex

# Default target to build everything
all: sim

# Clean up generated files
clean:
	rm -f *.elf *.hex *.vvp *.asm
