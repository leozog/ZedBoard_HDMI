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
    input start,
    output [7:0] LD,
    output HD_CLK,
    output HD_DE,
    output HD_HSYNC,
    output HD_VSYNC,
    input HD_INT
    );

    i2c_stream #(.CMD_FILE("i2c_cmd.mem"), .CMD_SIZE(256))
        i2c_stream_inst
        (
        .clk(clk),
        .rst(rst),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .start(start),
        .interupt(HD_INT),
        .fin(),
        .acc_out(LD)
        );

    assign HD_CLK = 1'b0;
    assign HD_DE = 1'b0;
    assign HD_HSYNC = 1'b0;
    assign HD_VSYNC = 1'b0;


endmodule
