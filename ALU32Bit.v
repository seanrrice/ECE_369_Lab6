`timescale 1ns / 1ps

module ALU32Bit(
    input  wire [31:0] A, B,
    input  wire [3:0]  ALUControl,
    output reg  [31:0] ALUResult
);
    // Signed views for MIPS signed ops
    wire signed [31:0] sA = $signed(A);
    wire signed [31:0] sB = $signed(B);
    
    wire signed [63:0] MulResult = sA * sB;

    always @(*) begin
        case (ALUControl)
            4'h0: ALUResult = A + B;                        // add
            4'h1: ALUResult = A - B;                        // sub
            4'h2: ALUResult = MulResult[31:0];              //mul      
            4'h3: ALUResult = A | B;                        // or
            4'h4: ALUResult = A ^ B;                        // xor
            4'h5: ALUResult = ~(A | B);                     // nor
            4'h6: ALUResult = A & B;                        // and
            4'h7: ALUResult = A << B[4:0];                  // sll (mask to 5 bits)       
            4'h8: ALUResult = A >> B[4:0];                  // srl (logical)               
            4'h9: ALUResult = (sA < sB) ? 32'd1 : 32'd0;    // slt (signed)

            default: ALUResult = 32'd0;
        endcase

    end
endmodule
