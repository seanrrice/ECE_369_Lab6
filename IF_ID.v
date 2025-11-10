`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: IF_ID
// Desc : IF?ID pipeline register (holds PC and instruction).
// Notes: - Uses explicit internal registers q.
//        - Outputs continuously reflect stored values.
//        - Includes reset, enable (stall), and flush (bubble).
//////////////////////////////////////////////////////////////////////////////////

module IF_ID (
    input         clk,
    input         reset,         // async reset ? zero outputs
    input         enable,        // 1=advance, 0=stall
    input         flush,         // 1=insert bubble (zeros)

    // Inputs from IF stage
    input  [31:0] PC_in,         // usually PC+4
    input  [31:0] Instruction_in,

    // Outputs to ID stage
    output wire [31:0] PC_out,
    output wire [31:0] Instruction_out
);

    reg [31:0] PC_q;
    reg [31:0] Instruction_q;

    
    assign PC_out         = PC_q;
    assign Instruction_out= Instruction_q;
   
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_q         <= 32'b0;
            Instruction_q<= 32'b0;
        end else if (enable) begin
            if (flush) begin
                // Insert bubble (NOP)
                PC_q          <= 32'b0;
                Instruction_q <= 32'b0;
            end else begin
                // Normal capture
                PC_q          <= PC_in;
                Instruction_q <= Instruction_in;
            end
        end
        // else: enable==0 ? hold (stall)
    end

endmodule