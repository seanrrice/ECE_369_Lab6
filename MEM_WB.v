`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: MEM_WB
// Desc : MEM?WB pipeline register (controls + data for writeback).
// Style: explicit storage (q) + continuous assigns (push).
//////////////////////////////////////////////////////////////////////////////////

module MEM_WB (
    input              clk,
    input              reset,              // async reset ? zeros
    input              enable,             // 1=advance, 0=stall
    input              flush,              // 1=insert bubble (zeros)


    input              RegWrite_in,
    input       [1:0]  MemToReg_in,

    input      [31:0]  ReadDataMem_in,     // data memory read data (for lw)
    input      [31:0]  ALUResult_in,       // ALU result (for R-type/addi, etc.)
    input       [4:0]  RegDestination_in,  // rd/rt selected earlier
    
    input       [31:0] PCPlus8_in,


    output wire        RegWrite_out,
    output wire  [1:0] MemToReg_out,

    output wire [31:0] ReadDataMem_out,
    output wire [31:0] ALUResult_out,
    output wire  [4:0] RegDestination_out,
    
    output wire [31:0] PCPlus8_out
    
    
);

    reg        RegWrite_q; 
    reg  [1:0] MemToReg_q;
    reg [31:0] ReadDataMem_q, ALUResult_q;
    reg  [4:0] RegDestination_q;
    reg [31:0] PCPlus8_q;


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RegWrite_q        <= 1'b0;
            MemToReg_q        <= 2'b00;
            ReadDataMem_q     <= 32'b0;
            ALUResult_q       <= 32'b0;
            RegDestination_q  <= 5'b0;
            PCPlus8_q         <= 32'b0;
        end else if (enable) begin
            if (flush) begin
                // bubble: zero controls (and data)
                RegWrite_q        <= 1'b0;
                MemToReg_q        <= 2'b00;
                ReadDataMem_q     <= 32'b0;
                ALUResult_q       <= 32'b0;
                RegDestination_q  <= 5'b0;
                PCPlus8_q         <= 32'b0;
            end else begin
                // normal capture from MEM
                RegWrite_q        <= RegWrite_in;
                MemToReg_q        <= MemToReg_in;
                ReadDataMem_q     <= ReadDataMem_in;
                ALUResult_q       <= ALUResult_in;
                RegDestination_q  <= RegDestination_in;
                PCPlus8_q         <= PCPlus8_in;
            end
        end
        // enable==0 ? hold (stall)
    end




    assign RegWrite_out       = RegWrite_q;
    assign MemToReg_out       = MemToReg_q;
    assign ReadDataMem_out    = ReadDataMem_q;
    assign ALUResult_out      = ALUResult_q;
    assign RegDestination_out = RegDestination_q;
    assign PCPlus8_out        = PCPlus8_q;

endmodule