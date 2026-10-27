module uart_self_test #(
    parameter CLK_FREQ = 50000000,
    parameter TX_BAUD = 9600,
    parameter RX_BAUD = 9600
)(
    input clk,
    input rst,
    input start,
    input [7:0] data_to_send,
    output [7:0] data_received,
    output ack_flag,
    output error_flag
);
    wire tx_baud_tick;
    wire rx_baud_tick;
    wire internal_serial_line;
    wire tx_busy;

    // TX Baud Generator
    baud_rate_generator #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(TX_BAUD)) brg_tx (
        .clk(clk), .rst(rst), .baud_tick(tx_baud_tick)
    );

    // RX Baud Generator
    baud_rate_generator #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(RX_BAUD)) brg_rx (
        .clk(clk), .rst(rst), .baud_tick(rx_baud_tick)
    );

    // Transmitter
    uart_tx tx_inst (
        .clk(clk), .rst(rst), .start(start),
        .data_to_send(data_to_send), .baud_tick(tx_baud_tick),
        .tx_out(internal_serial_line), .busy(tx_busy)
    );

    // Receiver (Reading directly from TX output)
    uart_rx rx_inst (
        .clk(clk), .rst(rst), .baud_tick(rx_baud_tick),
        .rx_in(internal_serial_line), .data_received(data_received),
        .ack_flag(ack_flag), .error_flag(error_flag)
    );

endmodule