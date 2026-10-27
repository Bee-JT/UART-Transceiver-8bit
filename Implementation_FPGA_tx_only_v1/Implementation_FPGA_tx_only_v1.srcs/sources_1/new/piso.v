module piso #(parameter WIDTH = 10)(
    input clk,
    input rst,
    input load,
    input shift,
    input [WIDTH-1:0] parallel_in,
    output serial_out
);
    reg [WIDTH-1:0] shift_reg;
    
    // Serial output is permanently wired to the Least Significant Bit
    assign serial_out = shift_reg[0];

    always @(posedge clk) begin
        if (rst) begin
            shift_reg <= {WIDTH{1'b1}}; // Default idle state is High (1)
        end else if (load) begin
            shift_reg <= parallel_in;
        end else if (shift) begin
            // Shift right by 1, pad the left with 1s
            shift_reg <= {1'b1, shift_reg[WIDTH-1:1]};
        end
    end
endmodule