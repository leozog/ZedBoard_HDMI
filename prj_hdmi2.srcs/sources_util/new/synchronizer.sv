`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.06.2024 22:55:05
// Design Name: 
// Module Name: synchronizer
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


module synchronizer #(
    parameter N = 1
    )(
    input clk1,
    input clk2,
    input [N-1:0] in,
    output reg [N-1:0] out
    );

    (* ASYNC_REG = "TRUE" *) 
    reg [N-1:0] sync1;
    (* ASYNC_REG = "TRUE" *) 
    reg [N-1:0] sync2;

    always @(posedge clk1) begin
        sync1 <= in;
    end

    always @(posedge clk2) begin
        sync2 <= sync1;
    end

    always @(posedge clk2) begin
        out <= sync2;
    end
endmodule
