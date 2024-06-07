`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.06.2024 22:03:03
// Design Name: 
// Module Name: hdmi_stream
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


module hdmi_stream
    #(
        parameter INPUT_CLK,
        parameter PIXEL_CLK,
        parameter H_ACTIVE,
        parameter H_FRONT,
        parameter H_SYNC,
        parameter H_BACK,
        parameter H_POLARITY,
        parameter V_ACTIVE,
        parameter V_FRONT,
        parameter V_SYNC,
        parameter V_BACK,
        parameter V_POLARITY
    )
    (
    input clk,
    input rst,
    output reg HD_CLK,
    output [15:0] HD_D,
    output reg HD_DE,
    output HD_HSYNC,
    output HD_VSYNC,
    input run
    );
    
    wire sclk;
    localparam integer CLK_DIV = INPUT_CLK / PIXEL_CLK;
    clk_div #(.DIV(CLK_DIV)) clk_div_inst(
        .clk(clk),
        .rst(rst),
        .sclk(sclk)
        );
    
    assign HD_CLK = run && ~sclk;
    
    reg [7:0] D1, D2;
    assign HD_D = {D1, D2};

    reg [15:0] h_cnt;
    reg [15:0] v_cnt;
    
    assign HD_DE = run && h_cnt < H_ACTIVE && v_cnt < V_ACTIVE;
    assign HD_HSYNC = run && (h_cnt >= H_ACTIVE + H_FRONT && h_cnt < H_ACTIVE + H_FRONT + H_SYNC) ? H_POLARITY : ~H_POLARITY;
    assign HD_VSYNC = run && (v_cnt >= V_ACTIVE + V_FRONT && v_cnt < V_ACTIVE + V_FRONT + V_SYNC) ? V_POLARITY : ~V_POLARITY;

    reg phase;

    always @(posedge clk, posedge rst)
        if (rst)
            phase <= 0;
        else if (sclk)
            phase <= phase + 1;

    buf(clk_buf, clk);
    always @(posedge clk_buf, posedge rst)
        if (rst) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end
        else if (sclk)
            if (h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
                if (v_cnt == V_ACTIVE + V_FRONT + V_SYNC + V_BACK - 1) begin
                    h_cnt <= 0;
                    v_cnt <= 0;
                end
                else begin
                    h_cnt <= 0;
                    v_cnt <= v_cnt + 1;
                end
            else
                h_cnt <= h_cnt + 1;
    
    assign D1 = 8'hFF;
    assign D2 = 8'hFF;
        
endmodule

