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
    input clk_100MHz,
    input clk_150MHz,
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
    input data_we,
    input int data_pos_x,
    input int data_pos_y,
    input [7:0] data_r,
    input [7:0] data_g,
    input [7:0] data_b
    );

    wire i2c_stream_fin;
    i2c_stream #(.CMD_FILE("i2c_cmd.mem"), .CMD_SIZE(256), .CLK_DIV(I2C_CLK_DIV))
        i2c_stream_inst
        (
        .clk(clk_100MHz),
        .rst(rst),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .start(start),
        .interupt(HD_INT),
        .fin(i2c_stream_fin)
        );

        synchronizer synchronizer_inst1 (
            .clk1(clk_100MHz),
            .clk2(clk_150MHz),
            .in(i2c_stream_fin),
            .out(i2c_stream_fin_sync)
        );

    hdmi_stream #(
        .H_ACTIVE(1920),
        .H_FRONT(88),
        .H_SYNC(44),
        .H_BACK(151),
        .H_POLARITY(1),
        .V_ACTIVE(1080),
        .V_FRONT(4),
        .V_SYNC(5),
        .V_BACK(34),
        .V_POLARITY(1),
        .MEM_WIDTH(480),
        .MEM_HEIGHT(270),
        .MEM_SCALE(4)
    ) hdmi_stream_inst (
        .clk(clk_150MHz),
        .rst(rst),
        .HD_CLK(HD_CLK),
        .HD_D(HD_D),
        .HD_DE(HD_DE),
        .HD_HSYNC(HD_HSYNC),
        .HD_VSYNC(HD_VSYNC),
        .run(i2c_stream_fin_sync),
        // data
        .data_clk(clk_100MHz),
        .data_we(data_we),
        .data_pos_x(data_pos_x),
        .data_pos_y(data_pos_y),
        .data_r(data_r),
        .data_g(data_g),
        .data_b(data_b)
    );
endmodule
