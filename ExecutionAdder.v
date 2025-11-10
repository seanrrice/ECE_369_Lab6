`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory  
// Module - ExecutionAdder.v
// Description - 32-Bit adder for execution portion of pipline.
// 
// INPUTS:-
// LeftShiftResult: 32-Bit input port.
// PCAddResult: 32-Bit input port.
// 
// OUTPUTS:-
// ExecutionAddResult: 32-Bit output port.
//
// FUNCTIONALITY:-
// Design an adder that computes the PCAddresult from the previous adder
// plus the result from the left shifter 
// (i.e., ExecutionAddResult = LeftShiftResult + PCAddResult).
////////////////////////////////////////////////////////////////////////////////

module ExecutionAdder(PCAddResult, LeftShiftResult, ExecutionAddResult);
    input [31:0] LeftShiftResult;
    input [31:0] PCAddResult;
    output reg [31:0] ExecutionAddResult;
    
    initial begin
        ExecutionAddResult = 32'h0;
    end
    
    always@(*) begin
        ExecutionAddResult = LeftShiftResult + PCAddResult;
    end
    
endmodule