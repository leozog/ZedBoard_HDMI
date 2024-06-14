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
        parameter H_ACTIVE = 0,
        parameter H_FRONT = 0,
        parameter H_SYNC = 0,
        parameter H_BACK = 0,
        parameter H_POLARITY = 0,
        parameter V_ACTIVE = 0,
        parameter V_FRONT = 0,
        parameter V_SYNC = 0,
        parameter V_BACK = 0,
        parameter V_POLARITY = 0,
        parameter MEM_WIDTH = 0,
        parameter MEM_HEIGHT = 0,
        parameter MEM_SCALE = 0
    )
    (
    input clk,
    input rst,
    output HD_CLK,
    output reg [15:0] HD_D,
    output reg HD_DE,
    output reg HD_HSYNC,
    output reg HD_VSYNC,
    input run,
    input data_clk,
    input data_we,
    input int data_pos_x,
    input int data_pos_y,
    input [7:0] data_r,
    input [7:0] data_g,
    input [7:0] data_b
    );

    reg HD_CLK_p, HD_CLK_n; 
    assign HD_CLK = HD_CLK_p == HD_CLK_n; // to triger on both edges
    always @(posedge clk, posedge rst)
        if (rst)
            HD_CLK_p <= 0;
        else
            HD_CLK_p <= ~HD_CLK_p;
    always @(negedge clk, posedge rst)
        if (rst)
            HD_CLK_n <= 0;
        else
            HD_CLK_n <= ~HD_CLK_n;

    
    reg [7:0] D1, D2;
    reg [15:0] h_cnt;
    reg [15:0] v_cnt;

    always @(posedge clk) begin
        HD_D <= {D1, D2};
        HD_DE <= run && h_cnt < H_ACTIVE && v_cnt < V_ACTIVE;
        HD_HSYNC <= run && (h_cnt >= H_ACTIVE + H_FRONT && h_cnt < H_ACTIVE + H_FRONT + H_SYNC) ? H_POLARITY : ~H_POLARITY;
        HD_VSYNC <= run && (v_cnt >= V_ACTIVE + V_FRONT && v_cnt < V_ACTIVE + V_FRONT + V_SYNC) ? V_POLARITY : ~V_POLARITY;
    end

    reg phase;

    always @(posedge clk, posedge rst)
        if (rst)
            phase <= 0;
        else if (h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
            phase <= 0;
        else 
            phase <= phase + 1;
    
    always @(posedge clk, posedge rst)
        if (rst)
            h_cnt <= 0;
        else if (h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
            h_cnt <= 0;
        else
            h_cnt <= h_cnt + 1;

    always @(posedge clk, posedge rst)
        if (rst)
            v_cnt <= 0;
        else if (h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
            if (v_cnt == V_ACTIVE + V_FRONT + V_SYNC + V_BACK - 1) 
                v_cnt <= 0;
            else 
                v_cnt <= v_cnt + 1;

    localparam MEM_SIZE = MEM_WIDTH * MEM_HEIGHT;
    
    reg [$clog2(MEM_WIDTH):0] hm_cnt;
    reg [$clog2(MEM_SCALE)-1:0] hm_cnt_incr;
    reg [$clog2(MEM_HEIGHT):0] vm_cnt;
    reg [$clog2(MEM_SCALE)-1:0] vm_cnt_incr;

    always @(posedge clk, posedge rst)
        if (rst)
            hm_cnt <= 0;
        else if (h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
            hm_cnt <= 0;
        else if (hm_cnt_incr == MEM_SCALE - 1)
            hm_cnt <= hm_cnt + 1;
    
    always @(posedge clk, posedge rst)
        if (rst)
            hm_cnt_incr <= 0;
        else if (h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
            hm_cnt_incr <= 0;
        else if (hm_cnt_incr == MEM_SCALE - 1)
            hm_cnt_incr <= 0;
        else
            hm_cnt_incr <= hm_cnt_incr + 1;

    always @(posedge clk, posedge rst)
        if (rst)
            vm_cnt <= 0;
        else if (v_cnt == V_ACTIVE + V_FRONT + V_SYNC + V_BACK - 1 && h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
            vm_cnt <= 0;
        else if (vm_cnt_incr == MEM_SCALE - 1 && h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
            vm_cnt <= vm_cnt + 1;

    always @(posedge clk, posedge rst)
        if (rst)
            vm_cnt_incr <= 0;
        else if (v_cnt == V_ACTIVE + V_FRONT + V_SYNC + V_BACK - 1)
            vm_cnt_incr <= 0;
        else if (vm_cnt_incr == MEM_SCALE - 1 && h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
            vm_cnt_incr <= 0;
        else if (h_cnt == H_ACTIVE + H_FRONT + H_SYNC + H_BACK - 1)
            vm_cnt_incr <= vm_cnt_incr + 1;

    reg [$clog2(MEM_SIZE)-1:0] data_pos_out;
    always @(posedge clk)
        data_pos_out <= hm_cnt + vm_cnt * MEM_WIDTH;


    wire [7:0] Y_q, Cb_q, Cr_q;
    reg [7:0] Y_in, Cb_in, Cr_in;
    RGB_to_YCbCr RGB_to_YCbCr_inst (
        .R1(data_r),
        .G1(data_g),
        .B1(data_b),
        .Y(Y_q),
        .Cb(Cb_q),
        .Cr(Cr_q)
    );

    reg [$clog2(MEM_SIZE)-1:0] data_pos_in;
    always @(posedge data_clk) begin
        data_pos_in <= data_pos_x + data_pos_y * MEM_WIDTH;
        Y_in <= Y_q;
        Cb_in <= Cb_q;
        Cr_in <= Cr_q;
    end

    wire [7:0] Y_out, Cb_out, Cr_out;
    vram vram_inst (
        .clka(clk),    // input wire clka
        .ena(1),      // input wire ena
        .wea(0),      // input wire [0 : 0] wea
        .addra(data_pos_out),  // input wire [16 : 0] addra
        .dina(24'b0),    // input wire [23 : 0] dina
        .douta({Y_out, Cb_out, Cr_out}),  // output wire [23 : 0] douta
        .clkb(data_clk),    // input wire clkb
        .enb(1),      // input wire enb
        .web(data_we),      // input wire [0 : 0] web
        .addrb(data_pos_in),  // input wire [16 : 0] addrb
        .dinb({Y_in, Cb_in, Cr_in}),    // input wire [23 : 0] dinb
        .doutb()  // output wire [23 : 0] doutb
    );
    
    always @*
        case (phase)
            0: begin
                D1 = Y_out;
                D2 = Cb_out;
            end
            1: begin
                D1 = Y_out;
                D2 = Cr_out;
            end
        endcase;
endmodule