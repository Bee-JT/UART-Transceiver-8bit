module uart_tx(
    input clk,
    input rst,
    input start,
    input [7:0] data_to_send,
    input baud_tick,
    output reg tx_out,
    output reg busy
);
    reg [2:0] bit_counter;
    reg [7:0] byte_tx;
    reg [1:0] state;
    
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            tx_out <= 1; 
            busy <= 0;
            bit_counter <= 0;
            byte_tx <= 0;
        end else begin
            case(state)
                IDLE: begin
                    tx_out <= 1;
                    if (start && !busy) begin
                        busy <= 1;
                        byte_tx <= data_to_send;
                        state <= START;
                    end else begin
                        busy <= 0;
                    end
                end
                
                START: begin
                    if (baud_tick) begin
                        tx_out <= 0; // START bit
                        bit_counter <= 0;
                        state <= DATA;
                    end
                end
                
                DATA: begin
                    if (baud_tick) begin
                        tx_out <= byte_tx[bit_counter];
                        if (bit_counter == 7) begin
                            state <= STOP;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                end
                
                STOP: begin
                    if (baud_tick) begin
                        tx_out <= 1; // STOP bit
                        busy <= 0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule