// ============================================================
// led_latch : holds the low 6 bits of the last byte; LEDs are active-low
// ============================================================
module led_latch (
    input        clk,
    input        rst,
    input        load,
    input  [5:0] d,
    output [5:0] led_n
);
    reg [5:0] q = 6'd0;

    always @(posedge clk) begin
        if (rst)       q <= 6'd0;
        else if (load) q <= d;
    end

    assign led_n = ~q;
endmodule
