module uart_tx(
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

    // Instantiate the Datapath
    piso #(.WIDTH(10)) piso_inst (
        .clk(clk),
        .rst(rst),
        .load(load_piso),
        .shift(shift_piso),
        .parallel_in({1'b1, data_in, 1'b0}), // [Stop Bit, Data, Start Bit]
        .serial_out(tx_out)
    );

    // Control Logic Wires
    assign load_piso = (start && !busy);
    assign shift_piso = (baud_tick && busy);

    // State Counter
    always @(posedge clk) begin
        if (rst) begin
            busy <= 0;
            bit_shifts <= 0;
        end else begin
            if (start && !busy) begin
                busy <= 1;
                bit_shifts <= 10;
            end else if (baud_tick && busy) begin
                if (bit_shifts == 1) begin
                    busy <= 0;
                end else begin
                    bit_shifts <= bit_shifts - 1;
                end
            end
        end
    end
endmodule