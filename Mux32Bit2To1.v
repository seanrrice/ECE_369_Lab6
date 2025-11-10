`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - Mux32Bit2To1.v
// Description - Performs signal multiplexing between 2 32-Bit words.
////////////////////////////////////////////////////////////////////////////////

module Mux32Bit2To1(
    input  [31:0] inA,
    input  [31:0] inB,
    input         sel,
    output reg [31:0] out
);

always @(*) begin
    if (sel)
        out = inB;
    else
        out = inA;
end

endmodule

