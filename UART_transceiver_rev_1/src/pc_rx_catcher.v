// ============================================================
// pc_rx_catcher : catches bytes typed on the PC (onboard USB-UART, pin 18)
// Thin named wrapper around uart_rx so the PC side can be tuned separately.
// ============================================================
module pc_rx_catcher (
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
