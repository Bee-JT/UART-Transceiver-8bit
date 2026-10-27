module fpga_tx_only (
    input clk,       // 50 MHz Artix-7 System Clock
    input rst,       // Reset button (Active High)
    output tx_line   // Wire connected to ESP32 GPIO16
);
    wire baud_tick;
    wire tx_busy;
    reg start_tx;
    reg [7:0] data_to_send;
    reg [25:0] delay_counter; 

    // Instantiate the Baud Rate Generator
    baud_rate_generator #(.CLK_FREQ(50000000), .BAUD_RATE(9600)) baud_gen (
        .clk(clk), .rst(rst), .baud_tick(baud_tick)
    );

    // Instantiate the Modular Transmitter
    uart_tx_v2 tx_inst (
        .clk(clk), .rst(rst), .start(start_tx), .data_in(data_to_send),
        .baud_tick(baud_tick), .tx_out(tx_line), .busy(tx_busy)
    );

    // 1-Second Timer & Data Dispatcher
    always @(posedge clk) begin
        if (rst) begin
            delay_counter <= 0;
            start_tx <= 0;
            data_to_send <= 8'h41; // Start at ASCII 'A'
        end else begin
            start_tx <= 0; 
            
            // 50,000,000 clock cycles = 1 second at 50MHz
            if (delay_counter == 50000000 - 1) begin
                delay_counter <= 0;
                
                if (!tx_busy) begin
                    start_tx <= 1; 
                    
                    // Increment the ASCII character, reset after 'Z' (0x5A)
                    if (data_to_send == 8'h5A) data_to_send <= 8'h41; 
                    else data_to_send <= data_to_send + 1;
                end
            end else begin
                delay_counter <= delay_counter + 1;
            end
        end
    end
endmodule