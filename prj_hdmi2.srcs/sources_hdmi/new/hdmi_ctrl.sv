`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.06.2024 19:02:20
// Design Name: 
// Module Name: hdmi_ctrl
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


module hdmi_ctrl
    #(
        parameter I2C_CLK_DIV = 8192
    )
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
    input start
    );

    wire i2c_stream_fin;
    i2c_stream #(.CMD_FILE("i2c_cmd.mem"), .CMD_SIZE(256), .CLK_DIV(I2C_CLK_DIV))
        i2c_stream_inst
        (
        .clk(clk),
        .rst(rst),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .start(start),
        .interupt(HD_INT),
        .fin(i2c_stream_fin)
        );
        
    hdmi_stream #(
        .INPUT_CLK(100_000_000),
        .PIXEL_CLK(48_412_000),
        .H_ACTIVE(1280),
        .H_FRONT(440),
        .H_SYNC(40),
        .H_BACK(220),
        .H_POLARITY(1),
        .V_ACTIVE(720),
        .V_FRONT(5),
        .V_SYNC(5),
        .V_BACK(20),
        .V_POLARITY(1)
    ) hdmi_stream_inst (
        .clk(clk),
        .rst(rst),
        .HD_CLK(HD_CLK),
        .HD_D(HD_D),
        .HD_DE(HD_DE),
        .HD_HSYNC(HD_HSYNC),
        .HD_VSYNC(HD_VSYNC),
        .run(i2c_stream_fin)
    );
     
endmodule
