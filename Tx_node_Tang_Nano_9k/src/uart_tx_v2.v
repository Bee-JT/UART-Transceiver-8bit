module uart_tx_v2(
    input clk,
    input rst,
    input start,
    input [7:0] data_in,
    input baud_tick,
    output tx_out,
    output reg busy
);
    reg [3:0] bit_shifts;
    wire load_piso;
    wire shift_piso;

    // Instantiate the PISO Shift Register
    piso #(.WIDTH(10)) piso_inst (
        .clk(clk), .rst(rst),
        .load(load_piso), .shift(shift_piso),
        .parallel_in({1'b1, data_in, 1'b0}), // 8-N-1 format
        .serial_out(tx_out)
    );

    assign load_piso = (start && !busy);
    assign shift_piso = (baud_tick && busy);

    always @(posedge clk) begin
        if (rst) begin
            busy <= 0;
            bit_shifts <= 0;
        end else begin
            if (start && !busy) begin
                busy <= 1;
                bit_shifts <= 10;
            end else if (baud_tick && busy) begin
                if (bit_shifts == 1) busy <= 0;
                else bit_shifts <= bit_shifts - 1;
            end
        end
    end
endmodule