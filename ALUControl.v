`timescale 1ns / 1ps

module ALUControlUnit(
    input  wire [1:0] ALUOp,
    input  wire [5:0] funct,
    input  wire [5:0] OpCode,
    input  wire [2:0] branchType,     // used only when ALUOp == 2'b01
    output reg  [3:0] ALUControl
);
    // 4-bit opcodes (example set - make sure your ALU implements these):
    // 0 add, 1 sub, 2 mult, 3 or, 4 xor, 5 nor, 6 and, 7 sll, 8 srl, 9 slt,
    // A cmp_ltz, B cmp_gtz, C cmp_lez, D cmp_gez, E cmp_ne, F nop

    always @* begin
        ALUControl = 4'hF; // default NOP to avoid latches

        case (ALUOp)
            2'b00: begin
                // LW/SW -> add address
                ALUControl = 4'h0;
            end

            2'b01: begin
                // Branches
                // BEQ/BNE typically use SUB + Zero flag,
                // but here we expose explicit compare ops for clarity.
                case (branchType)
                    3'b000: ALUControl = 4'h1; // BEQ -> SUB, use Zero==1
                    3'b001: ALUControl = 4'hE; // BNE -> CMP_NE (or SUB + !Zero)
                    3'b010: ALUControl = 4'hD; // BGEZ -> CMP_GEZ (signed)
                    3'b011: ALUControl = 4'hB; // BGTZ -> CMP_GTZ (signed)
                    3'b100: ALUControl = 4'hC; // BLEZ -> CMP_LEZ (signed)
                    3'b101: ALUControl = 4'hA; // BLTZ -> CMP_LTZ (signed)
                    default: ALUControl = 4'hF; // BR_NONE / unknown
                endcase
            end
           
            2'b10: begin
                // R-type
                case (funct)
                    6'h20: ALUControl = 4'h0; // add
                    6'h22: ALUControl = 4'h1; // sub
                    6'h18: ALUControl = 4'h2; // mult (HI/LO in a full MIPS)
                    6'h25: ALUControl = 4'h3; // or
                    6'h26: ALUControl = 4'h4; // xor
                    6'h27: ALUControl = 4'h5; // nor
                    6'h24: ALUControl = 4'h6; // and
                    6'h00: ALUControl = 4'h7; // sll
                    6'h02: ALUControl = 4'h8; // srl
                    6'h2a: ALUControl = 4'h9; // slt (signed)
                    default: ALUControl = 4'hF; // nop / illegal
                endcase
            end
            
            2'b11: begin
                case(OpCode)
                    6'b001100: ALUControl = 4'h6;     // ANDI
                    6'b001101: ALUControl = 4'h3;     // ORI
                    6'b001110: ALUControl = 4'h4;     // XORI
                    6'b001010: ALUControl = 4'h9;     // SLTI (signed)
                    default:    ALUControl = 4'hF;
                endcase
            end
            
            default: begin
                ALUControl = 4'hF; // nop
            end
            
        endcase
    end
endmodule
