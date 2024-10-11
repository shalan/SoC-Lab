# LAB 2 : Tiny SoC
In this experiment, we are creating a simple AHB lite based SoC that contains:
- Hazard 2 CPU (Master)
- A 32-bit GPIO (Slave @ 0x40000000)
- 8 kBytes Program RAM (Slave @ 0x00000000)
- 8 kBytes Data RAM (Slave @ 0x20000000)
- A 4-port AHB lite Splitter with a bus mux and a bus decoder. The fourth port is unused.
