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


module tb_i2c_base_read(

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
    wire [7:0] dev_data_read;
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
        .dev_data_read(dev_data_read),
        .write(0),
        .read(start),
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

    // bus test
    // i2c_bus i2c_bus_inst(
    //     .clk(clk),
    //     .rst(rst),
    //     .sclk(sclk),
    //     .i2c_scl(i2c_scl),
    //     .i2c_sda(i2c_sda),
    //     .next_cmd(next_cmd),
    //     .idle(idle),
    //     .error(error)
    //     );

    // initial begin
    //     next_cmd = i2c_bus_state::IDLE;
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::WRITE_START;
    //     wait (idle == 0);
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::WRITE_ONE;
    //     wait (idle == 0);
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::WRITE_ZERO;
    //     wait (idle == 0);
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::WRITE_ONE;
    //     wait (idle == 0);
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::READ_ACK;
    //     force i2c_sda = 0;
    //     wait (idle == 0);
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::WRITE_STOP;
    //     release i2c_sda;
    //     wait (idle == 0);
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::IDLE;
    // end

    // bit steam test
    // reg [7:0] data;
    // reg setup, enable;
    // wire finish, out;

    // bit_stream bit_stream_inst(
    //     .clk(clk),
    //     .rst(rst),
    //     .sclk(sclk),
    //     .data(data),
    //     .setup(setup),
    //     .enable(enable),
    //     .finish(finish),
    //     .out(out)
    //     );

    // initial begin
    //     data = 8'hFF;
    //     setup = 1;
    //     enable = 0;
    //     #20 enable = 1;
    //     setup = 0;
    //     wait (finish == 1);
    //     #10 $finish;
    // end
