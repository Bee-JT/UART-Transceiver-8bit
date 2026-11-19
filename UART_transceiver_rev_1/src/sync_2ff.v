// ============================================================
// sync_2ff : two-flip-flop synchronizer for an asynchronous input
// Initialised to 1 so an idle-high UART line never shows a false start bit.
// ============================================================
module sync_2ff (
    input  clk,
    input  d,
    output q
);
    reg s1 = 1'b1;
    reg s2 = 1'b1;

    always @(posedge clk) begin
        s1 <= d;
        s2 <= s1;
    end

    assign q = s2;
endmodule
