`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.06.2024 19:35:08
// Design Name: 
// Module Name: RGB_to_YCbCr
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


module RGB_to_YCbCr(
    input [7:0] R1,
    input [7:0] G1,
    input [7:0] B1,
    output [7:0] Y,
    output [7:0] Cb,
    output [7:0] Cr
);
    wire signed [15:0] Y_temp;
    wire signed [15:0] Cb_temp;
    wire signed [15:0] Cr_temp;

    assign Y_temp = ( (66 * R1) + (129 * G1) + (25 * B1) ) >> 8;
    assign Y = Y_temp + 16;

    assign Cb_temp = ( (-38 * R1) - (74 * G1) + (112 * B1) ) >> 8;
    assign Cr_temp = ( (112 * R1) - (94 * G1) - (18 * B1) ) >> 8;
    assign Cb = Cb_temp + 128;
    assign Cr = Cr_temp + 128;
endmodule