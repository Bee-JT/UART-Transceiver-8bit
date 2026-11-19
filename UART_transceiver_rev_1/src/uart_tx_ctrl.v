// ============================================================
// uart_tx_ctrl : transmitter control
//
// start (while idle) -> load pulse; baud_gen is restarted by 'load', so the
// start bit is always a full bit long. 10 baud ticks later (start + 8 data +
// stop) busy drops again.
// ============================================================
module uart_tx_ctrl (
    input      clk,
    input      rst,
    input      start,       // request to send (ignored while busy)
    input      baud_tick,
    output     load,        // to piso + baud_gen restart
    output     shift,       // to piso
    output reg busy
);
    reg [3:0] bit_shifts = 4'd0;

    assign load  = start && !busy;
    assign shift = baud_tick && busy;

    always @(posedge clk) begin
        if (rst) begin
            busy       <= 1'b0;
            bit_shifts <= 4'd0;
        end else if (load) begin
            busy       <= 1'b1;
            bit_shifts <= 4'd10;
        end else if (shift) begin
            if (bit_shifts == 4'd1) busy <= 1'b0;
            else bit_shifts <= bit_shifts - 1'b1;
        end
    end
endmodule
