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


module top
    (
    input clk,
    input rst,
    inout i2c_scl,
    inout i2c_sda,
    output HD_CLK,
    output [15:0] HD_D,
    output HD_DE,
    output HD_HSYNC,
    output HD_VSYNC,
    input HD_INT,
    input start,
    output [7:0] LD
    );

    hdmi_ctrl hdmi_ctrl_inst (
        .clk(clk),
        .rst(rst),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .HD_CLK(HD_CLK),
        .HD_D(HD_D),
        .HD_DE(HD_DE),
        .HD_HSYNC(HD_HSYNC),
        .HD_VSYNC(HD_VSYNC),
        .HD_INT(HD_INT),
        .start(start)
        );

    assign LD = hdmi_ctrl_inst.i2c_stream_inst.acc;

endmodule
