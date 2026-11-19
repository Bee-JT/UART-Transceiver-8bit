// ============================================================
// uart_tx : generic UART transmitter, 8-N-1
//
//   start,data_in --> uart_tx_ctrl --load/shift--> piso --> tx_out
//                          ^   | load (restart)
//                  tick    |   v
//                         baud_gen
// ============================================================
module uart_tx #(
    parameter CLKS_PER_BIT = 2812
)(
    input        clk,
    input        rst,
    input        start,
    input  [7:0] data_in,
    output       tx_out,
    output       busy
);
    wire tick, load, shift;

    baud_gen #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .PRELOAD(0)
    ) tx_baud (
        .clk(clk), .rst(rst), .restart(load), .tick(tick)
    );

    uart_tx_ctrl ctrl (
        .clk(clk), .rst(rst), .start(start), .baud_tick(tick),
        .load(load), .shift(shift), .busy(busy)
    );

    piso #(.WIDTH(10)) tx_piso (
        .clk(clk), .rst(rst),
        .load(load), .shift(shift),
        .parallel_in({1'b1, data_in, 1'b0}),    // stop, data[7:0], start
        .serial_out(tx_out)
    );
endmodule
