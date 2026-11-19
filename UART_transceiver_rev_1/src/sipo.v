// ============================================================
// sipo : Serial-In Parallel-Out shift register (used by the receiver)
//
// Bits arrive LSB first (UART). Each bit enters at the MSB and everything
// shifts right, so after WIDTH shifts the first bit received sits in bit 0.
// ============================================================
module sipo #(
    parameter WIDTH = 8
)(
    input                  clk,
    input                  rst,
    input                  shift_en,     // 1 clock-wide: take serial_in now
    input                  serial_in,
    output [WIDTH-1:0]     parallel_out
);
    reg [WIDTH-1:0] shift_reg = {WIDTH{1'b0}};

    always @(posedge clk) begin
        if (rst)           shift_reg <= {WIDTH{1'b0}};
        else if (shift_en) shift_reg <= {serial_in, shift_reg[WIDTH-1:1]};
    end

    assign parallel_out = shift_reg;
endmodule
