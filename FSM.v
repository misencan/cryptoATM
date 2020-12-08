`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2020 08:14:30 PM
// Design Name: 
// Module Name: FSM
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


module FSM(
    input clk,
    input inc_state, //debug button to progress state
    input usr_input, //Input from user (probably going to change as the input format is still up in the air)
                     //Maybe Instead of forwarding user input to this module there is another module in the middle
                     //that verifies account numbers and pin numbers
    input status_code, //Status from middle module for use in progressing states that require more than a simple input 
    output [15:0] current_state, //Current state code
    output display_enable, //Display output parameter that will have to get configured
    output input_style_out,
    output [15:0] state_led
    
    // I think we can base the input style parameter and the display enable parameter based off the current state value
    
    );
    
    // Temporary registers for various 
    
    reg display_out;
    reg input_style;
    
    
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
    
    // Parameter for output style (I have no clue if these are the best parameters let me know what you want)
    
    parameter [3:0]
        INFORMATION = 4'b0001,
        INSTRUCTION = 4'b0010,
        STATIC = 4'b0011,
        SCROLLING = 4'b0100,
        DISPLAY_INPUT = 4'b0101,
        CYCLING = 4'b0110;
    
    // Parameter for menu options (These can change also, just needed a way to distinguish between user inputs)
    parameter [1:0]
        BALANCE = 2'b00,
        CONVERT = 2'b01,
        WITHDRAW_OPTION = 2'b10,
        TRANSFER_OPTION = 2'b11;
    
    reg [10:0] state;
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
    
    initial state = IDLE;
    
    // Isolate rising edge of debug button for state progression
    
    wire inc_state_edge;
    reg inc_state_sync_f;
    reg inc_state_f;
    reg inc_state_sync;
    
    always @(posedge clk) begin
        inc_state_f <= inc_state;
        inc_state_sync <= inc_state_f;
    end
    
    always @(posedge clk) begin
        inc_state_sync_f <= inc_state_sync;
    end
    
    assign inc_state_edge = inc_state_sync & ~inc_state_sync_f;
    
    always @(posedge clk) begin // Use up button to increase state
        
        case(state)
            IDLE: begin
                if (status_code == INPUT_COMPLETE) begin
                    state = ACC_NUM;
                    display_out = SCROLLING; //TODO: Display "INPUT ACCOUNT NUMBER" Or something like that 
                                     //also should make an encoding scheme for what to display (Make a list of text to display)
                    input_style = ACC_NUMBER; //TODO: Associate input style with amount of characters that can be inputted, 
                                     //If input is saved, or if is simply progressing through menus
                                     //Need an encoding scheme for this also (make a list of input lenghts/configurations)
                                     //Maybe this is just based on what buttons they press on the keyboard
                end else begin
                    state = IDLE;
                    display_out = CYCLING; //Default display out to show idle/welcome text or current prices
                    input_style = SINGLE_KEY; //any key will progress to next state
                end
            end
            ACC_NUM: begin
                if (status_code == ACC_FOUND) begin //Move to next state if account was found
                    state = PIN_INPUT;
                    display_out = SCROLLING; // Display "INPUT PIN NUMBER"
                    input_style = PIN_NUMBER;
                end else if (status_code == ACC_NOT_FOUND) begin
                    state = IDLE;
                    display_out = CYCLING;
                    input_style = SINGLE_KEY;
                end else begin
                    state = ACC_NUM;
                    display_out = SCROLLING;
                    input_style = ACC_NUMBER;
                end
            end
            PIN_INPUT: begin
                if (status_code == PIN_CORRECT) begin
                    state = MENU;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION;
                end else if (status_code == PIN_INCORRECT) begin
                    state = IDLE;
                    display_out = CYCLING;
                    input_style = SINGLE_KEY;
                end else begin
                    state = PIN_INPUT;
                    display_out = SCROLLING;
                    input_style = PIN_NUMBER;
                end
            end
            MENU: begin
                if (usr_input == BALANCE) begin
                    state = SHOW_BALANCES;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY;
                end else if (usr_input == CONVERT) begin
                    state = CONVERT_CURRENCY;
                    display_out = SCROLLING;
                    input_style = CURRENCY_TYPE;
                end else if (usr_input == WITHDRAW_OPTION) begin
                    state = WITHDRAW;
                    display_out = SCROLLING;
                    input_style = CURRENCY_TYPE;
                end else if (usr_input == TRANSFER_OPTION) begin
                    state = TRANSFER;
                    display_out = SCROLLING;
                    input_style = ACC_NUMBER;
                end else if (status_code == EXIT) begin
                    state = IDLE;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY;
                end else begin
                    state = MENU;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION;          
                end
            end
            SHOW_BALANCES: begin
                if (status_code == EXIT) begin
                    state = MENU;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION;
                end else begin
                    state = SHOW_BALANCES;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY;
                end
            end
            CONVERT_CURRENCY: begin
                if (status_code == INPUT_COMPLETE) begin
                    state = SELECT_CURRENCY_CONVERT_1;
                    display_out = SCROLLING;
                    input_style = CURRENCY_AMOUNT;
                end else if (status_code == EXIT) begin
                    state = MENU;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION;    
                end else begin
                    state = CONVERT_CURRENCY;
                    display_out = SCROLLING;
                    input_style = CURRENCY_TYPE;
                end
            end
            SELECT_CURRENCY_CONVERT_1: begin
                if (status_code == AMT_VALID) begin
                    state = SELECT_CURRENCY_CONVERT_2;
                    display_out = SCROLLING;
                    input_style = CURRENCY_TYPE;
                end else if (status_code == AMT_INVALID) begin
                    state = ERROR;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY;
                end else if (status_code == EXIT) begin
                    state = MENU;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION;    
                end else begin
                    state = SELECT_CURRENCY_CONVERT_1;
                    display_out = SCROLLING;
                    input_style = CURRENCY_AMOUNT;      
                end
            end
            SELECT_CURRENCY_CONVERT_2: begin
                if (status_code == INPUT_COMPLETE) begin
                    state = SUCCESS;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY;
                end else if (status_code == EXIT) begin
                    state = MENU;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION;
                end else begin
                    state = SELECT_CURRENCY_CONVERT_2;
                    display_out = SCROLLING;
                    input_style = CURRENCY_TYPE;
                end
            end
            WITHDRAW: begin
                if (status_code == INPUT_COMPLETE) begin
                    state = SELECT_AMOUNT_WITHDRAW;
                    display_out = SCROLLING;
                    input_style = CURRENCY_AMOUNT;
                end else if (status_code == EXIT) begin
                    state = MENU;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION;    
                end else begin
                    state = WITHDRAW;
                    display_out = SCROLLING;
                    input_style = CURRENCY_TYPE; 
                end
            end
            SELECT_AMOUNT_WITHDRAW: begin
                if (status_code == AMT_VALID) begin
                    state = SUCCESS;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY;
                end else if (status_code == AMT_INVALID) begin
                    state = ERROR;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY;    
                end else begin
                    state = SELECT_AMOUNT_WITHDRAW;
                    display_out = SCROLLING;
                    input_style = CURRENCY_AMOUNT; 
                end
            end
            TRANSFER: begin
                if (status_code == ACC_FOUND) begin
                    state = SELECT_CURRENCY_TRANSFER;
                    display_out = SCROLLING;
                    input_style = CURRENCY_TYPE;
                end else if (status_code == ACC_NOT_FOUND) begin
                    state = ERROR;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY;
                end else if (status_code == EXIT) begin
                    state = MENU;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION;   
                end else begin
                    state = TRANSFER;
                    display_out = SCROLLING;
                    input_style = ACC_NUMBER; 
                end
            end
            SELECT_CURRENCY_TRANSFER: begin
                if (status_code == INPUT_COMPLETE) begin
                    state = SELECT_AMOUNT_TRANSFER;
                    display_out = SCROLLING;
                    input_style = CURRENCY_AMOUNT;
                end else if (status_code == EXIT) begin
                    state = MENU;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION; 
                end else begin
                    state = SELECT_AMOUNT_TRANSFER;
                    display_out = SCROLLING;
                    input_style = CURRENCY_TYPE;
                end
            end
            SELECT_AMOUNT_TRANSFER: begin
                if (status_code == AMT_VALID) begin
                    state = SUCCESS;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY;
                end else if (status_code == AMT_INVALID) begin
                    state = ERROR;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY;                      
                end else begin
                    state = SELECT_AMOUNT_TRANSFER;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION;
                end
            end
            ERROR: begin
                if (status_code == EXIT) begin
                    state = MENU;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION;                    
                end else begin
                    state = ERROR;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY; 
                end
            end
            SUCCESS: begin
                if (status_code == EXIT) begin
                    state = MENU;
                    display_out = SCROLLING;
                    input_style = MENU_SELECTION;                    
                end else begin
                    state = SUCCESS;
                    display_out = SCROLLING;
                    input_style = SINGLE_KEY;
                end
            end
        endcase
        end
        
        assign state_led = current_state;
    
endmodule
