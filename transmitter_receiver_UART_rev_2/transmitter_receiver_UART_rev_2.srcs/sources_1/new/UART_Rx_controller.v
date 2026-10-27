module uart_rx(
    input clk,
    input rst,
    input rx_in,
    input baud_tick,
    output reg [7:0] data_out,
    output reg rx_done,
    output reg error_flag
);
    reg [3:0] bit_shifts;
    reg receiving;
    reg evaluate_frame; 
    
    wire shift_sipo;
    wire [9:0] sipo_parallel;

    // Instantiate the Datapath
    sipo #(.WIDTH(10)) sipo_inst (
        .clk(clk),
        .rst(rst),
        .shift(shift_sipo),
        .serial_in(rx_in),
        .parallel_out(sipo_parallel)
    );

    // Control Logic Wire
    assign shift_sipo = (baud_tick && receiving);

    // State Counter & Evaluation
    always @(posedge clk) begin
        if (rst) begin
            bit_shifts <= 0;
            receiving <= 0;
            evaluate_frame <= 0;
            rx_done <= 0;
            error_flag <= 0;
            data_out <= 0;
        end else begin
            if (rx_done) rx_done <= 0;
            if (evaluate_frame) evaluate_frame <= 0;

            // 1. Frame Evaluation (Reads from SIPO after shifts are complete)
            if (evaluate_frame) begin
                // Verify 8-N-1 format: [9] must be STOP (1), [0] must be START (0)
                if (sipo_parallel[9] == 1'b1 && sipo_parallel[0] == 1'b0) begin
                    data_out <= sipo_parallel[8:1];
                    rx_done <= 1;
                end else begin
                    error_flag <= 1; // Sticky Error
                end
            end

            // 2. Receiving State Machine
            if (!receiving) begin
                if (!rx_in) begin
                    receiving <= 1;
                    bit_shifts <= 0;
                end
            end else if (baud_tick) begin
                bit_shifts <= bit_shifts + 1;
                if (bit_shifts == 9) begin
                    receiving <= 0;
                    evaluate_frame <= 1; // Trigger verification on the next clock cycle
                end
            end
        end
    end
endmodule