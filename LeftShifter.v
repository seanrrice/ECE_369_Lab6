`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory  
// Module - LeftShifter.v
// Description - 32-Bit shifter to shift input left by 2 units.
// 
// INPUTS:-
// LeftShiftInput: 32-Bit input port.
// 
// OUTPUTS:-
// LeftShiftOutput: 32-Bit output port.
//
// FUNCTIONALITY:-
// This left shifter takes in a 32-bit input and logically shifts it left
// by 2 units
////////////////////////////////////////////////////////////////////////////////

module LeftShifter(LeftShiftInput, LeftShiftOutput);
    input [31:0] LeftShiftInput;
    output reg [31:0] LeftShiftOutput;
        
    initial begin
        LeftShiftOutput = 32'h0;
    end
    
    always @(*) begin
        LeftShiftOutput = LeftShiftInput << 2;
    end
    
endmodule