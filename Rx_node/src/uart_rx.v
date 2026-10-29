module uart_rx (
    input wire clk,            // 27 MHz system clock
    input wire rst,
    input wire rx_in,          // 3.3V physical wire from Team B
    output reg [7:0] rx_byte,  // Reassembled 8-bit payload
    output reg rx_done         // Trigger pulse when byte is ready
);

    parameter CLKS_PER_BIT = 16'd2812; // 27 MHz / 9600 bps

    // Hardware States
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] shift_reg; // The Serial-In, Parallel-Out (SIPO) buffer

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
            rx_done <= 1'b0;
            rx_byte <= 8'd0;
        end else begin
            rx_done <= 1'b0; // Default: line quiet

            case (state)
                IDLE: begin
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (rx_in == 1'b0) // Start bit pulls the copper low
                        state <= START;
                end

                START: begin
                    // Wait exactly 0.5 baud periods to hit the middle of the start bit
                    if (clk_count == (CLKS_PER_BIT / 2)) begin
                        if (rx_in == 1'b0) begin
                            clk_count <= 16'd0;
                            state <= DATA;
                        end else
                            state <= IDLE; // Glitch rejected
                    end else begin
                        clk_count <= clk_count + 16'd1;
                    end
                end

                DATA: begin
                    if (clk_count == (CLKS_PER_BIT - 16'd1)) begin
                        clk_count <= 16'd0;
                        shift_reg[bit_index] <= rx_in; // Sample the copper line
                        if (bit_index == 3'd7) begin
                            bit_index <= 3'd0;
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 3'd1;
                        end
                    end else begin
                        clk_count <= clk_count + 16'd1;
                    end
                end

                STOP: begin
                    if (clk_count == (CLKS_PER_BIT - 16'd1)) begin
                        clk_count <= 16'd0;
                        rx_byte <= shift_reg; // Dump SIPO buffer to parallel bus
                        rx_done <= 1'b1;      // Fire the completion trigger
                        state <= IDLE;
                    end else begin
                        clk_count <= clk_count + 16'd1;
                    end
                end
            endcase
        end
    end
endmodule