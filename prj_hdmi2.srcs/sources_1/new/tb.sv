`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2024 06:38:15
// Design Name: 
// Module Name: tb
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


module tb(

    );

    reg clk, rst, sclk;
    // wire i2c_scl, i2c_sda;
    // i2c_bus_state::state next_cmd;
    // wire idle, error;

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    initial begin
        rst = 1;
        #10 rst = 0;
        #3000 $finish;
    end

    clk_div #(.DIV(4)) clk_div_inst(
        .clk(clk),
        .rst(rst),
        .sclk(sclk)
        );


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
    //     next_cmd = i2c_bus_state::SEND_START;
    //     wait (idle == 0);
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::SEND_ONE;
    //     wait (idle == 0);
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::SEND_ZERO;
    //     wait (idle == 0);
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::SEND_ONE;
    //     wait (idle == 0);
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::RECEIVE_ACK;
    //     force i2c_sda = 0;
    //     wait (idle == 0);
    //     wait (idle == 1);
    //     next_cmd = i2c_bus_state::SEND_STOP;
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

    // i2c_base test
    reg [7:0] dev_adr, dev_reg, dev_data_write;
    assign dev_adr = 8'h72;
    assign dev_reg = 8'h98;
    assign dev_data_write = 8'hCC;
    wire [7:0] dev_data_read;
    reg start;
    wire idle;
    wire i2c_scl, i2c_sda;
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
        .idle(idle)
        );
        
    pullup(i2c_scl);
    pullup(i2c_sda);

    initial begin
        start = 0;
        #10 start = 1;
        wait (i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::RECEIVE_ACK);
        #20 force i2c_sda = 0;
        wait (i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::RECEIVE_ACK_1);
        #25 release i2c_sda;
        wait (i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::RECEIVE_ACK);
        #20 force i2c_sda = 0;
        wait (i2c_base_inst.i2c_bus_inst.st == i2c_bus_state::RECEIVE_ACK_1);
        #25 release i2c_sda;
    end

endmodule
