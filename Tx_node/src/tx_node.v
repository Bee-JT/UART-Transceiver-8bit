module tx_node (
    input clk,          // Pin 52 (27 MHz onboard clock)
    input rst,          // Pin 3 (Physical button)
    input pc_rx_pin,    // Pin 86 (Onboard USB-to-UART RX pin)
    output b_tx    // Your chosen GPIO wire out to  B
);
    wire baud_tick;
    wire [7:0] typed_data;
    wire pc_byte_ready;
    wire tx_busy;

    // 1. Generate 9600 bps tick
    baud_gen_27mhz clk_div (
        .clk(clk), .rst(rst), .baud_tick(baud_tick)
    );

    // 2. Catch the ASCII character typed on your PC
    pc_rx_catcher pc_listener (
        .clk(clk), .rst(rst), .rx_in(pc_rx_pin), 
        .data_out(typed_data), .rx_done(pc_byte_ready)
    );

    // 3. Immediately transmit that character via PISO to  B
    uart_tx_v2 tx_inst (
        .clk(clk), .rst(rst), .start(pc_byte_ready), .data_in(typed_data),
        .baud_tick(baud_tick), .tx_out(b_tx), .busy(tx_busy)
    );
endmodule