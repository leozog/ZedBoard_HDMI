`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2024 23:08:49
// Design Name: 
// Module Name: tb_i2c_stream
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


module tb_i2c_stream(

    );

    reg clk, rst;

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    initial begin
        rst = 1;
        #10 rst = 0;
    end

    reg start;
    wire idle;
    wire i2c_scl, i2c_sda;
    pullup(i2c_scl);
    pullup(i2c_sda);
    i2c_stream #(.CMD_FILE("i2c_cmd.mem"), .CMD_SIZE(16), .DEV_ADR(8'h72), .CLK_DIV(2))
        i2c_stream_inst
        (
        .clk(clk),
        .rst(rst),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .start(start),
        .fin(fin)
        );

    initial begin
        start = 0;
        #10 start = 1;
        #100 start = 0;
    end


    always @(i2c_stream_inst.i2c_base_inst.i2c_bus_inst.st)
        if (i2c_stream_inst.i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::READ_ACK)
            #1 force i2c_sda = 0;
        else if (i2c_stream_inst.i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::READ_DATA)
            #1 force i2c_sda = 0;
        else
            #1 release i2c_sda;

endmodule
