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

    int data_x, data_y;
    reg [7:0] data_r, data_g, data_b;
    wire data_we;
    hdmi_ctrl hdmi_ctrl_inst (
        .clk_100MHz(clk_100MHz),
        .clk_150MHz(clk_150MHz),
        .rst(rst),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .HD_CLK(HD_CLK),
        .HD_D(HD_D),
        .HD_DE(HD_DE),
        .HD_HSYNC(HD_HSYNC),
        .HD_VSYNC(HD_VSYNC),
        .HD_INT(HD_INT),
        .start(clk_wiz_0_locked),
        // data
        .data_we(data_we),
        .data_pos_x(data_x),
        .data_pos_y(data_y),
        .data_r(data_r),
        .data_g(data_g),
        .data_b(data_b)
        );

    assign LD = hdmi_ctrl_inst.i2c_stream_inst.acc;

    assign data_we = 1;

    int x, y;
    always @(posedge clk_100MHz, posedge rst)
        if (rst)
            x <= 0;
        else if (x == 479)
            x <= 0;
        else
            x <= x + 1;
    
    always @(posedge clk_100MHz, posedge rst)
        if (rst)
            y <= 0;
        else if (y == 269 && x == 479)
            y <= 0;
        else if (x == 479)
            y <= y + 1;
    
    always @(posedge clk_100MHz) begin
        data_x <= x;
        data_y <= y;
        data_r <= x<<2;
        data_g <= y<<2;
        data_b <= 0;
    end

endmodule
