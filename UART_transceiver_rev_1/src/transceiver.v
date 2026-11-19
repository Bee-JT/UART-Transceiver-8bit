// ============================================================
// FULL-DUPLEX UART TRANSCEIVER (top level) - same design on BOTH boards
// Sipeed Tang Nano 9K, 27 MHz clock, 9600 baud, 8-N-1
//
//   PC keyboard -> pin 18 -> pc_rx_catcher -> f1 FIFO -> link_tx_inst -> pin 25 -> other board
//   other board -> pin 26 -> link_rx_catcher -> f2 FIFO -+
//                                                        +-> pc_tx_arbiter -> pc_tx_inst -> pin 17 -> PC screen
//   (local echo)  pc_rx_catcher -> f3 FIFO --------------+
//
// Wiring between two boards:  A25 -> B26,  B25 -> A26,  GND - GND
// ============================================================
module transceiver #(
    parameter ECHO_LOCAL = 1,   // 1: your own typing also shows on your own terminal
    parameter CR_TO_CRLF = 1    // 1: add LF after every CR sent to the PC terminal
)(
    input        clk,           // Pin 52 (27 MHz)
    input        pc_rx_pin,     // Pin 18 (PC -> FPGA)
    output       pc_tx_pin,     // Pin 17 (FPGA -> PC)
    input        link_rx,       // Pin 26 (from other board)
    output       link_tx,       // Pin 25 (to other board)
    output [5:0] led            // Onboard LEDs, active-low
);
    // ---------------- reset ----------------
    wire rst;
    por_reset #(.BITS(8)) por_inst (.clk(clk), .rst(rst));

    // ---------------- receivers ----------------
    wire [7:0] pc_data_in,   link_data_in;
    wire       pc_got,       link_got;
    (* syn_keep = 1 *) wire [1:0] pc_rx_state;
    (* syn_keep = 1 *) wire [1:0] link_rx_state;

    pc_rx_catcher pc_catcher (
        .clk(clk), .rst(rst), .rx_in(pc_rx_pin),
        .data_out(pc_data_in), .rx_done(pc_got), .state_out(pc_rx_state)
    );

    link_rx_catcher link_catcher (
        .clk(clk), .rst(rst), .rx_in(link_rx),
        .data_out(link_data_in), .rx_done(link_got), .state_out(link_rx_state)
    );

    // ---------------- path 1: PC -> other board ----------------
    wire [7:0] f1_data;
    wire       f1_empty;
    (* syn_keep = 1 *) wire link_busy;
    wire       f1_pop = !f1_empty && !link_busy;

    byte_fifo f1_pc_to_link (
        .clk(clk), .rst(rst),
        .wr_en(pc_got), .wr_data(pc_data_in),
        .rd_en(f1_pop), .rd_data(f1_data), .empty(f1_empty)
    );

    uart_tx #(.CLKS_PER_BIT(2812)) link_tx_inst (
        .clk(clk), .rst(rst),
        .start(f1_pop), .data_in(f1_data),
        .tx_out(link_tx), .busy(link_busy)
    );

    // ---------------- path 2: other board (+ local echo) -> PC ----------------
    wire [7:0] f2_data, f3_data;
    wire       f2_empty, f3_empty;
    wire       pop_link, pop_echo;
    (* syn_keep = 1 *) wire pc_busy;

    byte_fifo f2_link_to_pc (
        .clk(clk), .rst(rst),
        .wr_en(link_got), .wr_data(link_data_in),
        .rd_en(pop_link), .rd_data(f2_data), .empty(f2_empty)
    );

    byte_fifo f3_echo_to_pc (
        .clk(clk), .rst(rst),
        .wr_en((ECHO_LOCAL != 0) & pc_got), .wr_data(pc_data_in),
        .rd_en(pop_echo), .rd_data(f3_data), .empty(f3_empty)
    );

    wire       pc_start;
    wire [7:0] pc_data_out;

    pc_tx_arbiter #(.CR_TO_CRLF(CR_TO_CRLF)) arbiter (
        .clk(clk), .rst(rst), .pc_busy(pc_busy),
        .link_empty(f2_empty), .link_data(f2_data), .pop_link(pop_link),
        .echo_empty(f3_empty), .echo_data(f3_data), .pop_echo(pop_echo),
        .start(pc_start), .data_out(pc_data_out)
    );

    uart_tx #(.CLKS_PER_BIT(2812)) pc_tx_inst (
        .clk(clk), .rst(rst),
        .start(pc_start), .data_in(pc_data_out),
        .tx_out(pc_tx_pin), .busy(pc_busy)
    );

    // ---------------- LEDs: last byte from the other board ----------------
    led_latch leds (
        .clk(clk), .rst(rst),
        .load(link_got), .d(link_data_in[5:0]), .led_n(led)
    );

    // ---------------- optional GAO debug ----------------
    (* syn_keep = 1 *) wire gao_clk;
    (* syn_keep = 1 *) wire pc_toggle;
    (* syn_keep = 1 *) wire link_toggle;

    gao_helper gao_inst (
        .clk(clk), .evt_a(pc_got), .evt_b(link_got),
        .gao_clk(gao_clk), .toggle_a(pc_toggle), .toggle_b(link_toggle)
    );
endmodule
