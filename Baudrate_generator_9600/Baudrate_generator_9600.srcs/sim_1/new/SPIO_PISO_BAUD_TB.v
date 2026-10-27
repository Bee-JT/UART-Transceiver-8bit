`timescale 1ns / 1ps

module SPIO_PISO_BAUD_TB;
    reg clk;
    reg rst;
    reg load;
    reg shift_en;
    reg [7:0] parallel_in;
    wire serial_line;
    wire [7:0] parallel_out;

    module PISO (
        .clk(clk),
        .rst(rst),
        .load(load),
        .shift_en(shift_en),
        .parallel_in(parallel_in),
        .serial_out(serial_line)
    );

    module SIPO (
        .clk(clk),
        .rst(rst),
        .data_in(serial_line),
        .shift_en(shift_en),
        .parallel_out(parallel_out)
    );

    module Baudrate_9600 (
        .clk(clk),
        .rst(rst),
        .baud_tick()
    );

    initial begin
        clk = 1'b0;
        forever #5 clk =~clk;  
    end

    initial begin
        rst = 1'b0;
        load = 1'b0;
        shift_en = 8'b00000000;
        #20; 
        rst = 1'b1;
        #10;  
        @(posedge clk);  
        parallel_in = 8'b10101010;
        load=1'b1;

        @(posedge clk);
        load =1'b0;

        repeat(8) begin
            @(posedge clk);
            shift_en = 1'b1;  
        end

        @(posedge clk);
        shift_en=1'b0;  
        #10;
    end

    always @ (posedge clk)begin
        if (baud_tick) begin
            shift_en = 1'b1;
        end else begin
            shift_en = 1'b0;
        end
    end

endmodule