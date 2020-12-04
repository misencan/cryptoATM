`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/04 15:09:31
// Design Name: 
// Module Name: instruction_seven_seg_display
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


module instruction_seven_seg_display(
    input clk,
    input [39:0] instruction,
    output reg [7:0] AN,
    output reg [6:0] led
    );
    
    reg [19:0]refresh_counter = 0;
    reg [4:0] selected_anode;
    wire [2:0] LED_counter;
    
    always @(posedge clk)
    refresh_counter <= refresh_counter +1;
    assign LED_counter = refresh_counter[19:17];
    always @(LED_counter)
    begin
        case(LED_counter)
            3'b000:
                AN = 8'b11111110;
            3'b001:
                AN = 8'b11111101;
            3'b010:
                AN = 8'b11111011;
            3'b011:
                AN = 8'b11110111;
            3'b100:
                AN = 8'b11101111;
            3'b101:
                AN = 8'b11011111;
            3'b110:
                AN = 8'b10111111;
            3'b111:
                AN = 8'b01111111;     
        endcase
    end
    
    always@(*)
    begin
    case(LED_counter)
        3'b000: 
            selected_anode = instruction[4:0];
        3'b001:
            selected_anode = instruction[9:5];
        3'b010:
            selected_anode = instruction[14:10];
        3'b011:
            selected_anode = instruction[19:15];
        3'b100:
            selected_anode = instruction[24:20];
        3'b101:
            selected_anode = instruction[29:25];
        3'b110:
            selected_anode = instruction[34:30];
        3'b111:
            selected_anode = instruction[39:35];                        
    endcase
    end
    
    always@(*)
    begin
        case(selected_anode)
        5'b00000: led = 7'b1111111;
        5'b00001: led = 7'b0001000;
        5'b00010: led = 7'b1100000;
        5'b00011: led = 7'b1110010;
        5'b00100: led = 7'b1000010;
        5'b00101: led = 7'b0110000;
        5'b00110: led = 7'b0111000;
        5'b00111: led = 7'b0000100;
        5'b01000: led = 7'b1001000;
        5'b01001: led = 7'b1001111;
        5'b01010: led = 7'b1000011;
        5'b01011: led = 7'b1110000;
        5'b01100: led = 7'b1110001;
        5'b01101: led = 7'b0101011;   
        5'b01110: led = 7'b1101010;
        5'b01111: led = 7'b1100010;
        5'b10000: led = 7'b0011000;
        5'b10001: led = 7'b0001100;
        5'b10010: led = 7'b1111010;
        5'b10011: led = 7'b0100100;
        5'b10100: led = 7'b1001110;
        5'b10101: led = 7'b1000001;
        5'b10110: led = 7'b1100011;
        5'b10111: led = 7'b1010101;
        5'b11000: led = 7'b0110110;
        5'b11001: led = 7'b1000100;
        5'b11010: led = 7'b0010010;
        default: led = 7'b1111111;
    endcase

    end
endmodule

