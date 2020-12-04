`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/04 16:59:09
// Design Name: 
// Module Name: withdraw
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


module withdraw(
    input sec_clock,
    output [39:0] instruction
    );

    reg[39:0] temp = 40'b0000000000000000000000000000000000000000;
    reg[7:0] count;
    
     always@(posedge sec_clock)
    begin
        count <= count + 1;
        if (count == 1)
        begin
            temp = { temp[34:0], 5'b10111};
        end
        else if (count == 2)
        begin
            temp = { temp[34:0], 5'b01001};
        end
        else if (count == 3)
        begin
            temp = { temp[34:0], 5'b10100};
        end
        else if (count == 4)
        begin
            temp = { temp[34:0], 5'b01000};
        end
        else if (count == 5)
        begin
            temp = { temp[34:0], 5'b00100};
        end
        else if (count == 6)
        begin
            temp = { temp[34:0], 5'b10010};
        end
        else if (count == 7)
        begin
            temp = { temp[34:0], 5'b00001};
        end
        else if (count == 8)
        begin
            temp = { temp[34:0], 5'b10111};
        end
        else
        begin
            if( count<=15)
                temp <= { temp[34:0],5'b00000};
            else
                count <= 0;
        end
    end
    
    assign instruction = temp;
    
endmodule
