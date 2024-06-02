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
    #(parameter CMD_FILE = "", parameter CMD_SIZE = 1, parameter DEV_ADR = 8'h72, parameter CLK_DIV = 8192)
    (
    input clk,
    input rst,
    inout i2c_scl,
    inout i2c_sda,
    input start,
    output fin
    );
    
    wire sclk;
    clk_div #(.DIV(CLK_DIV)) clk_div_inst(
        .clk(clk),
        .rst(rst),
        .sclk(sclk)
        );

    reg [7:0] dev_reg, dev_data_write;
    wire [7:0] dev_data_read;
    reg base_write, base_read;
    wire base_idle;
    i2c_base i2c_base_inst(
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .dev_adr(DEV_ADR),
        .dev_reg(dev_reg),
        .dev_data_write(dev_data_write),
        .dev_data_read(dev_data_read),
        .write(base_write),
        .read(base_read),
        .idle(base_idle)
        );
        

    reg [7:0] rom [CMD_SIZE:0];
    initial $readmemh(CMD_FILE, rom);
    reg [$clog2(CMD_SIZE):0] rom_ctr;
    reg rom_nxt;
    reg [7:0] acc;

    typedef enum {
        STOP, 
        IDLE, 
        FETCH_CMD, 
        CONST, 
        OR, 
        AND, 
        WRITE_REG, 
        WRITE_REG_WAIT, 
        WRITE_REG_NEXT,
        READ_REG, 
        READ_REG_WAIT, 
        READ_REG_NEXT
    } state;
    state st, nst;
    assign fin = st == STOP;

    always @(posedge clk, posedge rst)
        if (rst)
            st <= IDLE;
        else
            st <= nst;

    always @*
        case (st)
            STOP: nst = STOP;
            IDLE: nst = start ? FETCH_CMD : IDLE;
            FETCH_CMD: case (rom[rom_ctr])
                8'h00: nst = STOP;
                8'h01: nst = CONST;
                8'h02: nst = OR;
                8'h03: nst = AND;
                8'h04: nst = WRITE_REG;
                8'h05: nst = READ_REG;
                default: nst = STOP;
            endcase
            WRITE_REG: nst = base_idle ? WRITE_REG : WRITE_REG_WAIT;
            WRITE_REG_WAIT: nst = base_idle ? WRITE_REG_NEXT : WRITE_REG_WAIT; 
            WRITE_REG_NEXT: nst = FETCH_CMD;
            READ_REG: nst = base_idle ? READ_REG : READ_REG_WAIT;
            READ_REG_WAIT: nst = base_idle ? READ_REG_NEXT : READ_REG_WAIT;
            READ_REG_NEXT: nst = FETCH_CMD;
            default: nst = FETCH_CMD;
        endcase
        
    always @(posedge clk, posedge rst)
        if (rst)
            rom_ctr <= 0;
        else 
            rom_ctr <= rom_ctr + rom_nxt;
        
    always @*
        case (st) 
            FETCH_CMD: rom_nxt = 1;
            CONST: rom_nxt = 1;
            OR: rom_nxt = 1;
            AND: rom_nxt = 1;
            WRITE_REG_NEXT: rom_nxt = 1;
            READ_REG_NEXT: rom_nxt = 1;
            default: rom_nxt = 0;
        endcase
        
        
    always @(posedge clk, posedge rst)
        if (rst) 
            acc <= 0;
        else if (st == CONST)
            acc <= rom[rom_ctr];
        else if (st == OR)
            acc <= acc | rom[rom_ctr];
        else if (st == AND)
            acc <= acc & rom[rom_ctr];
        else if (st == WRITE_REG)
            dev_data_write <= acc;
        else if (st == READ_REG_NEXT && base_idle)
            acc <= dev_data_read;

    always @*
        if (st == READ_REG) begin
            dev_reg = rom[rom_ctr];
            base_read = 1;
        end
        else if (st == WRITE_REG) begin
            dev_reg = rom[rom_ctr];
            base_write = 1;
        end
        else begin
            base_read = 0;
            base_write = 0;
        end
endmodule
