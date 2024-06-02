`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2024 05:45:45
// Design Name: 
// Module Name: i2c_bus
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


package i2c_bus_state;
    typedef enum { IDLE, WRITE_START, WRITE_STOP, WRITE_ZERO, WRITE_ONE, READ_DATA, READ_ACK, WRITE_NACK, WAIT, ERROR} state;
endpackage

module i2c_bus(
    input clk,
    input rst,
    input sclk,
    inout i2c_scl,
    inout i2c_sda,
    input i2c_bus_state::state next_cmd,
    output idle,
    output error,
    output reg data_read
    );
    
    reg force_scl, force_sda;
    assign i2c_scl = force_scl ? 1'bz : 1'b0;
    assign i2c_sda = force_sda ? 1'bz : 1'b0;

    reg [1:0] phase;
    i2c_bus_state::state st, nst, lst;
    assign idle = sclk && phase == 1;
    assign error = st == i2c_bus_state::ERROR;

    always @(posedge clk, posedge rst)
        if (rst)
            phase <= 0;
        else if (sclk)
            phase <= phase + 1'b1;

    always @(posedge clk, posedge rst)
        if (rst) begin
            lst <= i2c_bus_state::IDLE;
            st <= i2c_bus_state::IDLE;
        end
        else if (sclk && phase == 3) begin
            lst <= st;
            st <= nst;
        end

    always @*
        case (st)
            i2c_bus_state::READ_ACK:
                nst = i2c_sda == 0 ? (i2c_scl == 1 ? next_cmd : i2c_bus_state::WAIT) : i2c_bus_state::ERROR;
            i2c_bus_state::WAIT:
                nst = i2c_scl == 1 ? next_cmd : i2c_bus_state::WAIT;
            default: nst = next_cmd;
        endcase

    always @(posedge clk, posedge rst)
        if (rst)
            force_scl <= 1;
        else if (sclk)
            if (phase == 0)
                case (st)
                    i2c_bus_state::IDLE:
                        force_scl <= 1;
                    i2c_bus_state::WRITE_START:
                        force_scl <= lst == i2c_bus_state::IDLE ? 1 : 0;
                    default: 
                        force_scl <= 0;
                endcase
            else if (phase == 2)
                force_scl <= 1;

    always @(posedge clk, posedge rst) 
        if (rst) 
            force_sda <= 1;
        else if (sclk)
            if (phase == 1)
                case (st)
                    i2c_bus_state::WRITE_START:
                        force_sda <= 1;
                    i2c_bus_state::WRITE_STOP:
                        force_sda <= 0;
                    i2c_bus_state::WRITE_ZERO:
                        force_sda <= 0;
                    i2c_bus_state::WRITE_ONE:
                        force_sda <= 1;
                    i2c_bus_state::READ_DATA:
                        force_sda <= 1;
                    i2c_bus_state::READ_ACK:
                        force_sda <= 1;
                    i2c_bus_state::WRITE_NACK:
                        force_sda <= 1;
                    i2c_bus_state::WAIT:
                        force_sda <= 1;
                    default: force_sda <= 1;
                endcase
            else if (phase == 3)
                case (st)
                    i2c_bus_state::WRITE_START:
                        force_sda <= 0;
                    i2c_bus_state::WRITE_STOP:
                        force_sda <= 1;
                    default: force_sda <= force_sda;
                endcase
            
    always @(posedge clk, posedge rst)
        if (rst)
            data_read <= 0;
        else if (sclk && phase == 3 && st == i2c_bus_state::READ_DATA)
            data_read <= i2c_sda;
endmodule
