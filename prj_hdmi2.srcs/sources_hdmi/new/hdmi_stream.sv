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
        parameter H_ACTIVE,
        parameter H_FRONT,
        parameter H_SYNC,
        parameter H_BACK,
        parameter H_POLARITY,
        parameter V_ACTIVE,
        parameter V_FRONT,
        parameter V_SYNC,
        parameter V_BACK,
        parameter V_POLARITY,
        parameter MEM_WIDTH,
        parameter MEM_HEIGHT,
        parameter MEM_SCALE
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
    
    assign HD_CLK = run && ~clk;
    
    reg [7:0] D1, D2;
    assign HD_D = {D1, D2};

    reg [15:0] h_cnt;
    reg [15:0] next_h_cnt;
    reg [15:0] v_cnt;
    reg [15:0] next_v_cnt;
    
    assign HD_DE = run && h_cnt < H_ACTIVE && v_cnt < V_ACTIVE;
    assign HD_HSYNC = run && (h_cnt >= H_ACTIVE + H_FRONT && h_cnt < H_ACTIVE + H_FRONT + H_SYNC) ? H_POLARITY : ~H_POLARITY;
    assign HD_VSYNC = run && (v_cnt >= V_ACTIVE + V_FRONT && v_cnt < V_ACTIVE + V_FRONT + V_SYNC) ? V_POLARITY : ~V_POLARITY;

    reg phase;

    always @(posedge clk, posedge rst)
        if (rst)
            phase <= 0;
        else 
            phase <= phase + 1;
    
    always @(posedge clk, posedge rst)
        if (rst)
            h_cnt <= 0;
        else 
            h_cnt <= next_h_cnt;

    always @(posedge clk, posedge rst)
        if (rst)
            v_cnt <= 0;
        else 
            v_cnt <= next_v_cnt;

    always @*
        if (h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
            next_h_cnt = 0;
        else
            next_h_cnt = h_cnt + 1;

    always @*
        if (h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
            if (v_cnt == V_ACTIVE + V_FRONT + V_SYNC + V_BACK - 1) 
                next_v_cnt = 0;
            else 
                next_v_cnt = v_cnt + 1;
        else
            next_v_cnt = v_cnt;
    

    localparam data_size = $clog2((MEM_WIDTH >> 2) * MEM_HEIGHT);
    (* ram_style = "block" *) 
    reg [7:0] R1 [data_size-1:0];
    (* ram_style = "block" *) 
    reg [7:0] G1 [data_size-1:0];
    (* ram_style = "block" *) 
    reg [7:0] B1 [data_size-1:0];
    (* ram_style = "block" *) 
    reg [7:0] R2 [data_size-1:0];
    (* ram_style = "block" *) 
    reg [7:0] G2 [data_size-1:0];
    (* ram_style = "block" *) 
    reg [7:0] B2 [data_size-1:0];

    wire [data_size-1:0] data_pos = (h_cnt >> (MEM_SCALE + 2)) + (v_cnt >> MEM_SCALE) * (H_ACTIVE >> 2);
    
    reg R1_r, G1_r, B1_r, R2_r, G2_r, B2_r;
    always @(posedge clk, posedge rst)
        if (rst) begin
            R1_r <= 0;
            G1_r <= 0;
            B1_r <= 0;
            R2_r <= 0;
            G2_r <= 0;
            B2_r <= 0;
        end
        else begin
            R1_r <= R1[data_pos];
            G1_r <= G1[data_pos];
            B1_r <= B1[data_pos];
            R2_r <= R2[data_pos];
            G2_r <= G2[data_pos];
            B2_r <= B2[data_pos];
        end

    wire [7:0] Y1, Y2, Cb, Cr;
    RGB_to_YCbCr_422 RGB_to_YCbCr_422_inst(
        .R1(R1_r),
        .G1(G1_r),
        .B1(B1_r),
        .R2(R2_r),
        .G2(G2_r),
        .B2(B2_r),
        .Y1(Y1),
        .Y2(Y2),
        .Cb(Cb),
        .Cr(Cr)
    );

    always @*
        case (phase)
            0: begin
                D1 = Y1;
                D2 = Cb;
            end
            1: begin
                D1 = Y2;
                D2 = Cr;
            end
        endcase
    

        
endmodule

