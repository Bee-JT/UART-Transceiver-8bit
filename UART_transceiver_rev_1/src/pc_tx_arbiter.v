// ============================================================
// pc_tx_arbiter : decides what goes to the PC screen next
//
// Priority: (1) pending LF  (2) byte from the other board  (3) local echo.
// CR_TO_CRLF = 1 : after every CR sent to the PC, an LF is inserted so new
//                  lines start at the left edge (terminal Enter must send CR only).
// ============================================================
module pc_tx_arbiter #(
    parameter CR_TO_CRLF = 1
)(
    input        clk,
    input        rst,
    input        pc_busy,

    input        link_empty,
    input  [7:0] link_data,
    output       pop_link,

    input        echo_empty,
    input  [7:0] echo_data,
    output       pop_echo,

    output       start,          // to the PC-side uart_tx
    output [7:0] data_out
);
    reg  pending_lf = 1'b0;
    wire send_lf = pending_lf && !pc_busy;

    assign pop_link = !send_lf && !link_empty && !pc_busy;
    assign pop_echo = !send_lf &&  link_empty && !echo_empty && !pc_busy;
    assign start    = send_lf | pop_link | pop_echo;
    assign data_out = send_lf ? 8'h0A : (pop_link ? link_data : echo_data);

    always @(posedge clk) begin
        if (rst)
            pending_lf <= 1'b0;
        else if (send_lf)
            pending_lf <= 1'b0;
        else if ((CR_TO_CRLF != 0) &&
                 ((pop_link && link_data == 8'h0D) || (pop_echo && echo_data == 8'h0D)))
            pending_lf <= 1'b1;
    end
endmodule
