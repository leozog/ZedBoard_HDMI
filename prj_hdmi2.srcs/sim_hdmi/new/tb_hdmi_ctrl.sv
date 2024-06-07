`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.06.2024 19:38:49
// Design Name: 
// Module Name: tb_hdmi_ctrl
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


module tb_hdmi_ctrl(

    );

    reg clk, rst;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #50 rst = 0;
    end

    reg start;
    wire interupt;
    
    initial begin
        start = 0;
        #100 start = 1;
        #10000 start = 0;
    end

    wire i2c_scl, i2c_sda;
    pullup(i2c_scl);
    pullup(i2c_sda);

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

    hdmi_ctrl #(.I2C_CLK_DIV(2))
        hdmi_ctrl_inst 
        (
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
        .start(start && clk_wiz_0_locked)
        );

    always @(hdmi_ctrl_inst.i2c_stream_inst.st == 18)
        if (interupt)
            #1 force interupt = 0;
        else
            #1 release interupt;

    always @(hdmi_ctrl_inst.i2c_stream_inst.i2c_base_inst.i2c_bus_inst.st)
        if (hdmi_ctrl_inst.i2c_stream_inst.i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::READ_ACK)
            #1 force i2c_sda = 0;
        else if (hdmi_ctrl_inst.i2c_stream_inst.i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::READ_DATA)
            #1 force i2c_sda = 1;
        else
            #1 release i2c_sda;
endmodule
