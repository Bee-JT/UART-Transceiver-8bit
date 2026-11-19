// ============================================================
// uart_rx : generic UART receiver, 8-N-1
//
//   rx_in --> sync_2ff --> uart_rx_ctrl --> sipo --> data_out
//                              ^  |
//                    tick      |  | restart
//                     baud_gen <--+
// ============================================================
module uart_rx #(
    parameter CLKS_PER_BIT = 2812
)(
    input        clk,
    input        rst,
    input        rx_in,           // asynchronous serial line (idles high)
    output [7:0] data_out,        // stable while / after rx_done
    output       rx_done,         // 1-clock pulse
    output [1:0] state_out        // for GAO
);
    wire rx_s;
    wire tick, restart, sample_en;

    sync_2ff input_sync (
        .clk(clk), .d(rx_in), .q(rx_s)
    );

    baud_gen #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .PRELOAD(CLKS_PER_BIT / 2)
    ) rx_baud (
        .clk(clk), .rst(rst), .restart(restart), .tick(tick)
    );

    uart_rx_ctrl ctrl (
        .clk(clk), .rst(rst), .rx_s(rx_s), .tick(tick),
        .restart(restart), .sample_en(sample_en),
        .done(rx_done), .state_out(state_out)
    );

    sipo #(.WIDTH(8)) rx_sipo (
        .clk(clk), .rst(rst),
        .shift_en(sample_en), .serial_in(rx_s),
        .parallel_out(data_out)
    );
endmodule
