`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2020 03:16:47 PM
// Design Name: 
// Module Name: ATM
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


module ATM(
    input clk,
    input [11:0] accNumber,
    input [3:0] pin,
    input [3:0] current_state,
    input [1:0] menuOption,
    input [10:0] amount,
    output reg [10:0] balance,
    output [3:0] status_code
    );
    
    parameter 
        FIND = 1'b0,
        AUTHENTICATE = 1'b1;
        
    parameter [15:0] // I made this encoding scheme so i could light up debug LEDs but there are too many states lol
                     // These will probably change but wont affect any other modules
        IDLE = 16'b0000000000000001,
        ACC_NUM = 16'b0000000000000010,
        PIN_INPUT = 16'b0000000000000100,
        MENU = 16'b0000000000001000,
        SHOW_BALANCES = 16'b0000000000010000,
        CONVERT_CURRENCY = 16'b0000000000100000,
        SELECT_CURRENCY_CONVERT_1 = 16'b0000000001000000,
        SELECT_CURRENCY_CONVERT_2 = 16'b0000000010000000,
        WITHDRAW = 16'b0000000100000000,
        SELECT_AMOUNT_WITHDRAW = 16'b0000001000000000,
        TRANSFER = 16'b0000010000000000,
        SELECT_CURRENCY_TRANSFER = 16'b0000100000000000,
        SELECT_AMOUNT_TRANSFER = 16'b0001000000000000,
        ERROR = 16'b0010000000000000,
        SUCCESS = 16'b0100000000000000;
    
    parameter [2:0]
        USD = 3'b000,
        BTC = 3'b001,
        ETH = 3'b010,
        XRP = 3'b011,
        LTC = 3'b100;
    
    parameter [3:0] 
        ACC_FOUND = 4'b0001,
        ACC_NOT_FOUND = 4'b0010,
        PIN_CORRECT = 4'b0011,
        PIN_INCORRECT = 4'b0100,
        AMT_VALID = 4'b0101,
        AMT_INVALID = 4'b0110,
        EXIT = 4'b0111,
        INPUT_COMPLETE = 4'b1000;
    
    // Initialize and Fill all currency balances
    reg [15:0] balance_database [0:9][0:4];
    initial begin
    balance_database[0][0] = 16'd500;
    balance_database[1][0] = 16'd500;
    balance_database[2][0] = 16'd500;
    balance_database[3][0] = 16'd500;
    balance_database[4][0] = 16'd500;
    balance_database[5][0] = 16'd500;
    balance_database[6][0] = 16'd500;
    balance_database[7][0] = 16'd500;
    balance_database[8][0] = 16'd500;
    balance_database[9][0] = 16'd500;
    
    balance_database[0][1] = 16'd5;
    balance_database[1][1] = 16'd5;
    balance_database[2][1] = 16'd5;
    balance_database[3][1] = 16'd5;
    balance_database[4][1] = 16'd5;
    balance_database[5][1] = 16'd5;
    balance_database[6][1] = 16'd5;
    balance_database[7][1] = 16'd5;
    balance_database[8][1] = 16'd5;
    balance_database[9][1] = 16'd5;
    
    balance_database[0][2] = 16'd10;
    balance_database[1][2] = 16'd10;
    balance_database[2][2] = 16'd10;
    balance_database[3][2] = 16'd10;
    balance_database[4][2] = 16'd10;
    balance_database[5][2] = 16'd10;
    balance_database[6][2] = 16'd10;
    balance_database[7][2] = 16'd10;
    balance_database[8][2] = 16'd10;
    balance_database[9][2] = 16'd10;
    
    balance_database[0][3] = 16'd100;
    balance_database[1][3] = 16'd100;
    balance_database[2][3] = 16'd100;
    balance_database[3][3] = 16'd100;
    balance_database[4][3] = 16'd100;
    balance_database[5][3] = 16'd100;
    balance_database[6][3] = 16'd100;
    balance_database[7][3] = 16'd100;
    balance_database[8][3] = 16'd100;
    balance_database[9][3] = 16'd100;
    
    balance_database[0][4] = 16'd10;
    balance_database[1][4] = 16'd10;
    balance_database[2][4] = 16'd10;
    balance_database[3][4] = 16'd10;
    balance_database[4][4] = 16'd10;
    balance_database[5][4] = 16'd10;
    balance_database[6][4] = 16'd10;
    balance_database[7][4] = 16'd10;
    balance_database[8][4] = 16'd10;
    balance_database[9][4] = 16'd10;
    
    end
    
    wire [3:0] accIndex;
    wire [3:0] accIndexFind;
    wire [3:0] destinationAccIndex;
    wire isAuthenticated;
    wire wasFound;
    wire accFound;
    
    reg deAuth = 1'b0;
    
    reg balance_dollars;
    reg balance_btc;
    reg balance_eth;
    reg balance_xrp;
    reg balance_ltc;
    
    reg currency_type = 2'b00;
    reg status_code_reg;
    
    authenticator authAccNumberModule(accNumber, pin, AUTHENTICATE, deAuth, isAuthenticated, accIndex);
    authenticator accFinder(accNumber, pin, FIND, deAuth, accFound, accIndexFind);
    authenticator findAccNumberModule(destinationAcc, 0, FIND, deAuth, wasFound, destinationAccIndex);
    
    always @(posedge clk) begin
    
    case (current_state)
        
        ACC_NUM: begin
            if (accFound)
                status_code_reg = ACC_FOUND;
            else
                status_code_reg = ACC_NOT_FOUND;
        end
        
        PIN_INPUT: begin
            if (isAuthenticated)
                status_code_reg = PIN_CORRECT;
            else
                status_code_reg = PIN_INCORRECT;
        end
        
        SHOW_BALANCES: begin
            balance_dollars = balance_database[accIndex][0];
            balance_btc = balance_database[accIndex][1];
            balance_eth = balance_database[accIndex][2];
            balance_xrp = balance_database[accIndex][3];
            balance_ltc = balance_database[accIndex][4];
        end
        
        CONVERT_CURRENCY: begin
        end
        
        SELECT_AMOUNT_WITHDRAW: begin
            if (amount <= balance_database[accIndex][currency_type]) begin
                balance_database[accIndex][currency_type] = balance_database[accIndex][currency_type] - amount;
                balance = balance_database[accIndex][currency_type];
                status_code_reg = AMT_VALID;
            end else begin
                status_code_reg = AMT_INVALID;
            end
        end
        
        
    endcase
    end
    
    assign status_code = status_code_reg;
    
endmodule
