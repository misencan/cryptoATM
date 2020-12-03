`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 03:45:38 PM
// Design Name: 
// Module Name: digclk
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

module digclk(
    input clk,reset,
    output wire [6:0]segh1,segh2,segm1,segm2,segs1,segs2
);
//0-59 are mins, secs, 0-23 are hours
    reg [5:0]outh,outm,outs;

//hour,minute and second bdc outputs from bios(binary to BCD converter)

    wire [3:0]hr1,hr2,min1,min2,sec1,sec2;

//seconds clock

always @(posedge clk or posedge reset)
    begin
    if (reset==1)
        begin
        outs<=0;
    end
    else if(outs!=6'd59)
        begin
        outs<= outs+1;
    end
    else outs<=0;
end

//minutes clock

always @(posedge clk or posedge reset)
    begin
    if (reset==1)
        begin
        outm<=0;
    end
    else if(outs==6'd59)
        begin
        outm<= outm+1;
    end
    else if (outm==6'd60)
        begin
        outm<=0;
    end
end

//hours clock

always @(posedge clk or posedge reset)
    begin
    if(reset==1)
        begin
        outh <=0;
    end
    else if(outm==6'd60)
        begin
        outh<= outh+1;
    end
    else if (outh==6'd24)
        begin
        outh<=0;
    end
end

//binary to BCD converter instantiations

bintobcd s0(.bin(outs),.bcd1(sec1),.bcd0(sec2));

bintobcd s1(.bin(outm),.bcd1(min1),.bcd0(min2));

bintobcd s3(.bin(outh),.bcd1(hr1),.bcd0(hr2));

//BCD to seven segment decoder instantiations

//instantiations for seconds display

bcdtoseg e0(.bcd(sec1), .segment(segs1));

bcdtoseg e1(.bcd(sec2), .segment(segs2));

//instantiations for minutes display

bcdtoseg e2(.bcd(min1), .segment(segm1));

bcdtoseg e3(.bcd(min2), .segment(segm2));

//instantiations for hours display

bcdtoseg e4(.bcd(hr1), .segment(segh1));

bcdtoseg e5(.bcd(hr2), .segment(segh2));

endmodule