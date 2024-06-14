`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2024 00:06:08
// Design Name: 
// Module Name: tb_top
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


module tb_top(

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

    top top_inst (
        .clk(clk),
        .rst(rst),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .HD_CLK(),
        .HD_D(),
        .HD_DE(),
        .HD_HSYNC(),
        .HD_VSYNC(),
        .HD_INT(),
        .start(start),
        .LD()
    );

    always @(top_inst.hdmi_ctrl_inst.i2c_stream_inst.st == 18)
        if (interupt)
            #1 force interupt = 0;
        else
            #1 release interupt;

    always @(top_inst.hdmi_ctrl_inst.i2c_stream_inst.i2c_base_inst.i2c_bus_inst.st)
        if (top_inst.hdmi_ctrl_inst.i2c_stream_inst.i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::READ_ACK)
            #1 force i2c_sda = 0;
        else if (top_inst.hdmi_ctrl_inst.i2c_stream_inst.i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::READ_DATA)
            #1 force i2c_sda = 1;
        else
            #1 release i2c_sda;
endmodule
