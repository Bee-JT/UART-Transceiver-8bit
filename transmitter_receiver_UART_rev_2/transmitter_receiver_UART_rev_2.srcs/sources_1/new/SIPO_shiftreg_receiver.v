module sipo #(parameter WIDTH = 10)
(
    input clk,
    input rst,
    input shift,
    input serial_in,
    output [WIDTH-1:0] parallel_out
);
    reg [WIDTH-1:0] shift_reg;
    
    // Constantly expose the entire register to the controller
    assign parallel_out = shift_reg;

    always @(posedge clk) begin
        if (rst) begin
            shift_reg <= {WIDTH{1'b0}};
        end else if (shift) begin
            // Shift right by 1, pull the new serial bit into the MSB
            shift_reg <= {serial_in, shift_reg[WIDTH-1:1]};
        end
    end
endmodule