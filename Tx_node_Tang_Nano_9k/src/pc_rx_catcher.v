module pc_rx_catcher(
    input clk,       // 27 MHz
    input rst,
    input rx_in,     // Incoming line from the PC USB
    output reg [7:0] data_out,
    output reg rx_done
);
    // Timing constants for 27MHz and 9600 baud
    localparam CLK_PER_BIT = 2812; 
    localparam CLK_HALF_BIT = 1406;     

    reg [2:0] state;
    reg [15:0] timer;
    reg [2:0] bit_index;

    always @(posedge clk) begin
        if (rst) begin
            state <= 0;
            rx_done <= 0;
            timer <= 0;
            data_out <= 0;
            bit_index <= 0;
        end else begin
            rx_done <= 0; // Default pulse low
            case (state)
                0: begin // Idle: Wait for Start Bit drop
                    if (rx_in == 0) begin
                        state <= 1;
                        timer <= 0;
                    end
                end
                1: begin // Verify it is a valid Start Bit by sampling the middle
                    if (timer == CLK_HALF_BIT) begin
                        if (rx_in == 0) begin
                            timer <= 0;
                            state <= 2;
                            bit_index <= 0;
                        end else state <= 0; // Glitch detected, ignore
                    end else timer <= timer + 1;
                end
                2: begin // Shift in the 8 Data Bits
                    if (timer == CLK_PER_BIT - 1) begin
                        timer <= 0;
                        data_out[bit_index] <= rx_in;
                        if (bit_index == 7) state <= 3;
                        else bit_index <= bit_index + 1;
                    end else timer <= timer + 1;
                end
                3: begin // Wait for the Stop Bit
                    if (timer == CLK_PER_BIT - 1) begin
                        rx_done <= 1; // Pulse high to tell the PISO to transmit
                        state <= 0;
                    end else timer <= timer + 1;
                end
            endcase
        end
    end
endmodule