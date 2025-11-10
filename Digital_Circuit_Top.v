`timescale 1ns / 1ps

module Digital_Circuit_Top(Reset, Clk, out7, en_out);
    input Reset, Clk;
    output [6:0] out7;
    output [7:0] en_out;
    
    // wire nets connecting submodules
    wire ClkOut;
    wire [31:0] WriteDataDisplay;
    wire [31:0] PCAddDisplay;
    
    // submodules to be implimented in this program
    ClkDiv ClkDiv_1(Clk, 0, ClkOut);
    One_Core_CPU_Mips_Top(ClkOut, Reset, PCAddDisplay, WriteDataDisplay);
    Two4DigitDisplay Two4DigitDisplay_1(Clk, WriteDataDisplay[15:0], PCAddDisplay[15:0], out7, en_out);
endmodule