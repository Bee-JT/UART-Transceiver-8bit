module piso #(parameter WIDTH = 10)(
    input clk,
    input rst,
    input load,
    input shift,
    input [WIDTH-1:0] parallel_in,
    output serial_out
);
    (* syn_preserve = 1 *) reg [WIDTH-1:0] shift_reg;
    assign serial_out = shift_reg[0];

    always @(posedge clk) begin
        if (rst) begin
            shift_reg <= {WIDTH{1'b1}}; 
        end else if (load) begin
            shift_reg <= parallel_in;
        end else if (shift) begin
            shift_reg <= {1'b1, shift_reg[WIDTH-1:1]};
        end
    end
endmodule