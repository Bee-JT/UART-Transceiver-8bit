// ============================================================
// byte_fifo : 2^AW-deep, 8-bit synchronous FIFO (default 16 bytes)
// rd_data shows the oldest byte whenever 'empty' is 0 (first-word-fall-through).
// Pop it by pulsing rd_en. Writes to a full FIFO are dropped.
// ============================================================
module byte_fifo #(
    parameter AW = 4
)(
    input        clk,
    input        rst,
    input        wr_en,
    input  [7:0] wr_data,
    input        rd_en,
    output [7:0] rd_data,
    output       empty
);
    reg [7:0]  mem [0:(1<<AW)-1];
    reg [AW:0] wr_ptr = 0;
    reg [AW:0] rd_ptr = 0;

    assign empty   = (wr_ptr == rd_ptr);
    wire   full    = (wr_ptr[AW-1:0] == rd_ptr[AW-1:0]) && (wr_ptr[AW] != rd_ptr[AW]);
    assign rd_data = mem[rd_ptr[AW-1:0]];

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr[AW-1:0]] <= wr_data;
                wr_ptr <= wr_ptr + 1'b1;
            end
            if (rd_en && !empty)
                rd_ptr <= rd_ptr + 1'b1;
        end
    end
endmodule
