`timescale 1ns / 1ps
// EX ? MEM pipeline register
module EX_MEM (
    input  wire        clk,
    input  wire        reset,          // async, active-high
    input  wire        enable,         // 1=advance, 0=stall
    input  wire        flush,          // 1=insert bubble

    // ----- Control (to MEM / WB) -----
    input  wire [1:0]  MemToReg_in,
    input  wire        RegWrite_in,
    input  wire        MemRead_in,
    input  wire        MemWrite_in,
    input  wire        Branch_in,
    input  wire [2:0]  branchType_in,   // e.g., BEQ/BNE/BLTZ/BGEZ/etc.
    input  wire [1:0]  loadWidth_in,    // byte/half/word
    input  wire        loadUnsigned_in, // LBU/LHU
    input  wire [1:0]  storeWidth_in,   // SB/SH/SW
    input  wire        DoJump_in, DoJR_in, IsJal_in,

    // ----- Data / flags (from EX) -----
    input  wire [31:0] PCBranch_in,     // branch target (PC+4 + (imm<<2))
    input  wire        Zero_in,         // ALU compare flag
    input  wire [31:0] ALUResult_in,    // ALU result (addr/data)
    input  wire [31:0] WriteData_in,    // value to write to memory (from EX ReadData2)
    input  wire [4:0]  WriteReg_in,     // destination reg (rd/rt selected in EX)
    
    input  wire [31:0] JRTarget_in, JumpTarget_in,
    input  wire        BranchTaken_in,
    input  wire [31:0] PCPlus8_in, PCPlus4_in,

    // ----- Outputs to MEM / WB -----
    output wire [1:0]  MemToReg_out,
    output wire        RegWrite_out,
    output wire        MemRead_out,
    output wire        MemWrite_out,
    output wire        Branch_out,
    output wire [2:0]  branchType_out,
    output wire [1:0]  loadWidth_out,
    output wire        loadUnsigned_out,
    output wire [1:0]  storeWidth_out,
    
    output  wire        DoJump_out, DoJR_out, IsJal_out,

    output wire [31:0] PCBranch_out,
    output wire        Zero_out,
    output wire [31:0] ALUResult_out,
    output wire [31:0] WriteData_out,
    output wire [4:0]  WriteReg_out,
    
    output  wire [31:0] JRTarget_out, JumpTarget_out,
    output  wire        BranchTaken_out,
    output  wire [31:0] PCPlus8_out, PCPlus4_out
);

    // ---- Registered storage ----
    reg [1:0]  MemToReg_q;
    reg        RegWrite_q, MemRead_q, MemWrite_q, Branch_q;
    reg [2:0]  branchType_q;
    reg [1:0]  loadWidth_q, storeWidth_q;
    reg        loadUnsigned_q;
    reg        DoJump_q, DoJR_q, IsJal_q;
    

    reg [31:0] PCBranch_q, ALUResult_q, WriteData_q;
    reg        Zero_q;
    reg [4:0]  WriteReg_q;
    
    reg [31:0] JRTarget_q, JumpTarget_q;
    reg        BranchTaken_q;
    reg [31:0] PCPlus8_q, PCPlus4_q;

    // ---- Reset/flush helpers ----
    localparam [1:0]  Z2 = 2'b00;
    localparam [2:0]  Z3 = 3'b000;
    localparam [4:0]  Z5 = 5'b00000;
    localparam [31:0] Z32 = 32'h0000_0000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // controls
            MemToReg_q      <= Z2;
            RegWrite_q      <= 1'b0;
            MemRead_q       <= 1'b0;
            MemWrite_q      <= 1'b0;
            Branch_q        <= 1'b0;
            branchType_q    <= Z3;
            loadWidth_q     <= Z2;
            loadUnsigned_q  <= 1'b0;
            storeWidth_q    <= Z2;
            DoJump_q       <= 1'b0;
            DoJR_q         <= 1'b0;
            IsJal_q        <= 1'b0;
            // data/flags
            PCBranch_q      <= Z32;
            Zero_q          <= 1'b0;
            ALUResult_q     <= Z32;
            WriteData_q     <= Z32;
            WriteReg_q      <= Z5;
            JRTarget_q      <= Z32;
            JumpTarget_q    <= Z32;
            BranchTaken_q   <= 1'b0;
            PCPlus8_q       <= Z32;  
            PCPlus4_q       <= Z32;
            
        end else if (enable) begin
            if (flush) begin
                // bubble: zero the controls (and data for safety)
                MemToReg_q      <= Z2;
                RegWrite_q      <= 1'b0;
                MemRead_q       <= 1'b0;
                MemWrite_q      <= 1'b0;
                Branch_q        <= 1'b0;
                branchType_q    <= Z3;
                loadWidth_q     <= Z2;
                loadUnsigned_q  <= 1'b0;
                storeWidth_q    <= Z2;
                DoJump_q       <= 1'b0;
                DoJR_q         <= 1'b0;
                IsJal_q        <= 1'b0;

                PCBranch_q      <= Z32;
                Zero_q          <= 1'b0;
                ALUResult_q     <= Z32;
                WriteData_q     <= Z32;
                WriteReg_q      <= Z5;
                JRTarget_q      <= Z32;
                JumpTarget_q    <= Z32;
                BranchTaken_q   <= 1'b0;
                PCPlus8_q       <= Z32;  
                PCPlus4_q       <= Z32;
            end
            else begin
                // normal capture
                MemToReg_q      <= MemToReg_in;
                RegWrite_q      <= RegWrite_in;
                MemRead_q       <= MemRead_in;
                MemWrite_q      <= MemWrite_in;
                Branch_q        <= Branch_in;
                branchType_q    <= branchType_in;
                loadWidth_q     <= loadWidth_in;
                loadUnsigned_q  <= loadUnsigned_in;
                storeWidth_q    <= storeWidth_in;
                DoJump_q        <= DoJump_in;
                DoJR_q          <= DoJR_in;
                IsJal_q         <= IsJal_in;

                PCBranch_q      <= PCBranch_in;
                Zero_q          <= Zero_in;
                ALUResult_q     <= ALUResult_in;
                WriteData_q     <= WriteData_in;
                WriteReg_q      <= WriteReg_in;
                JRTarget_q      <= JRTarget_in;
                JumpTarget_q    <= JumpTarget_in;
                BranchTaken_q   <= BranchTaken_in;
                PCPlus8_q       <= PCPlus8_in; 
                PCPlus4_q       <= PCPlus4_in;
            end
        end
        // else: hold values on stall
    end

    // ---- Continuous outputs ----
    assign MemToReg_out     = MemToReg_q;
    assign RegWrite_out     = RegWrite_q;
    assign MemRead_out      = MemRead_q;
    assign MemWrite_out     = MemWrite_q;
    assign Branch_out       = Branch_q;
    assign branchType_out   = branchType_q;
    assign loadWidth_out    = loadWidth_q;
    assign loadUnsigned_out = loadUnsigned_q;
    assign storeWidth_out   = storeWidth_q;
    assign DoJump_out       = DoJump_q;
    assign DoJR_out         = DoJR_q;
    assign IsJal_out        = IsJal_q;
                
    assign PCBranch_out     = PCBranch_q;
    assign Zero_out         = Zero_q;
    assign ALUResult_out    = ALUResult_q;
    assign WriteData_out    = WriteData_q;
    assign WriteReg_out     = WriteReg_q;
    assign JRTarget_out     = JRTarget_q;
    assign JumpTarget_out   = JumpTarget_q;
    assign BranchTaken_out  = BranchTaken_q;
    assign PCPlus8_out      = PCPlus8_q; 
    assign PCPlus4_out      = PCPlus4_q;

endmodule
