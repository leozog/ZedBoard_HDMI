`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.06.2024 22:09:21
// Design Name: 
// Module Name: tb_hdmi_stream
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


module tb_hdmi_stream(

    );
    
    reg clk, rst, run;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        run = 0;
        #50 rst = 0;
        #10 run = 1;
    end


    hdmi_stream #(
        .INPUT_CLK(100_000_000),
        .PIXEL_CLK(48_412_000),
        .H_ACTIVE(1280),
        .H_FRONT(440),
        .H_SYNC(40),
        .H_BACK(220),
        .H_POLARITY(1),
        .V_ACTIVE(720),
        .V_FRONT(5),
        .V_SYNC(5),
        .V_BACK(20),
        .V_POLARITY(1)
    ) hdmi_stream_inst (
        .clk(clk),
        .rst(rst),
        .HD_CLK(),
        .HD_D(),
        .HD_DE(),
        .HD_HSYNC(),
        .HD_VSYNC(),
        .run(run),
        .data_clk(),
        .data_we(),
        .data_pos_x(),
        .data_pos_y(),
        .data_r(),
        .data_g(),
        .data_b()
    );

endmodule
