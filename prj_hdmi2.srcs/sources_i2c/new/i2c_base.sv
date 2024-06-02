`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Leon
// 
// Create Date: 22.05.2024 05:26:57
// Design Name: 
// Module Name: i2c_base
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


module i2c_base(
    input clk,
    input rst,
    input sclk,
    inout i2c_scl,
    inout i2c_sda,
    input [7:0] dev_adr,
    input [7:0] dev_reg,
    input [7:0] dev_data_write,
    output [7:0] dev_data_read,
    input write,
    input read,
    output idle
    );

    i2c_bus_state::state bus_next_cmd; 
    wire bus_idle, bus_error, bus_data_read;
    i2c_bus i2c_bus_inst(
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .next_cmd(bus_next_cmd),
        .idle(bus_idle),
        .error(bus_error),
        .data_read(bus_data_read)
        );
        
    reg stream_start, stream_write, stream_read;
    wire stream_finish, stream_bit_out;
    reg [7:0] stream_data_out;
    bit_stream #(.N(8)) bit_stream_inst(
        .clk(clk),
        .rst(rst),
        .sclk(bus_idle),
        .setup(stream_start),
        .write(stream_write),    
        .read(stream_read),
        .finish(stream_finish),
        .bit_out(stream_bit_out),
        .bit_in(bus_data_read),
        .data_out(stream_data_out),
        .data_in(dev_data_read)
        );


    typedef enum { 
        IDLE, 
        WRITE_START, 
        WRITE_SLAVE_ADDRESS, 
        READ_SLAVE_ADDRESS_ACK, 
        WRITE_DATA_ADDRESS, 
        READ_DATA_ADDRESS_ACK,
        WRITE_DATA,
        READ_DATA_ACK,
        READ_DATA,
        WRITE_DATA_NACK,
        WRITE_STOP
    } state;

    typedef enum { 
        FRAME_IDLE,
        FRAME_WRITE,
        FRAME_READ_0,
        FRAME_READ_1
    } frame_state;

    state st, nst;
    frame_state frame_st, frame_nst;

    assign idle = st == IDLE;

    always @(posedge clk, posedge rst)
        if(rst)
            st <= IDLE;
        else if(bus_idle)
            st <= nst;

    always @*
        case(st)
            IDLE: nst = (write || read) ? WRITE_START : IDLE;   
            WRITE_START: nst = WRITE_SLAVE_ADDRESS;
            WRITE_SLAVE_ADDRESS: nst = stream_finish ? READ_SLAVE_ADDRESS_ACK : WRITE_SLAVE_ADDRESS;
            READ_SLAVE_ADDRESS_ACK: nst = bus_error ? WRITE_STOP : (frame_st == FRAME_READ_1 ? READ_DATA : WRITE_DATA_ADDRESS);
            WRITE_DATA_ADDRESS: nst = stream_finish ? READ_DATA_ADDRESS_ACK : WRITE_DATA_ADDRESS;
            READ_DATA_ADDRESS_ACK: nst = bus_error ? WRITE_STOP : (frame_st == FRAME_WRITE ? WRITE_DATA : WRITE_START);
            WRITE_DATA: nst = stream_finish ? READ_DATA_ACK : WRITE_DATA; 
            READ_DATA_ACK: nst = WRITE_STOP;
            READ_DATA: nst = stream_finish ? WRITE_DATA_NACK : READ_DATA;
            WRITE_DATA_NACK: nst = WRITE_STOP;
            WRITE_STOP: nst = IDLE;
            default: nst = IDLE;
        endcase

    always @(posedge clk, posedge rst)
        if(rst)
            frame_st <= FRAME_IDLE;
        else if(bus_idle)
            frame_st <= frame_nst;

    always @*
        if (nst == IDLE)
            frame_nst = FRAME_IDLE;
        else
            case(frame_st)
                FRAME_IDLE: frame_nst = read ? FRAME_READ_0 : (write ? FRAME_WRITE : FRAME_IDLE);
                FRAME_WRITE: frame_nst = FRAME_WRITE;
                FRAME_READ_0: frame_nst = st == READ_DATA_ADDRESS_ACK ? FRAME_READ_1 : FRAME_READ_0;
                FRAME_READ_1: frame_nst = FRAME_READ_1;
                default: frame_nst = FRAME_IDLE;
            endcase


    always @*
        case(st)
            WRITE_START: stream_data_out = dev_adr & 8'hFE | (frame_st == FRAME_READ_1 ? 8'h01 : 8'h00);
            READ_SLAVE_ADDRESS_ACK: stream_data_out = dev_reg;
            READ_DATA_ADDRESS_ACK: stream_data_out = dev_data_write;
            default: stream_data_out = 8'hFF;
        endcase
    
    always @*
        case(st)
            WRITE_START: stream_start = 1;
            READ_SLAVE_ADDRESS_ACK: stream_start = 1;
            READ_DATA_ADDRESS_ACK: stream_start = 1;
            default: stream_start = 0;
        endcase

    always @*
        case(st)
            WRITE_SLAVE_ADDRESS: stream_write = 1;
            WRITE_DATA_ADDRESS: stream_write = 1;
            WRITE_DATA: stream_write = 1;
            default: stream_write = 0;
        endcase

    always @*
        case(st)
            READ_DATA: stream_read = 1;
            default: stream_read = 0;
        endcase

    always @*
        case(st)
            IDLE: bus_next_cmd = i2c_bus_state::IDLE;
            WRITE_START: bus_next_cmd = i2c_bus_state::WRITE_START;
            WRITE_SLAVE_ADDRESS: bus_next_cmd = stream_bit_out ? i2c_bus_state::WRITE_ONE : i2c_bus_state::WRITE_ZERO;
            READ_SLAVE_ADDRESS_ACK: bus_next_cmd = i2c_bus_state::READ_ACK;
            WRITE_DATA_ADDRESS: bus_next_cmd = stream_bit_out ? i2c_bus_state::WRITE_ONE : i2c_bus_state::WRITE_ZERO;
            READ_DATA_ADDRESS_ACK: bus_next_cmd = i2c_bus_state::READ_ACK;
            WRITE_DATA: bus_next_cmd = stream_bit_out ? i2c_bus_state::WRITE_ONE : i2c_bus_state::WRITE_ZERO;
            READ_DATA_ACK: bus_next_cmd = i2c_bus_state::READ_ACK;
            READ_DATA: bus_next_cmd = i2c_bus_state::READ_DATA;
            WRITE_DATA_NACK: bus_next_cmd = i2c_bus_state::WRITE_NACK;
            WRITE_STOP: bus_next_cmd = i2c_bus_state::WRITE_STOP;
            default: bus_next_cmd = i2c_bus_state::IDLE;
        endcase
endmodule
