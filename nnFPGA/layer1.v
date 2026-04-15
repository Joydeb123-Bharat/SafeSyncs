`timescale 1ns / 1ps

module layer1 (
    input [7:0] x0, x1, x2, x3, x4,

    output reg signed [15:0]
    h1_0, h1_1, h1_2, h1_3,
    h1_4, h1_5, h1_6, h1_7,
    h1_8, h1_9, h1_10, h1_11
);

reg signed [15:0] W [0:59];
reg signed [15:0] B [0:11];

integer i;
reg signed [47:0] sum;

initial begin
    $readmemh("weights_hidden1.mem", W);
    $readmemh("biases_hidden_1.mem", B);
end

always @(*) begin
    for (i = 0; i < 12; i = i + 1) begin
        sum = 0;
        sum = sum + x0 * W[i*5 + 0];
        sum = sum + x1 * W[i*5 + 1];
        sum = sum + x2 * W[i*5 + 2];
        sum = sum + x3 * W[i*5 + 3];
        sum = sum + x4 * W[i*5 + 4];
        
        sum = sum + B[i];
        sum = sum >>> 7;

        case(i)
            0: h1_0 = (sum < 0) ? 0 : sum[15:0];
            1: h1_1 = (sum < 0) ? 0 : sum[15:0];
            2: h1_2 = (sum < 0) ? 0 : sum[15:0];
            3: h1_3 = (sum < 0) ? 0 : sum[15:0];
            4: h1_4 = (sum < 0) ? 0 : sum[15:0];
            5: h1_5 = (sum < 0) ? 0 : sum[15:0];
            6: h1_6 = (sum < 0) ? 0 : sum[15:0];
            7: h1_7 = (sum < 0) ? 0 : sum[15:0];
            8: h1_8 = (sum < 0) ? 0 : sum[15:0];
            9: h1_9 = (sum < 0) ? 0 : sum[15:0];
            10: h1_10 = (sum < 0) ? 0 : sum[15:0];
            11: h1_11 = (sum < 0) ? 0 : sum[15:0];
        endcase
    end
end
endmodule