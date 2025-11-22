`timescale 1ns / 1ps

module BranchLogic(
    input  wire [31:0] A,          // rs
    input  wire [31:0] B,          // rt (used for BEQ/BNE)
    input  wire        Branch,     // master branch enable from controller
    input  wire [2:0]  BranchType, // BEQ/BNE/BGEZ/BGTZ/BLEZ/BLTZ/BR_NONE
    output reg         BranchTaken // 1 when branch should be taken
);

    // Encodings (match your controller!)
    localparam BEQ     = 3'b000,
               BNE     = 3'b001,
               BGEZ    = 3'b010,
               BGTZ    = 3'b011,
               BLEZ    = 3'b100,
               BLTZ    = 3'b101,
               BR_NONE = 3'b111;

    // Signed view of A for <, <=, >, >= against 0
    wire signed [31:0] sA = A;
    wire signed [31:0] sB = B;

    // Basic predicates
    wire eq   = (sA == sB);
    wire neq  = ~eq;
    wire ltz  = (sA <  0);
    wire gtz  = (sA >  0);
    wire lez  = (sA <= 0);
    wire gez  = (sA >= 0);

    reg cond_match;

    always @* begin
        // defaults to avoid latches
        cond_match  = 1'b0;
        BranchTaken = 1'b0;

        // Select condition based on BranchType
        case (BranchType)
            BEQ:     cond_match = eq;
            BNE:     cond_match = neq;
            BGEZ:    cond_match = gez;
            BGTZ:    cond_match = gtz;
            BLEZ:    cond_match = lez;
            BLTZ:    cond_match = ltz;
            default: cond_match = 1'b0; // BR_NONE or undefined -> not taken
        endcase

        // Final gate with Branch enable
        BranchTaken = Branch & cond_match;
    end

endmodule
