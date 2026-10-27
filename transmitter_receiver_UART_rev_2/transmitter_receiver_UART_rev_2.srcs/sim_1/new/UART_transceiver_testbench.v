`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2026 00:19:03
// Design Name: 
// Module Name: UART_transceiver_testbench
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


module tb_dual_transceiver;
    reg clk;
    reg rst;

    // Device A controls
    reg start_A;
    reg [7:0] data_in_A;
    wire [7:0] data_out_A;
    wire rx_done_A, rx_error_A, tx_busy_A;

    // Device B controls
    reg start_B;
    reg [7:0] data_in_B;
    wire [7:0] data_out_B;
    wire rx_done_B, rx_error_B, tx_busy_B;

    // Cross-wired serial lines
    wire serial_A_to_B;
    wire serial_B_to_A;

    // 50 MHz System Clock
    initial clk = 0;
    always #10 clk = ~clk;

    // Instantiate Device A 
    uart_transceiver #(.CLK_FREQ(50000000), .BAUD_RATE(9600)) Device_A (
        .clk(clk), .rst(rst),
        .start_tx(start_A), .data_to_send(data_in_A), .tx_line(serial_A_to_B), .tx_busy(tx_busy_A),
        .rx_line(serial_B_to_A), .data_received(data_out_A), .rx_done(rx_done_A), .rx_error(rx_error_A)
    );

    // Instantiate Device B 
    uart_transceiver #(.CLK_FREQ(50000000), .BAUD_RATE(9600)) Device_B (
        .clk(clk), .rst(rst),
        .start_tx(start_B), .data_to_send(data_in_B), .tx_line(serial_B_to_A), .tx_busy(tx_busy_B),
        .rx_line(serial_A_to_B), .data_received(data_out_B), .rx_done(rx_done_B), .rx_error(rx_error_B)
    );

    initial begin
        // 1. Reset the system
        rst = 1; start_A = 0; start_B = 0; data_in_A = 0; data_in_B = 0;
        #100; rst = 0; #100;

        // 2. PHASE 1: Device A sends data to Device B
        data_in_A = 8'h5A; 
        start_A = 1; 
        #20; 
        start_A = 0; 

        // Wait 1.5ms for A's transmission to travel across the wire to B
        #1500000;

        $display("--- PHASE 1: A Transmits to B ---");
        $display("Device B received: %h (Expected: 5a) | Error: %b", data_out_B, rx_error_B);

        // 3. PHASE 2: Device B sends Acknowledgement back to Device A
        // 0xAA is a common test byte for Acknowledgement
        data_in_B = 8'hAA; 
        start_B = 1;
        #20; 
        start_B = 0;

        // Wait another 1.5ms for B's acknowledgement to travel back to A
        #1500000;

        $display("--- PHASE 2: B Sends ACK to A ---");
        $display("Device A received ACK: %h (Expected: aa) | Error: %b", data_out_A, rx_error_A);
        
        $display("--- TEST COMPLETE ---");
        $finish;
    end
endmodule