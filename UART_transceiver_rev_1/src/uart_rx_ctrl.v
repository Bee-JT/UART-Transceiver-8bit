// ============================================================
// uart_rx_ctrl : receiver control FSM (no data, no counters of time)
//
//   IDLE  : wait for the line to go low
//           -> 'restart' re-aligns the baud generator to the falling edge
//   START : first tick lands mid start bit; line must still be low, else glitch
//   DATA  : every tick lands mid data bit -> 'sample_en' shifts the SIPO (8x)
//   STOP  : tick lands mid stop bit -> 'done' pulses, back to IDLE
//
// Tick sequence after a start edge: 1 (start) 2..9 (d0..d7) 10 (stop).
// ============================================================
module uart_rx_ctrl (
    input            clk,
    input            rst,
    input            rx_s,        // synchronised serial input
    input            tick,        // from baud_gen (bit-centre ticks)
    output           restart,     // to baud_gen
    output           sample_en,   // to sipo
    output reg       done,        // 1-clock pulse: byte is valid
    output     [1:0] state_out    // for GAO
);
    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    reg [1:0] state   = IDLE;
    reg [2:0] bit_cnt = 3'd0;

    assign restart   = (state == IDLE) && !rx_s;
    assign sample_en = (state == DATA) && tick;
    assign state_out = state;

    always @(posedge clk) begin
        if (rst) begin
            state   <= IDLE;
            bit_cnt <= 3'd0;
            done    <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE:  if (!rx_s) state <= START;

                START: if (tick) begin
                           if (!rx_s) begin
                               state   <= DATA;
                               bit_cnt <= 3'd0;
                           end else state <= IDLE;      // glitch, not a real start bit
                       end

                DATA:  if (tick) begin
                           if (bit_cnt == 3'd7) state <= STOP;
                           else bit_cnt <= bit_cnt + 1'b1;
                       end

                STOP:  if (tick) begin
                           done  <= 1'b1;
                           state <= IDLE;
                       end
            endcase
        end
    end
endmodule
