// ============================================================
// link_rx_catcher : catches bytes arriving from the other board (pin 26)
// Thin named wrapper around uart_rx so the link side can be tuned separately.
// ============================================================
module link_rx_catcher (
    input        clk,
    input        rst,
    input        rx_in,
    output [7:0] data_out,
    output       rx_done,
    output [1:0] state_out
);
    uart_rx #(.CLKS_PER_BIT(2812)) core (
        .clk(clk), .rst(rst), .rx_in(rx_in),
        .data_out(data_out), .rx_done(rx_done), .state_out(state_out)
    );
endmodule
