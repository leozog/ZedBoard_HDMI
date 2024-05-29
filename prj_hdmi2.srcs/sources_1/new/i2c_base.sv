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
    input send,
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
        .error(bus_error)
        .data_read(bus_data_read)
        );
        
    reg stream_start, stream_send, stream_read;
    wire stream_finish, stream_bit_out;
    reg [7:0] stream_data_out;
    wire [7:0] stream_data_in;
    bit_stream #(.N(8)) bit_stream_inst(
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .setup(stream_start),
        .send(stream_send),    
        .read(stream_read),
        .finish(stream_finish),
        .bit_out(stream_bit_out),
        .bit_in(bus_data_read),
        .data_out(stream_data_out),
        .data_in(stream_data_in)
        );


    typedef enum { 
        Idle, 
        SendStart, 
        SendSlaveAddress, 
        ReceiveSlaveAddressAck, 
        SendDataAddress, 
        ReceiveDataAddressAck,
        SendData,
        ReceiveDataAck,
        ReceiveData,
        SendDataNack,
        SendStop
    } state;

    typedef enum { 
        Idle,
        FrameSend,
        FrameRead0,
        FraneRead1
    } frame_state;

    state st, nst;
    frame_state frame_st, frame_nst;

    assign idle = st == Idle;
    wire read_write_bit = frame_st == FrameRead1 ? 1 : 0;

    always @(posedge clk, posedge rst)
        if(rst)
            st <= Idle;
        else if(bus_idle)
            st <= nst;

    always @*
        case(st)
            Idle: nst = (send || read) ? SendStart : Idle;   
            SendStart: nst = SendSlaveAddress;
            SendSlaveAddress: nst = stream_finish ? ReceiveSlaveAddressAck : SendSlaveAddress;
            ReceiveSlaveAddressAck: nst = frame_st == FrameRead1 ? ReceiveData : SendDataAddress;
            SendDataAddress: nst = stream_finish ? ReceiveDataAddressAck : SendDataAddress;
            ReceiveDataAddressAck: nst = read_write_bit ? SendData : SendStart;
            SendData: nst = stream_finish ? ReceiveDataAck : SendData; 
            ReceiveDataAck: nst = SendStop;
            ReceiveData: nst = SendDataNack;
            SendDataNack: nst = SendStop;
            SendStop: nst = Idle;
            default: nst = Idle;
        endcase

    always @(posedge clk, posedge rst)
        if(rst)
            frame_st <= Idle;
        else (bus_idle)
            frame_st <= frame_nst;

    always @*
        if nst == Idle
            frame_nst = Idle;
        else
            case(frame_st)
                Idle: frame_nst = read ? FrameRead0 : (send ? FrameSend : Idle);
                FrameSend: frame_nst = FrameSend;
                FrameRead0: frame_nst = st == ReceiveDataAddressAck ? FrameRead1 : FrameRead0;
                FrameRead1: frame_nst = FrameRead1;
                default: frame_nst = Idle;
            endcase


    always @(posedge clk, posedge rst)
        if (rst)
            stream_data_out <= 8'hFF;
        else 
            case(st)
                SendStart: stream_data_out <= {dev_adr[7:1], read_write_bit};
                ReceiveSlaveAddressAck: stream_data_out <= dev_reg;
                ReceiveDataAddressAck: stream_data_out <= dev_data_write;
                default: stream_data_out <= 8'hFF;
            endcase
    
    always @(posedge clk, posedge rst)
        if (rst)
            stream_start <= 0;
        else 
            case(st)
                SendStart: stream_start <= 1;
                ReceiveSlaveAddressAck: stream_start <= 1;
                ReceiveDataAddressAck: stream_start <= 1;
                default: stream_start <= 0;
            endcase

    always @(posedge clk, posedge rst)
        if (rst)
            stream_send <= 0;
        else 
            case(st)
                SendSlaveAddress: stream_send <= 1;
                SendDataAddress: stream_send <= 1;
                SendData: stream_send <= 1;
                default: stream_send <= 0;
            endcase

    always @(posedge clk, posedge rst)
        if (rst)
            stream_read <= 0;
        else 
            case(st)
                ReceiveData: stream_read <= 1;
                default: stream_read <= 0;
            endcase

    always @(posedge clk, posedge rst)
        if (rst)
            bus_next_cmd <= i2c_bus_state::IDLE;
        else 
            case(st)
                Idle: bus_next_cmd <= i2c_bus_state::IDLE;
                SendStart: bus_next_cmd <= i2c_bus_state::SEND_START;
                SendSlaveAddress: bus_next_cmd <= stream_out ? i2c_bus_state::SEND_ONE : i2c_bus_state::SEND_ZERO;
                ReceiveSlaveAddressAck: bus_next_cmd <= i2c_bus_state::RECEIVE_ACK;
                SendDataAddress: bus_next_cmd <= stream_out ? i2c_bus_state::SEND_ONE : i2c_bus_state::SEND_ZERO;
                ReceiveDataAddressAck: bus_next_cmd <= i2c_bus_state::RECEIVE_ACK;
                SendData: bus_next_cmd <= stream_out ? i2c_bus_state::SEND_ONE : i2c_bus_state::SEND_ZERO;
                ReceiveDataAck: bus_next_cmd <= i2c_bus_state::RECEIVE_ACK;
                ReceiveData: bus_next_cmd <= i2c_bus_state::READ_DATA;
                SendDataNack: bus_next_cmd <= i2c_bus_state::SEND_NACK;
                default: bus_next_cmd <= i2c_bus_state::IDLE;
            endcase
endmodule
