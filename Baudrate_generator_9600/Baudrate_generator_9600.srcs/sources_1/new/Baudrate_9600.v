`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2026 15:53:54
// Design Name: 
// Module Name: Baudrate_9600
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


module Baudrate_9600 #(
    parameter Clk_freq = 50000000, 
    parameter Baudrate = 9600
)(
    input clk,
    input rst,
    output reg baud_tick
);
    localparam MAX_COUNT = Clk_freq / Baudrate;
    reg [15:0] counter;

    always @(posedge clk) begin 
        if (rst) begin
            counter <= 0;
            baud_tick <= 0;
        end else if (counter == MAX_COUNT - 1) begin 
            counter <= 0;
            baud_tick <= 1;
        end else begin
            counter <= counter + 1;
            baud_tick <= 0;
        end
    end 
endmodule
  