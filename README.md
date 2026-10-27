# 8-Bit UART Transceiver Core (Verilog HDL)



A synthesizable 8-bit UART core in Verilog HDL featuring configurable baud rates, oversampled receiver logic, full-duplex transmission, and testbenches.



## Architecture



- baud_rate_gen.v: Generates sampling ticks from system clock (standard 1x baud tick for TX, 16x oversampled tick for RX).

- uart_tx.v: Transmit engine. Serializes 8-bit parallel data LSB-first with 1 start bit and 1 stop bit.

- uart_rx.v: Receive engine. Uses 16x oversampling with midpoint majority voting to capture serial data.

- uart_top.v: Top-level integration module connecting baud generator, TX, and RX.



## Protocol Specification



- Data width: 8 bits

- Start bit: 1 bit (Low)

- Stop bit: 1 bit (High)

- Parity: None (8-N-1)

- Bit order: LSB first



## Baud Rates (50 MHz Clock)



- 9600 bps: 16x oversample divider = 325

- 115200 bps: 16x oversample divider = 27



## Simulation & Testing



- Use Icarus Verilog or Vivado to run `uart_top_tb.v`.

- Performs full loopback verification by tying TX out to RX in.

