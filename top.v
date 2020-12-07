`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Thomas Kappenman
// 
// Create Date: 03/03/2015 09:06:31 PM
// Design Name: 
// Module Name: top
// Project Name: Nexys4DDR Keyboard Demo
// Target Devices: Nexys4DDR
// Tool Versions: 
// Description: This project takes keyboard input from the PS2 port,
//  and outputs the keyboard scan code to the 7 segment display on the board.
//  The scan code is shifted left 2 characters each time a new code is
//  read.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input CLK100MHZ,
    input inc_state,
    input status_code,
    input PS2_CLK,
    input PS2_DATA,
    output [6:0]SEG,
    output [7:0]AN,
    output DP,
    output UART_TXD,
    output [10:0] next_state
    );
    
reg CLK50MHZ=0; 
reg[10:0] state;   
reg[1:0] password;
reg[1:0] acct;
wire [31:0]keycode;
wire[7:0] ascii_code;
wire display_enable;
wire input_style_out;

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
        
    parameter[1:0]
        ACCT1 = 2'b01,
        ACCT2 = 2'b10,
        ACCT3 = 2'b11;
        
    parameter[1:0]
        PIN1 = 2'b01,
        PIN2 = 2'b10,
        PIN3 = 2'b11;
        
    parameter[1:0]
        BAL1 = 2'b01,
        BAL2 = 2'b10,
        BAL3 = 2'b11;
        
    initial state = IDLE;

always @(posedge(CLK100MHZ))begin
    CLK50MHZ<=~CLK50MHZ;
end

PS2Receiver keyboard (
.clk(CLK50MHZ),
.kclk(PS2_CLK),
.kdata(PS2_DATA),
.keycodeout(keycode[31:0])
);

ascii_decoder adec(.scan_code(keycode[7:0]), .ascii_code(ascii_code));

seg7decimal sevenSeg (
.x(ascii_code[7:0]),
.clk(CLK100MHZ),
.seg(SEG[6:0]),
.an(AN[7:0]),
.dp(DP) 
);

FSM UUT(
    .clk(CLK100MHZ),
    .inc_state(inc_state), //debug button to progress state
    .usr_input(ascii_code[7:0]), //Input from user (probably going to change as the input format is still up in the air
    .status_code(status_code), //Status from middle module for use in progressing states that require more than a simple input 
    .current_state(state[10:0]), //Current state code
    .display_enable(display_enable), //Display output parameter that will have to get configured
    .input_style_out(input_style_out) //
    );
    
user_input #(.ACC_FOUND(4'b0001),
        .ACC_NOT_FOUND(4'b0010),
        .PIN_CORRECT(4'b0011),
        .PIN_INCORRECT(4'b0100),
        .AMT_VALID(4'b0101),
        .AMT_INVALID(4'b0110),
        .EXIT(4'b0111),
        .INPUT_COMPLETE(4'b1000),
        .SINGLE_KEY(4'b0001),
        .ACC_NUMBER(4'b0010),
        .PIN_NUMBER(4'b0011),
        .MENU_SELECTION(4'b0100),
        .CURRENCY_TYPE(4'b0101),
        .CURRENCY_AMOUNT(4'b0110),
        .IDLE(5'b00001),
        .ACC_NUM(5'b00010),
        .PIN_INPUT(5'b00011),
        .MENU(5'b00100),
        .SHOW_BALANCES(5'b00101),
        .CONVERT_CURRENCY(5'b00110),
        .SELECT_CURRENCY_CONVERT_1(5'b00111),
        .SELECT_CURRENCY_CONVERT_2(5'b01000),
        .WITHDRAW(5'b01001),
        .SELECT_AMOUNT_WITHDRAW(5'b01010),
        .TRANSFER(5'b01011),
        .SELECT_CURRENCY_TRANSFER(5'b01100),
        .SELECT_AMOUNT_TRANSFER(5'b01101),
        .ERROR(5'b01110),
        .SUCCESS(5'b01111),
        .ACCT1(2'b01),
        .ACCT2(2'b10),
        .ACCT3(2'b11),
        .PIN1(2'b01),
        .PIN2(2'b10),
        .PIN3(2'b11),
        .BAL1(2'b01),
        .BAL2(2'b10),
        .BAL3(2'b11))
        usr(
    .clk(CLK100MHZ),
    .ascii_code(ascii_code[7:0]),
    .state(state[10:0]),
    .input_style_out(input_style_out),
    .status_code(status_code),
    .status_codeo(0),
    .next_state(0),
    .pswd(0),
    .acct(0)
    );

endmodule
