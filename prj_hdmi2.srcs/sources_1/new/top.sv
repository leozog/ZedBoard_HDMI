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
    output [7:0] dev_data_read
    );

    wire sclk;
    clk_div #(.DIV(8192)) clk_div_inst(
        .clk(clk),
        .rst(rst),
        .sclk(sclk)
        );

    reg [7:0] dev_adr, dev_reg, dev_data_write;
    assign dev_adr = 8'h72;
    assign dev_reg = 8'hBB;
    assign dev_data_write = 8'hCC;

    i2c_base i2c_base_inst(
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .dev_adr(dev_adr),
        .dev_reg(dev_reg),
        .dev_data_write(dev_data_write),
        .dev_data_read(dev_data_read),
        .send(0),
        .read(start),
        .idle()
        );

endmodule
