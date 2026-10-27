module uart_rx(
    input clk,
    input rst,
    input baud_tick,
    input rx_in,
    output reg [7:0] data_received,
    output reg ack_flag,
    output reg error_flag
);
    reg [2:0] bit_counter;
    reg [1:0] state;

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            data_received <= 0;
            bit_counter <= 0;
            ack_flag <= 0;
            error_flag <= 0;
        end else begin
            case(state)
                IDLE: begin
                    if (!rx_in) begin 
                        ack_flag <= 0;
                        // FIX: error_flag is intentionally NOT cleared here.
                        // It is now a "sticky bit" that stays High until a hard reset.
                        state <= START;
                    end
                end

                START: begin
                    if (baud_tick) begin
                        state <= DATA;
                        bit_counter <= 0;
                    end
                end

                DATA: begin
                    if (baud_tick) begin
                        data_received[bit_counter] <= rx_in;
                        if (bit_counter == 7) begin
                            state <= STOP;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                end

                STOP: begin
                    if (baud_tick) begin
                        if (rx_in == 1'b1) begin
                            // Only allow an ACK if no previous errors have latched
                            if (error_flag == 1'b0) begin
                                ack_flag <= 1; 
                            end
                        end else begin
                            ack_flag <= 0; 
                            error_flag <= 1; // Trigger the sticky error!
                        end
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule