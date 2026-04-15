`timescale 1ns / 1ps

module argmax (
    input signed [15:0] h3_0, h3_1, h3_2, h3_3,
    input [7:0] x4,                  
    output reg [1:0] class_out
);

reg signed [15:0] max_val;

always @(*) begin

    // PRIORITY OVERRIDE
    if (x4 == 8'd255) begin
        class_out = 2'd3;
    end else begin

        // normal argmax
        max_val = h3_0;
        class_out = 2'd0;

        if (h3_1 > max_val) begin
            max_val = h3_1;
            class_out = 2'd1;
        end

        if (h3_2 > max_val) begin
            max_val = h3_2;
            class_out = 2'd2;
        end
    end
end

endmodule