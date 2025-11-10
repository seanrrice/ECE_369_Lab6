`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - SignExtension.v
// Description - Extends a 16-bit input to 32 bits. 
//               If extOp = 1 ? sign extend
//               If extOp = 0 ? zero extend
////////////////////////////////////////////////////////////////////////////////
module SignExtension (
    input  [15:0] in,
    input         extOp,
    output reg [31:0] out
);

    always @(*) begin
        if (extOp)
            out = {{16{in[15]}}, in};  // Sign extend
        else
            out = {16'b0, in};         // Zero extend
    end

endmodule
