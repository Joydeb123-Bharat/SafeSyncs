`timescale 1ns / 1ps

module uart_tx #(parameter CLK_FREQ=100000000, BAUD_RATE=9600)(
    input clk,
    input start,
    input [7:0] data,
    output reg tx = 1,
    output reg busy = 0
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

reg [15:0] clk_count = 0;
reg [3:0] bit_index = 0;
reg [9:0] tx_shift;

always @(posedge clk) begin
    if (start && !busy) begin
        // Load all 10 bits safely: {Stop Bit, Data, Start Bit}
        tx_shift <= {1'b1, data, 1'b0};
        busy <= 1;
        bit_index <= 0;
        clk_count <= 0;
        tx <= 1'b0; // Send the Start Bit instantly
    end
    else if (busy) begin
        if (clk_count < CLKS_PER_BIT - 1) begin
            clk_count <= clk_count + 1;
        end
        else begin
            clk_count <= 0;
            if (bit_index < 9) begin
                // Move to the next bit in the package
                bit_index <= bit_index + 1;
                tx <= tx_shift[bit_index + 1]; 
            end
            else begin
                // Package finished, release the line
                busy <= 0; 
            end
        end
    end
end
endmodule