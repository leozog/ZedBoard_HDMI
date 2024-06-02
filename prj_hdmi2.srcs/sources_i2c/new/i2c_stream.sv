`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2024 09:12:25
// Design Name: 
// Module Name: i2c_stream
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


module i2c_stream
    #(parameter N_CMD, DEV_ADR = 8'h72)
    (
    input clk,
    input rst,
    inout i2c_scl,
    inout i2c_sda,
    input start,
    output fin
    );
    
    wire sclk;
    clk_div #(.DIV(8192)) clk_div_inst(
        .clk(clk),
        .rst(rst),
        .sclk(sclk)
        );

    reg [7:0] dev_adr, dev_reg, dev_data_write;
    wire [7:0] dev_data_read;
    assign dev_adr = DEV_ADR;

    reg start;
    wire idle;
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
        
    reg [7:0] rom [N_CMD:0];
    reg [$clog2(N_CMD):0] rom_ctr;

    typedef enum {IDLE, READ_CMD, READ_REG, READ_VAL, READ_MASK, , FIN} state;
    state st, nst;
    assign fin = st == FIN;

    always @(posedge clk, posedge rst)
        if (rst)
            st <= IDLE;
        else
            st <= nst;

    always @*
        case (st)
            IDLE:
                nst = start ? WRITE_REG : IDLE;
            WRITE_REG:
                nst = WRITE_DATA;
            WRITE_DATA:
                nst = WRITE_START;
            WRITE_START:
                nst = base_idle ? WRITE_START : WAIT;
            WAIT:
                nst = base_idle ? FIN : WAIT;
            FIN:
                nst = FIN;
            default:
                nst = IDLE;
        endcase
        
    always @(posedge clk, posedge rst)
        if (rst)
            rom_ctr <= 0;
        else if (st == WRITE_REG || st == WRITE_DATA)
            rom_ctr <= rom_ctr + 1;
            
    always @(posedge clk, posedge rst)
        if (rst) begin
            dev_reg <= 8'hFF;
            dev_data_write <= 8'hFF;
        end
        else if (st == WRITE_REG) 
            dev_reg <= rom[rom_ctr];
        else if (st == WRITE_DATA)
            dev_data_write <= rom[rom_ctr];
endmodule
