// 27 MHz clock = ~37.037 nanoseconds per period
create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}]