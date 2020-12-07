`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2020 11:36:48 AM
// Design Name: 
// Module Name: user_input
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


module user_input(
    input clk,
    input wire[7:0] ascii_code,
    input wire[10:0] state,
    input wire input_style_out,
    input wire status_code,
    output reg status_codeo,
    output reg [10:0] next_state,
    output reg[15:0] pswd,
    output reg[15:0] acct
    );
    
    // Parameter for status codes for state transitions (status_code)
    parameter [3:0] 
        ACC_FOUND = 4'b0001,
        ACC_NOT_FOUND = 4'b0010,
        PIN_CORRECT = 4'b0011,
        PIN_INCORRECT = 4'b0100,
        AMT_VALID = 4'b0101,
        AMT_INVALID = 4'b0110,
        EXIT = 4'b0111,
        INPUT_COMPLETE = 4'b1000;
        
    // Parameter for Input style (Pretty sure these will work for all state transitions/input requirements, let me know though)
    parameter [3:0]
        SINGLE_KEY = 4'b0001,
        ACC_NUMBER = 4'b0010,
        PIN_NUMBER = 4'b0011,
        MENU_SELECTION = 4'b0100,
        CURRENCY_TYPE = 4'b0101,
        CURRENCY_AMOUNT = 4'b0110;
        
    parameter [4:0] // I made this encoding scheme so i could light up debug LEDs but there are too many states lol
                     // These will probably change but wont affect any other modules
        IDLE = 5'b00001,
        ACC_NUM = 5'b00010,
        PIN_INPUT = 5'b00011,
        MENU = 5'b00100,
        SHOW_BALANCES = 5'b00101,
        CONVERT_CURRENCY = 5'b00110,
        SELECT_CURRENCY_CONVERT_1 = 5'b00111,
        SELECT_CURRENCY_CONVERT_2 = 5'b01000,
        WITHDRAW = 5'b01001,
        SELECT_AMOUNT_WITHDRAW = 5'b01010,
        TRANSFER = 5'b01011,
        SELECT_CURRENCY_TRANSFER = 5'b01100,
        SELECT_AMOUNT_TRANSFER = 5'b01101,
        ERROR = 5'b01110,
        SUCCESS = 5'b01111;
    
    parameter[15:0]
        ACCT1 = 16'b0111011101110111,
        ACCT2 = 16'b0001000100010001,
        ACCT3 = 16'b0011001100110011;
        
    parameter[15:0]
        PIN1 = 16'b0111011101110111,
        PIN2 = 16'b0001000100010001,
        PIN3 = 16'b0011001100110011;
        
    parameter[15:0]
        BAL1 = 16'b0111011101110111,
        BAL2 = 16'b0001000100010001,
        BAL3 = 16'b0011001100110011;
       
       
     reg count =0;
    // account, pin input
    always@(posedge clk) begin
     if(ascii_code == 8'h71) // q   
                begin
                    status_codeo <= EXIT;
                end   
        case(state)
              IDLE:
                    if(count == 0) begin
                        acct <= ascii_code[3:0]; // 0 is the pin's LSB
                        count <= count+1;
                    end
                    else if(count > 0 && count < 4) begin
                        acct  = {ascii_code[3:0],acct};
                        count <= count+1;
                    end
                    else if(count >= 4) begin
                        count <= 0;
                    end
              ACC_NUM:
                    if(acct == ACCT1 || acct == ACCT2 || acct == ACCT3) begin
                        status_codeo = ACC_FOUND;
                    end
                    else begin
                        status_codeo = ACC_NOT_FOUND;
                    end
              PIN_INPUT: begin
              if(pswd == PIN1 || pswd == PIN2 || pswd == PIN3) begin
                    status_codeo = PIN_CORRECT;
              end
              else begin
                status_codeo = PIN_INCORRECT;
              end
              if(count == 0) begin
                        count <= count+1;
                        pswd <= ascii_code[3:0]; // 0 is the pin's LSB
                         
                end
                else if(count > 0 && count < 4) begin
                        pswd  = {ascii_code[3:0], pswd};
                        count <= count + 1;
                 end
                 else if(count >= 4) begin
                    count <= 0;
                 end
                 //assign status_codeo = (pswd == 16'b0000000000000000) ? PIN_INCORRECT : PIN_CORRECT
                 end
          endcase
    end
endmodule
