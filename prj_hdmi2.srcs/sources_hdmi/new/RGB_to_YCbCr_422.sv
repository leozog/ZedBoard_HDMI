`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.06.2024 19:35:08
// Design Name: 
// Module Name: RGB_to_YCbCr_422
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RGB_to_YCbCr_422(
    input [7:0] R1,
    input [7:0] G1,
    input [7:0] B1,
    input [7:0] R2,
    input [7:0] G2,
    input [7:0] B2,
    output [7:0] Y1,
    output [7:0] Y2,
    output [7:0] Cb,
    output [7:0] Cr
);
    wire signed [15:0] Y1_temp;
    wire signed [15:0] Y2_temp;
    wire signed [15:0] Cb_temp1;
    wire signed [15:0] Cr_temp1;
    wire signed [15:0] Cb_temp2;
    wire signed [15:0] Cr_temp2;

    // Y1 
    assign Y1_temp = ( (66 * R1) + (129 * G1) + (25 * B1) ) >> 8;
    assign Y1 = Y1_temp + 16;

    // Y2 
    assign Y2_temp = ( (66 * R2) + (129 * G2) + (25 * B2) ) >> 8;
    assign Y2 = Y2_temp + 16;

    // Cb and Cr 
    assign Cb_temp1 = ( (-38 * R1) - (74 * G1) + (112 * B1) ) >> 8 + 128;
    assign Cr_temp1 = ( (112 * R1) - (94 * G1) - (18 * B1) ) >> 8 + 128;
    
    assign Cb_temp2 = ( (-38 * R2) - (74 * G2) + (112 * B2) ) >> 8 + 128;
    assign Cr_temp2 = ( (112 * R2) - (94 * G2) - (18 * B2) ) >> 8 + 128;

    // Average Cb and Cr 
    assign Cb = ((Cb_temp1 + Cb_temp2) >> 1) + 128;
    assign Cr = ((Cr_temp1 + Cr_temp2) >> 1) + 128;

endmodule