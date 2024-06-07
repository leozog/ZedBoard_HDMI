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

    wire clk_100MHz;
    wire clk_150MHz;
    wire clk_wiz_0_locked;
    clk_wiz_0 clk_wiz_0_inst
    (
        // Clock out ports
        .clk_100MHz(clk_100MHz),      // output clk_100MHz
        .clk_150MHz(clk_150MHz),      // output clk_150MHz
        // Status and control signals
        .reset(rst),                  // input reset
        .locked(clk_wiz_0_locked),    // output locked
        // Clock in ports
        .clk_in1(clk)                 // input clk_in1
    );

    wire i2c_stream_fin;
    i2c_stream #(.CMD_FILE("i2c_cmd.mem"), .CMD_SIZE(256), .CLK_DIV(I2C_CLK_DIV))
        i2c_stream_inst
        (
        .clk(clk_100MHz),
        .rst(rst),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .start(start && clk_wiz_0_locked),
        .interupt(HD_INT),
        .fin(i2c_stream_fin)
        );

    wire i2c_stream_fin_buf;
    BUFG BUFG_inst_fin (
        .I(i2c_stream_fin),
        .O(i2c_stream_fin_buf)
        );
        
    hdmi_stream #(
        .INPUT_CLK(150_000_000),
        .PIXEL_CLK(148_500_000),
        .H_ACTIVE(1920),
        .H_FRONT(88),
        .H_SYNC(44),
        .H_BACK(148),
        .H_POLARITY(1),
        .V_ACTIVE(1080),
        .V_FRONT(4),
        .V_SYNC(5),
        .V_BACK(36),
        .V_POLARITY(1)
    ) hdmi_stream_inst (
        .clk(clk_150MHz),
        .rst(rst),
        .HD_CLK(HD_CLK),
        .HD_D(HD_D),
        .HD_DE(HD_DE),
        .HD_HSYNC(HD_HSYNC),
        .HD_VSYNC(HD_VSYNC),
        .run(i2c_stream_fin_buf && clk_wiz_0_locked)
    );
     
endmodule
