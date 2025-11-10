`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - Mux32Bit2To1.v
// Description - Performs signal multiplexing between 2 32-Bit words.
////////////////////////////////////////////////////////////////////////////////

module Mux32Bit4To1(out, inA, inB, inC, inD, sel);

    output reg [31:0] out;
    
    input [31:0] inA;
    input [31:0] inB;
    input [31:0] inC, inD;
    input [1:0] sel;

    /* Fill in the implementation here ... */ 
always @(*) begin
   case(sel)
        2'b00: out = inA;
        2'b01: out = inB;
        2'b10: out = inC;
        2'b11: out = inD;
        default: out = inA;
   endcase
end
            
endmodule
