// ============================================================
// piso : Parallel-In Serial-Out shift register (used by the transmitter)
//
// load  : capture parallel_in  (priority over shift)
// shift : move to the next bit, filling with 1s (line idles high)
// serial_out is always bit 0. Resets / idles to all 1s.
// ============================================================
module piso #(
    parameter WIDTH = 10
)(
    input                  clk,
    input                  rst,
    input                  load,
    input                  shift,
    input  [WIDTH-1:0]     parallel_in,
    output                 serial_out
);
    (* syn_preserve = 1 *) reg [WIDTH-1:0] shift_reg = {WIDTH{1'b1}};
    assign serial_out = shift_reg[0];

    always @(posedge clk) begin
        if (rst)        shift_reg <= {WIDTH{1'b1}};
        else if (load)  shift_reg <= parallel_in;
        else if (shift) shift_reg <= {1'b1, shift_reg[WIDTH-1:1]};
    end
endmodule
