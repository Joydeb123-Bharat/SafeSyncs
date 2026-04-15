`timescale 1ns / 1ps
module nn_top_unified (
    input clk,
    input rst,
    input uart_rx,      
    output uart_tx,     
    output reg [1:0] class_out_led 
);
// =====================================================
// 1. CLOCK & UART CONFIGURATION (LOCKED AT 9600)
// =====================================================
parameter CLK_FREQ = 100000000;  
parameter BAUD_RATE = 9600;    

wire [7:0] rx_data;
wire rx_valid, tx_busy;

uart_rx #(CLK_FREQ, BAUD_RATE) RX (
    .clk(clk), .rx(uart_rx), .data(rx_data), .valid(rx_valid)
);

reg [7:0] tx_data;
reg tx_start;
uart_tx #(CLK_FREQ, BAUD_RATE) TX (
    .clk(clk), .start(tx_start), .data(tx_data), .tx(uart_tx), .busy(tx_busy)
);

// =====================================================
// 2. DECLARE THE CLASS WIRE FIRST! (Fixes the Warning)
// =====================================================
wire [1:0] class_wire; 

// =====================================================
// 3. ASCII PARSER & BUFFER
// =====================================================
reg [7:0] x0, x1, x2, x3, x4;
reg [15:0] current_val = 0;
reg [2:0] val_idx = 0;
reg is_sensor_packet = 0;

reg waiting_for_nn = 0;
reg [3:0] wait_cycles = 0;
reg sending_msg = 0;
reg [7:0] msg_buf [0:6];
reg [2:0] msg_len = 0;
reg [2:0] msg_idx = 0;

reg [7:0] pass_buf;
reg pass_ready = 0;

always @(posedge clk) begin
    tx_start <= 0;

    // --- RECEIVE LOGIC ---
    if (rx_valid) begin
        if (rx_data == "S") begin
            is_sensor_packet <= 1;
            val_idx <= 0;
            current_val <= 0;
        end 
        else if (rx_data == "R") begin
            is_sensor_packet <= 0;
        end
        else if (rx_data >= "0" && rx_data <= "9") begin
            current_val <= (current_val * 10) + (rx_data - "0");
        end
        else if (rx_data == ",") begin
            val_idx <= val_idx + 1;
            if (val_idx == 1) x0 <= current_val[7:0]; 
            if (val_idx == 2) x1 <= current_val[7:0];
            if (val_idx == 3) x2 <= current_val[7:0];
            if (val_idx == 4) x3 <= current_val[7:0];
            current_val <= 0;
        end
        else if (rx_data == "\n" && is_sensor_packet) begin
            x4 <= current_val[7:0]; 
            waiting_for_nn <= 1;
            wait_cycles <= 0;
        end

        // Buffer the character
        if (rx_data != "\n") begin
            pass_buf <= rx_data;
            pass_ready <= 1;
        end else if (!is_sensor_packet) begin
            pass_buf <= "\n"; 
            pass_ready <= 1;
        end
    end

    // --- PIPELINE DELAY LOGIC ---
    if (waiting_for_nn) begin
        if (wait_cycles < 5) begin
            wait_cycles <= wait_cycles + 1;
        end else begin
            waiting_for_nn <= 0;
            sending_msg <= 1;
            msg_idx <= 0;
            msg_buf[0] <= ","; 
            
            // Now reading the properly declared class_wire!
            if (class_wire == 0) begin
                msg_buf[1]<="S"; msg_buf[2]<="A"; msg_buf[3]<="F"; msg_buf[4]<="E"; msg_buf[5]<="\n"; msg_len <= 6;
            end else if (class_wire == 1) begin
                msg_buf[1]<="W"; msg_buf[2]<="A"; msg_buf[3]<="R"; msg_buf[4]<="N"; msg_buf[5]<="\n"; msg_len <= 6;
            end else begin
                msg_buf[1]<="F"; msg_buf[2]<="I"; msg_buf[3]<="R"; msg_buf[4]<="E"; msg_buf[5]<="\n"; msg_len <= 6;
            end
        end
    end

    // --- TRANSMIT LOGIC ---
    else if (sending_msg && !tx_busy && !tx_start) begin
         tx_data <= msg_buf[msg_idx];
         tx_start <= 1;
         msg_idx <= msg_idx + 1;
         if (msg_idx == msg_len - 1) begin
             sending_msg <= 0;
         end
    end
    else if (pass_ready && !tx_busy && !tx_start && !sending_msg) begin
         tx_data <= pass_buf;
         tx_start <= 1;
         pass_ready <= 0;
    end
end

// =====================================================
// 4. THE PIPELINED NEURAL NETWORK 
// =====================================================
wire signed [15:0] h1_0,h1_1,h1_2,h1_3,h1_4,h1_5,h1_6,h1_7,h1_8,h1_9,h1_10,h1_11;
layer1 L1 (x0,x1,x2,x3,x4, h1_0,h1_1,h1_2,h1_3,h1_4,h1_5,h1_6,h1_7,h1_8,h1_9,h1_10,h1_11);

reg signed [15:0] h1r [0:11];
always @(posedge clk) begin
    h1r[0]<=h1_0; h1r[1]<=h1_1; h1r[2]<=h1_2; h1r[3]<=h1_3;
    h1r[4]<=h1_4; h1r[5]<=h1_5; h1r[6]<=h1_6; h1r[7]<=h1_7;
    h1r[8]<=h1_8; h1r[9]<=h1_9; h1r[10]<=h1_10; h1r[11]<=h1_11;
end

wire signed [15:0] h2_0,h2_1,h2_2,h2_3,h2_4,h2_5;
layer2 L2 (h1r[0],h1r[1],h1r[2],h1r[3],h1r[4],h1r[5],h1r[6],h1r[7],h1r[8],h1r[9],h1r[10],h1r[11],
           h2_0,h2_1,h2_2,h2_3,h2_4,h2_5);

reg signed [15:0] h2r [0:5];
always @(posedge clk) begin
    h2r[0]<=h2_0; h2r[1]<=h2_1; h2r[2]<=h2_2; h2r[3]<=h2_3; h2r[4]<=h2_4; h2r[5]<=h2_5;
end

wire signed [15:0] h3_0,h3_1,h3_2,h3_3;
output_class OC (h2r[0],h2r[1],h2r[2],h2r[3],h2r[4],h2r[5], h3_0,h3_1,h3_2,h3_3);

// class_wire connects perfectly now because it was declared at the top!
argmax AM (h3_0, h3_1, h3_2, h3_3, x4, class_wire);

always @(posedge clk) begin
    class_out_led <= class_wire;
end

endmodule