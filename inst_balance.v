`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/03 21:12:10
// Design Name: 
// Module Name: inst_balance
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


module inst_balance(
    input sec_clock,
    output [39:0] instruction
    );
    reg[4:0] tempc;
    reg temp_clock;
    reg[39:0] temp = 40'b0000000000000000000000000000000000000000;
    reg[7:0] count;
    
    
    always@(posedge sec_clock)
    begin
        tempc <= tempc + 1;
        if (tempc <=2)
        begin
            temp_clock <= 0;
        end
        else if (tempc >=6)
        begin
            tempc <= 0;         
        end
        else
            temp_clock <= 1; 
    end
    
    
    always@(posedge temp_clock)
    begin
        count <= count + 1;
        if (count == 1)
        begin
            temp = { temp[34:0], 5'b00010};
        end
        else if (count == 2)
        begin
            temp = { temp[34:0], 5'b00001};
        end
        else if (count == 3)
        begin
            temp = { temp[34:0], 5'b01100};
        end
        else if (count == 4)
        begin
            temp = { temp[34:0], 5'b00001};
        end
        else if (count == 5)
        begin
            temp = { temp[34:0], 5'b01110};
        end
        else if (count == 6)
        begin
            temp = { temp[34:0], 5'b00011};
        end
        else if (count == 7)
        begin
            temp = { temp[34:0], 5'b00101};
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
