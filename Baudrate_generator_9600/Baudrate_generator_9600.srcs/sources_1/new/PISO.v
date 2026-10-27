`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2026 16:16:16
// Design Name: 
// Module Name: PISO
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


module PISO(
    input wire clk,
    input wire rst,
    input wire load,
    input wire shift_en,
    input wire [7:0]parallel_in,
    output wire serial_out
);
    reg [7:0]shift_reg;
    assign serial_out = shift_reg[0];
    always@(posedge clk) begin
        if(!rst) begin
            shift_reg <= 8'b00000000;
        end else if(load) begin
            shift_reg <= parallel_in;
        end else if(shift_en) begin
            shift_reg <= {1'b0, shift_reg[7:1]};
        end
    end  
endmodule
