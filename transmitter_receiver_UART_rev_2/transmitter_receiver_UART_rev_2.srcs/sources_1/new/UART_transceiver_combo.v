`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2026 00:14:10
// Design Name: 
// Module Name: UART_transceiver_combo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_transceiver #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input clk,
    input rst,
    // TX Pins
    input start_tx,
    input [7:0] data_to_send,
    output tx_line,
    output tx_busy,
    // RX Pins
    input rx_line,
    output [7:0] data_received,
    output rx_done,
    output rx_error
);
    wire baud_tick;

    baud_rate_generator #(
        .CLK_FREQ(CLK_FREQ), 
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen (
        .clk(clk), .rst(rst), .baud_tick(baud_tick)
    );

    uart_tx tx_inst (
        .clk(clk), .rst(rst), .start(start_tx), .data_in(data_to_send),
        .baud_tick(baud_tick), .tx_out(tx_line), .busy(tx_busy)
    );

    uart_rx rx_inst (
        .clk(clk), .rst(rst), .rx_in(rx_line), .baud_tick(baud_tick),
        .data_out(data_received), .rx_done(rx_done), .error_flag(rx_error)
    );
endmodule
