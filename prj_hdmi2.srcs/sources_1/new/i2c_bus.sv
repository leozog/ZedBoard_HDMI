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
    typedef enum { IDLE, SEND_START, SEND_STOP, SEND_ZERO, SEND_ONE, READ_DATA, READ_DATA_1, RECEIVE_ACK, RECEIVE_ACK_1, SEND_NACK, WAIT, FIN, ERROR} state;
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

    reg phase;
    i2c_bus_state::state st, nst;
    assign idle = sclk && phase == 0 && (st == i2c_bus_state::IDLE || st == i2c_bus_state::READ_DATA_1 || st == i2c_bus_state::RECEIVE_ACK_1);
    assign error = st == i2c_bus_state::ERROR;

    always @(posedge clk, posedge rst)
        if (rst)
            phase <= 0;
        else if (sclk)
            phase <= ~phase;

    always @(posedge clk, posedge rst)
        if (rst)
            st <= i2c_bus_state::IDLE;
        else if (sclk && phase == 1)
            st <= nst;

    always @*
        case (st)
            i2c_bus_state::IDLE:
                nst = next_cmd;
            i2c_bus_state::SEND_START:
                nst = i2c_bus_state::IDLE;
            i2c_bus_state::SEND_STOP:
                nst = i2c_bus_state::FIN;
            i2c_bus_state::SEND_ZERO:
                nst = i2c_bus_state::IDLE;
            i2c_bus_state::SEND_ONE:
                nst = i2c_bus_state::IDLE;
            i2c_bus_state::READ_DATA:
                nst = i2c_bus_state::READ_DATA_1;
            i2c_bus_state::READ_DATA_1:
                nst = next_cmd;
            i2c_bus_state::RECEIVE_ACK:
                nst = i2c_bus_state::RECEIVE_ACK_1;
            i2c_bus_state::RECEIVE_ACK_1:
                nst = i2c_sda == 0 ? (i2c_scl == 1 ? next_cmd : i2c_bus_state::WAIT) : i2c_bus_state::ERROR;
            i2c_bus_state::SEND_NACK:
                nst = i2c_bus_state::IDLE;
            i2c_bus_state::WAIT:
                nst = i2c_scl == 0 ? i2c_bus_state::WAIT : i2c_bus_state::IDLE;
            i2c_bus_state::ERROR:
                nst = i2c_bus_state::ERROR;
            i2c_bus_state::FIN:
                nst = i2c_bus_state::IDLE;
            default: nst = i2c_bus_state::SEND_STOP;
        endcase

    always @(posedge clk, posedge rst)
        if (rst)
            force_scl <= 1;
        else if (sclk && phase == 0)
            case (st)
                i2c_bus_state::IDLE:
                    force_scl <= 1;
                i2c_bus_state::SEND_START:
                    force_scl <= 1;
                i2c_bus_state::SEND_STOP:
                    force_scl <= 0;
                i2c_bus_state::SEND_ZERO:
                    force_scl <= 0;
                i2c_bus_state::SEND_ONE:
                    force_scl <= 0;
                i2c_bus_state::READ_DATA:
                    force_scl <= 0;
                i2c_bus_state::READ_DATA_1:
                    force_scl <= 1;
                i2c_bus_state::RECEIVE_ACK:
                    force_scl <= 0;
                i2c_bus_state::RECEIVE_ACK_1:
                    force_scl <= 1;
                i2c_bus_state::SEND_NACK:
                    force_scl <= 0;
                i2c_bus_state::WAIT:
                    force_scl <= 1;
                i2c_bus_state::FIN:
                    force_scl <= 1;
                default: force_scl <= 1;
            endcase

    always @(posedge clk, posedge rst) 
        if (rst) 
            force_sda <= 1;
        else if (sclk && phase == 1)
            case (st)
                i2c_bus_state::IDLE:
                    force_sda <= force_sda;
                i2c_bus_state::SEND_START:
                    force_sda <= 0;
                i2c_bus_state::SEND_STOP:
                    force_sda <= 0;
                i2c_bus_state::SEND_ZERO:
                    force_sda <= 0;
                i2c_bus_state::SEND_ONE:
                    force_sda <= 1;
                i2c_bus_state::READ_DATA:
                    force_sda <= 1;
                i2c_bus_state::READ_DATA_1:
                    force_sda <= 1;
                i2c_bus_state::RECEIVE_ACK:
                    force_sda <= 1;
                i2c_bus_state::RECEIVE_ACK_1:
                    force_sda <= 1;
                i2c_bus_state::SEND_NACK:
                    force_sda <= 1;
                i2c_bus_state::WAIT:
                    force_sda <= 1;
                i2c_bus_state::FIN:
                    force_sda <= 1;
                default: force_sda <= 1;
            endcase
            
    always @(posedge clk, posedge rst)
        if (rst)
            data_read <= 0;
        else if (sclk && phase == 0 && st == i2c_bus_state::READ_DATA_1)
            data_read <= i2c_sda;
endmodule
