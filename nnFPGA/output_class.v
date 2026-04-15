`timescale 1ns / 1ps
module output_class(
    input signed [15:0]
    h2_0, h2_1, h2_2, h2_3,
    h2_4, h2_5,

    output reg signed [15:0]
    h3_0, h3_1, h3_2, h3_3
);

reg signed [15:0] W [0:23];
reg signed [15:0] B [0:3];
reg signed [47:0] sum;
integer i;

initial begin
    $readmemh("weights_output_class.mem", W);
    $readmemh("biases_output_class.mem", B);
end

always @(*) begin
    h3_0=0; h3_1=0; h3_2=0; h3_3=0;

    for (i = 0; i < 4; i = i + 1) begin
        sum = 0;
        sum = sum + h2_0 * W[6*i + 0];
        sum = sum + h2_1 * W[6*i + 1];
        sum = sum + h2_2 * W[6*i + 2];
        sum = sum + h2_3 * W[6*i + 3];
        sum = sum + h2_4 * W[6*i + 4];
        sum = sum + h2_5 * W[6*i + 5];

        sum = sum + B[i];
        sum = sum >>> 7;

        case(i)
            0: h3_0 = sum[15:0];
            1: h3_1 = sum[15:0];
            2: h3_2 = sum[15:0];
            3: h3_3 = sum[15:0];
        endcase
    end
end
endmodule