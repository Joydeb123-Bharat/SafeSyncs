`timescale 1ns / 1ps
module layer2 (
    input signed [15:0]
    h1_0, h1_1, h1_2, h1_3,
    h1_4, h1_5, h1_6, h1_7,
    h1_8, h1_9, h1_10, h1_11,

    output reg signed [15:0]
    h2_0, h2_1, h2_2, h2_3,
    h2_4, h2_5
);

reg signed [15:0] W [0:71];
reg signed [15:0] B [0:5];
reg signed [47:0] sum;
integer i;

initial begin
    $readmemh("weights_hidden2.mem", W);
    $readmemh("biases_hidden_2.mem", B);
end

always @(*) begin
    h2_0=0; h2_1=0; h2_2=0;
    h2_3=0; h2_4=0; h2_5=0;

    for (i = 0; i < 6; i = i + 1) begin
        sum = 0;
        sum = sum + h1_0  * W[12*i + 0];
        sum = sum + h1_1  * W[12*i + 1];
        sum = sum + h1_2  * W[12*i + 2];
        sum = sum + h1_3  * W[12*i + 3];
        sum = sum + h1_4  * W[12*i + 4];
        sum = sum + h1_5  * W[12*i + 5];
        sum = sum + h1_6  * W[12*i + 6];
        sum = sum + h1_7  * W[12*i + 7];
        sum = sum + h1_8  * W[12*i + 8];
        sum = sum + h1_9  * W[12*i + 9];
        sum = sum + h1_10 * W[12*i + 10];
        sum = sum + h1_11 * W[12*i + 11];

        sum = sum + B[i];
        sum = sum >>> 7;

        case(i)
            0: h2_0 = (sum < 0) ? 0 : sum[15:0];
            1: h2_1 = (sum < 0) ? 0 : sum[15:0];
            2: h2_2 = (sum < 0) ? 0 : sum[15:0];
            3: h2_3 = (sum < 0) ? 0 : sum[15:0];
            4: h2_4 = (sum < 0) ? 0 : sum[15:0];
            5: h2_5 = (sum < 0) ? 0 : sum[15:0];
        endcase
    end
end
endmodule