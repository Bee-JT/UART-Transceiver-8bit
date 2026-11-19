// ============================================================
// gao_helper : optional debug aids for Gowin Analyzer Oscilloscope
//   gao_clk  : clk / 64 = 421.875 kHz  (~44 samples per 9600-baud bit)
//   toggle_* : flip on every event pulse (1-clock pulses vanish at gao_clk)
// If you do not use GAO you can delete the instance in transceiver.v.
// ============================================================
module gao_helper (
    input  clk,
    input  evt_a,
    input  evt_b,
    output gao_clk,
    output toggle_a,
    output toggle_b
);
    (* syn_preserve = 1 *) reg [5:0] div = 6'd0;
    (* syn_keep = 1 *)     reg ta = 1'b0;
    (* syn_keep = 1 *)     reg tb = 1'b0;

    always @(posedge clk) begin
        div <= div + 1'b1;
        if (evt_a) ta <= ~ta;
        if (evt_b) tb <= ~tb;
    end

    assign gao_clk  = div[5];
    assign toggle_a = ta;
    assign toggle_b = tb;
endmodule
