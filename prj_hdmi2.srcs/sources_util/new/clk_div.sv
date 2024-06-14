`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2024 06:39:02
// Design Name: 
// Module Name: clk_div
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


module clk_div
    #(parameter DIV = 1)
    (
    input clk,
    input rst,
    output sclk
    );

    reg [$clog2(DIV)-1:0] cnt;

    assign sclk = DIV == 1 ? clk : cnt == DIV-1;

    always @(posedge clk, posedge rst)
        if (rst)
            cnt <= 0;
        else if (cnt == DIV-1)
            cnt <= 0;
        else
            cnt <= cnt + 1;
endmodule
