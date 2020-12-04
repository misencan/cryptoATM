`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/03 20:17:01
// Design Name: 
// Module Name: sec_clock
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


module sec_clock(
    input clk, 
    output sec_clock
    );
    
    reg[27:0] counter=28'd0;
    parameter div = 28'd100000000;

    always @(posedge clk )
    begin
     counter <= counter + 28'd1;
     if(counter>=(div-1))
      counter <= 28'd0;
    end
    assign sec_clock = (counter<(div/2))?1'b0:1'b1;
endmodule
