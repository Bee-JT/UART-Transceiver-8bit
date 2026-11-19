// ============================================================
// baud_gen : programmable one-clock-wide tick generator
//
//   tick pulses once every CLKS_PER_BIT clocks.
//   'restart' re-aligns the counter to PRELOAD.
//
//   TX use : PRELOAD = 0               -> first tick one full bit after restart
//   RX use : PRELOAD = CLKS_PER_BIT/2  -> first tick half a bit after restart
//            (i.e. in the middle of the start bit), then every bit centre.
//
//   27 MHz / 9600 baud = 2812.5 -> 2812 (0.018 % error, harmless)
// ============================================================
module baud_gen #(
    parameter CLKS_PER_BIT = 2812,
    parameter PRELOAD      = 0
)(
    input      clk,
    input      rst,
    input      restart,
    output reg tick
);
    reg [15:0] counter = 16'd0;

    always @(posedge clk) begin
        if (rst || restart) begin
            counter <= PRELOAD;
            tick    <= 1'b0;
        end else if (counter == CLKS_PER_BIT - 1) begin
            counter <= 16'd0;
            tick    <= 1'b1;
        end else begin
            counter <= counter + 1'b1;
            tick    <= 1'b0;
        end
    end
endmodule
