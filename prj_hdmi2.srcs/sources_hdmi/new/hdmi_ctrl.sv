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
    input clk_100MHz,
    input clk_150MHz,
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
    input [15:0] data_x,
    input [15:0] data_y,
    input [7:0] data_r,
    input [7:0] data_g,
    input [7:0] data_b,
    input data_save
    );

    wire i2c_stream_fin;
    i2c_stream #(.CMD_FILE("i2c_cmd.mem"), .CMD_SIZE(256), .CLK_DIV(I2C_CLK_DIV))
        i2c_stream_inst
        (
        .clk(clk_100MHz),
        .rst(rst),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .start(start),
        .interupt(HD_INT),
        .fin(i2c_stream_fin)
        );

    wire i2c_stream_fin_buf;
    BUFG BUFG_inst_fin (
        .O(i2c_stream_fin_buf),
        .I(i2c_stream_fin)
        );

    localparam MEM_WIDTH = 256;
    localparam MEM_HEIGHT = 256;
    localparam MEM_SCALE = 4;
    hdmi_stream #(
        .H_ACTIVE(H_ACTIVE),
        .H_FRONT(88),
        .H_SYNC(44),
        .H_BACK(148),
        .H_POLARITY(1),
        .V_ACTIVE(V_ACTIVE),
        .V_FRONT(4),
        .V_SYNC(5),
        .V_BACK(36),
        .V_POLARITY(1),
        .MEM_WIDTH(MEM_WIDTH),
        .MEM_HEIGHT(MEM_HEIGHT),
        .MEM_SCALE(MEM_SCALE)
    ) hdmi_stream_inst (
        .clk(clk_150MHz),
        .rst(rst),
        .HD_CLK(HD_CLK),
        .HD_D(HD_D),
        .HD_DE(HD_DE),
        .HD_HSYNC(HD_HSYNC),
        .HD_VSYNC(HD_VSYNC),
        .run(i2c_stream_fin_buf)
    );
    
    localparam data_size = $clog2((MEM_WIDTH >> 2) * MEM_HEIGHT);
    wire [data_size-1:0] data_pos = (data_x >> 2) + data_y * (H_ACTIVE >> 2);
    always @(posedge clk_100MHz)
        if (data_save)
            if(data_x[0] == 0) begin
                hdmi_stream_inst.R1[data_pos] <= data_r;
                hdmi_stream_inst.G1[data_pos] <= data_g;
                hdmi_stream_inst.B1[data_pos] <= data_b;
            end 
            else begin
                hdmi_stream_inst.R2[data_pos] <= data_r;
                hdmi_stream_inst.G2[data_pos] <= data_g;
                hdmi_stream_inst.B2[data_pos] <= data_b;
            end


endmodule
