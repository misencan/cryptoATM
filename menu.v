`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/03 20:27:35
// Design Name: 
// Module Name: menu
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


module menu(
    input clk,
    output [7:0] AN,
    output [6:0] led
    );
    wire s_clock;
    wire [39:0] instruction;
    sec_clock sec(clk,s_clock);
    inst_balance ib(s_clock,instruction);
    instruction_seven_seg_display issd(clk,instruction,AN,led);
    
endmodule
