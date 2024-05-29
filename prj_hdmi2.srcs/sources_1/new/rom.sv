`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2024 09:06:13
// Design Name: 
// Module Name: rom
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


module rom
    #(parameter SIZE)
    (
    input clk,
    input rst,
    input [$clog2(SIZE) - 1:0] adr,
    output [7:0] data
    );

    reg [7:0] mem [SIZE - 1:0];

    

endmodule
