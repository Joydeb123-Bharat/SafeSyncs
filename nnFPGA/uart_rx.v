`timescale 1ns / 1ps

module uart_rx #(
    parameter CLK_FREQ = 100000000,
    parameter BAUD_RATE = 9600
)(
    input clk,
    input rx,
    output reg [7:0] data = 0,
    output reg valid = 0
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

reg [15:0] clk_count = 0;
reg [3:0] bit_index = 0;
reg [7:0] rx_shift = 0;
reg rx_d1 = 1;
reg rx_d2 = 1;
reg receiving = 0;

always @(posedge clk) begin
    // Double flip-flop to prevent metastability
    rx_d1 <= rx;
    rx_d2 <= rx_d1;
    valid <= 0;

    // Detect the falling edge of the Start Bit
    if (!receiving && rx_d2 == 0) begin
        receiving <= 1;
        clk_count <= CLKS_PER_BIT / 2; // Offset to sample in the exact middle of the bit
        bit_index <= 0;
    end
    else if (receiving) begin
        if (clk_count < CLKS_PER_BIT - 1) begin
            clk_count <= clk_count + 1;
        end
        else begin
            clk_count <= 0;
            
            // 🔴 THE FIX: Properly sort the bits!
            if (bit_index == 0) begin
                // We are at the Start Bit. Skip it and move to Data Bit 0.
                bit_index <= 1;
            end
            else if (bit_index <= 8) begin
                // We are at Data Bits (0 to 7). Save them!
                rx_shift[bit_index - 1] <= rx_d2;
                bit_index <= bit_index + 1;
            end
            else begin
                // We are at the Stop Bit. Output the pure, clean byte!
                data <= rx_shift;
                valid <= 1;
                receiving <= 0;
            end
        end
    end
end
endmodule