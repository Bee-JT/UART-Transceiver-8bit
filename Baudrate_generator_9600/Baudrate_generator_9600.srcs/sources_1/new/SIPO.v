`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2026 15:58:59
// Design Name: 
// Module Name: SIPO
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


module SIPO(
    input wire clk,
    input wire rst,
    input wire data_in,
    input wire shift_en,
    output reg [7:0]parallel_out
);
    always@(posedge clk) begin
        if(rst) begin
            parallel_out <= 8'b00000000;
        end else if(shift_enable) begin
            parallel_out <= {data_in, parallel_out[7:1]};
        end
   end           
endmodule
