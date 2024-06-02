`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.05.2024 14:51:28
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input rst,
    inout i2c_scl,
    inout i2c_sda,
    input start
    );

    i2c_stream #(.CMD_FILE("i2c_cmd.mem"), .CMD_SIZE(64), .DEV_ADR(8'h72), .CLK_DIV(2))
        i2c_stream_inst
        (
        .clk(clk),
        .rst(rst),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .start(start),
        .fin()
        );

endmodule
