// ============================================================
// por_reset : power-on reset generator
// Holds rst = 1 for 2^(BITS-1) clock cycles after configuration
// (BITS = 8 -> 128 cycles = ~4.7 us at 27 MHz). No reset button needed.
// ============================================================
module por_reset #(
    parameter BITS = 8
)(
    input  clk,
    output rst
);
    reg [BITS-1:0] cnt = {BITS{1'b0}};
    assign rst = ~cnt[BITS-1];

    always @(posedge clk)
        if (!cnt[BITS-1]) cnt <= cnt + 1'b1;
endmodule
