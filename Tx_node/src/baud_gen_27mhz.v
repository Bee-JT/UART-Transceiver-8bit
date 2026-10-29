module baud_gen_27mhz (
    input clk, // 27 MHz Tang Nano Clock
    input rst,
    output reg baud_tick
);
    // 27,000,000 Hz / 9600 baud = 2812.5 (rounded to 2812)
    reg [15:0] counter;
    always @(posedge clk) begin 
        if (rst) begin
            counter <= 0;
            baud_tick <= 0;
        end else if (counter == 2812 - 1) begin 
            counter <= 0;
            baud_tick <= 1;
        end else begin
            counter <= counter + 1;
            baud_tick <= 0;
        end
    end 
endmodule