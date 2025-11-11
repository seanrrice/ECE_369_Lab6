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
    input  wire [1:0]  loadWidth_in,    // byte/half/word
    input  wire        loadUnsigned_in, // LBU/LHU
    input  wire [1:0]  storeWidth_in,   // SB/SH/SW

    // ----- Data / flags (from EX) -----
    input  wire [31:0] ALUResult_in,    // ALU result (addr/data)
    input  wire [31:0] WriteData_in,    // value to write to memory (from EX ReadData2)
    input  wire [4:0]  WriteReg_in,     // destination reg (rd/rt selected in EX)
    
    input  wire [31:0] PCPlus8_in, PCPlus4_in,

    // ----- Outputs to MEM / WB -----
    output wire [1:0]  MemToReg_out,
    output wire        RegWrite_out,
    output wire        MemRead_out,
    output wire        MemWrite_out,
    output wire [1:0]  loadWidth_out,
    output wire        loadUnsigned_out,
    output wire [1:0]  storeWidth_out,
    
    output wire [31:0] ALUResult_out,
    output wire [31:0] WriteData_out,
    output wire [4:0]  WriteReg_out,
    
    output  wire [31:0] PCPlus8_out, PCPlus4_out
);

    // ---- Registered storage ----
    reg [1:0]  MemToReg_q;
    reg        RegWrite_q, MemRead_q, MemWrite_q;
    reg [1:0]  loadWidth_q, storeWidth_q;
    reg        loadUnsigned_q;
    

    reg [31:0] ALUResult_q, WriteData_q;
    reg [4:0]  WriteReg_q;

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
            loadWidth_q     <= Z2;
            loadUnsigned_q  <= 1'b0;
            storeWidth_q    <= Z2;
           
            // data/flags
            ALUResult_q     <= Z32;
            WriteData_q     <= Z32;
            WriteReg_q      <= Z5;
            PCPlus8_q       <= Z32;  
            PCPlus4_q       <= Z32;
            
        end else if (enable) begin
            if (flush) begin
                // bubble: zero the controls (and data for safety)
                MemToReg_q      <= Z2;
                RegWrite_q      <= 1'b0;
                MemRead_q       <= 1'b0;
                MemWrite_q      <= 1'b0;
                loadWidth_q     <= Z2;
                loadUnsigned_q  <= 1'b0;
                storeWidth_q    <= Z2;

                ALUResult_q     <= Z32;
                WriteData_q     <= Z32;
                WriteReg_q      <= Z5;
                PCPlus8_q       <= Z32;  
                PCPlus4_q       <= Z32;
            end
            else begin
                // normal capture
                MemToReg_q      <= MemToReg_in;
                RegWrite_q      <= RegWrite_in;
                MemRead_q       <= MemRead_in;
                MemWrite_q      <= MemWrite_in;
                loadWidth_q     <= loadWidth_in;
                loadUnsigned_q  <= loadUnsigned_in;
                storeWidth_q    <= storeWidth_in;

                ALUResult_q     <= ALUResult_in;
                WriteData_q     <= WriteData_in;
                WriteReg_q      <= WriteReg_in;
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
    assign loadWidth_out    = loadWidth_q;
    assign loadUnsigned_out = loadUnsigned_q;
    assign storeWidth_out   = storeWidth_q;
                
    assign ALUResult_out    = ALUResult_q;
    assign WriteData_out    = WriteData_q;
    assign WriteReg_out     = WriteReg_q;
    assign PCPlus8_out      = PCPlus8_q; 
    assign PCPlus4_out      = PCPlus4_q;

endmodule
