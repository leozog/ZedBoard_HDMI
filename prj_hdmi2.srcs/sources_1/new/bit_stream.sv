`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2024 08:52:03 AM
// Design Name: 
// Module Name: bit_stream
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


module bit_stream
    #(parameter N = 8)
    (
    input clk,
    input rst,
    input sclk,
    input setup,
    input send,
    input read,
    output finish,
    output bit_out,
    input bit_in,
    input [N - 1:0] data_out,
    output [N - 1:0] data_in
    );

    reg [N - 1:0] hold;
    reg [$clog2(N - 1) : 0] ctr;
    
    assign finish = ctr == 0;
    assign bit_out = hold[N - 1];
    assign data_in = hold;

    always @(posedge clk)
        if(sclk)
            if(setup)
                hold <= data_out;
            else if(!finish && send)
                hold <= {hold[N-2:0], 1'b0};
            else if(!finish && read)
                hold <= {hold[N-2:0], bit_in};
            
    always @(posedge clk, posedge rst)
        if(rst)
            ctr <= N - 1;
        else if(sclk)
            if(setup)
                ctr <= N - 1;
            else if(!finish && (send || read))
                ctr <= ctr - 1;

endmodule
