`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2024 06:38:15
// Design Name: 
// Module Name: tb_i2c_base
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


module tb_i2c_base_write(

    );

    reg clk, rst, sclk;

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    initial begin
        rst = 1;
        #10 rst = 0;
    end

    clk_div #(.DIV(4)) clk_div_inst(
        .clk(clk),
        .rst(rst),
        .sclk(sclk)
        );

    reg [7:0] dev_adr, dev_reg, dev_data_write;
    assign dev_adr = 8'h72;
    assign dev_reg = 8'h98;
    assign dev_data_write = 8'hCC;
    reg start;
    wire idle;
    wire i2c_scl, i2c_sda;
    pullup(i2c_scl);
    pullup(i2c_sda);
        
    i2c_base i2c_base_inst(
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .dev_adr(dev_adr),
        .dev_reg(dev_reg),
        .dev_data_write(dev_data_write),
        .dev_data_read(),
        .write(start),
        .read(0),
        .idle(idle)
        );

    initial begin
        start = 0;
        #10 start = 1;
        #100 start = 0;
    end

    always @(i2c_base_inst.i2c_bus_inst.st)
        if (i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::READ_ACK)
            #10 force i2c_sda = 0;
        else if (i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::READ_DATA)
            #10 force i2c_sda = 0;
        else
            #20 release i2c_sda;
endmodule
