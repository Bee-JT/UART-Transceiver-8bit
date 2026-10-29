module multi_baud_gen (
    input wire clk,          // 27 MHz system clock
    input wire rst,
    input wire [1:0] sel,    // 2-bit selector switch
    output reg baud_tick     // 1 clock cycle pulse at the target baud rate
);

    reg [15:0] counter;
    reg [15:0] threshold;

    // The Hardware Multiplexer: Routes the correct limit based on 'sel'
    always @(*) begin
        case (sel)
            2'b00: threshold = 16'd2812; // 9600 bps
            2'b01: threshold = 16'd1406; // 19200 bps
            2'b10: threshold = 16'd234;  // 115200 bps
            2'b11: threshold = 16'd2812; // Default fallback (9600 bps)
        endcase
    end

    // The Physical Counter: Ticks when it hits the selected threshold
    always @(posedge clk) begin
        if (rst) begin
            counter <= 16'd0;
            baud_tick <= 1'b0;
        end else begin
            if (counter >= (threshold - 16'd1)) begin
                counter <= 16'd0;
                baud_tick <= 1'b1;       // Fire the pulse
            end else begin
                counter <= counter + 16'd1;
                baud_tick <= 1'b0;       // Keep the line quiet
            end
        end
    end

endmodule