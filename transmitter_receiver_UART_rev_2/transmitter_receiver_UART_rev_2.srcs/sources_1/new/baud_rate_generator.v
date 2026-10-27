module baud_rate_generator #(
    parameter CLK_FREQ = 50000000, 
    parameter BAUD_RATE = 9600
)(
    input clk,
    input rst,
    output reg baud_tick
);
    localparam MAX_COUNT = CLK_FREQ / BAUD_RATE;
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