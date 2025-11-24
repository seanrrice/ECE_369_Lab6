`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: ID_EX
// Desc : ID?EX pipeline register (controls + data), explicit storage style.
// Notes: - Outputs are driven continuously from registered q-values.
//        - ALUOp is 2 bits.
//        - Add reset/enable/flush if you plan to handle hazards; included here.
//////////////////////////////////////////////////////////////////////////////////

module ID_EX (
    input clk,
    input reset,        // async reset to zeros
    input enable,       // 1=advance, 0=stall (hold outputs) // FIXME may not need it
    input flush,        // 1=insert bubble (zeros) on this edge
    

    //inputs from Controller
    input  [1:0]       RegDst_in, MemToReg_in,
    input              RegWrite_in, ALUSrc_in, extOp_in,
    input  [1:0]       ALUOp_in,
    input              MemRead_in, MemWrite_in,
    input  [1:0]       loadWidth_in,
    input              loadUnsigned_in,
    input  [1:0]       storeWidth_in,
    input              IsShift_in,

    //other inputs from ID stage
    input      [31:0]  ReadData1_in,
    input      [31:0]  ReadData2_in,
    input      [31:0]  SignExtend_in, // sign-extended immediate
    input      [5:0]   OpCode_in,
    input      [4:0]   Rt_in,
    input      [4:0]   Rd_in,
    input      [5:0]   Funct_in,
    input      [31:0]  PC_in,         // typically PC+4
    input      [31:0]  PCPlus8_in,
    input      [31:0]  Shamt_in,

    //Control outputs
    output wire   [1:0]       RegDst_out, MemToReg_out,
    output wire               RegWrite_out, ALUSrc_out, extOp_out,
    output wire   [1:0]       ALUOp_out,
    output wire               MemRead_out, MemWrite_out,
    output wire   [1:0]       loadWidth_out,
    output wire               loadUnsigned_out,
    output wire   [1:0]       storeWidth_out,
    output wire               IsShift_out,

    
    //other outputs from ID stage
    output wire [31:0] ReadData1_out,
    output wire [31:0] ReadData2_out,
    output wire [31:0] SignExtend_out,
    output wire  [5:0] OpCode_out,
    output wire  [4:0] Rt_out,
    output wire  [4:0] Rd_out,
    output wire  [5:0] Funct_out,
    output wire [31:0] PC_out,
    output wire [31:0] PCPlus8_out,
    output wire [31:0] Shamt_out
);
    //controller signals
    reg [1:0]   RegDst_q, MemToReg_q;
    reg         RegWrite_q, ALUSrc_q, extOp_q;
    reg [1:0]   ALUOp_q;
    reg         MemRead_q, MemWrite_q;
    reg [1:0]   loadWidth_q;
    reg         loadUnsigned_q;
    reg [1:0]   storeWidth_q;  
    reg         IsShift_q;
 

    // Data
    reg [31:0] ReadData1_q, ReadData2_q, SignExtend_q, PC_q;
    reg [5:0]  OpCode_q;
    reg [4:0]  Rt_q, Rd_q;
    reg [5:0]  Funct_q;
    reg [31:0] PCPlus8_q;
    reg [5:0]  Shamt_q;
    
    assign RegDst_out           =   RegDst_q;
    assign MemToReg_out         =   MemToReg_q;
    assign MemWrite_out         =   MemWrite_q;
    assign RegWrite_out         =   RegWrite_q;
    assign ALUSrc_out           =   ALUSrc_q;
    assign extOp_out            =   extOp_q;
    assign ALUOp_out            =   ALUOp_q;
    assign MemRead_out          =   MemRead_q;
    assign loadWidth_out        =   loadWidth_q;
    assign loadUnsigned_out     =   loadUnsigned_q;
    assign storeWidth_out       =   storeWidth_q;
    assign PCPlus8_out          =   PCPlus8_q;
    assign IsShift_out          =   IsShift_q;
    assign Shamt_out            =   Shamt_q;
    assign OpCode_out           =   OpCode_q;
    assign Rt_out               =   Rt_q;
    assign Rd_out               =   Rd_q;
    assign Funct_out            =   Funct_q;
    assign PC_out               =   PC_q;
    
    assign ReadData1_out        =   ReadData1_q;
    assign ReadData2_out        =   ReadData2_q;
    assign SignExtend_out       =   SignExtend_q;


    always @(posedge clk or posedge reset) begin
        if (reset)
         begin
            // controls             QUESTION: should these be set to all 0 or to Controler default values?
            RegWrite_q   <= 1'b0;
            ALUSrc_q     <= 1'b0;
            MemWrite_q   <= 1'b0;
            MemRead_q    <= 1'b0;
            ALUOp_q      <= 2'b00;
            RegDst_q     <= 2'b00;
            MemToReg_q   <= 2'b00;
            loadWidth_q  <= 2'b00;
            loadUnsigned_q <= 1'b0;
            storeWidth_q <= 2'b00;
            extOp_q      <= 1'b0;
            IsShift_q    <= 1'b0;
            
            
            // data
            ReadData1_q  <= 32'b0;
            ReadData2_q  <= 32'b0;
            SignExtend_q <= 32'b0;
            OpCode_q     <= 6'b0;
            Rt_q         <= 5'b0;
            Rd_q         <= 5'b0;
            Funct_q      <= 6'b0;
            PC_q         <= 32'b0;
            PCPlus8_q    <= 32'b0;
            Shamt_q      <= 32'b0;
        end 
        else if (enable) begin
            if (flush)
            begin
                // bubble = zero the controls (and commonly zero data too)
                RegWrite_q   <= 1'b0;
                ALUSrc_q     <= 1'b0;
                MemWrite_q   <= 1'b0;
                MemRead_q    <= 1'b0;
                ALUOp_q      <= 2'b00;
                RegDst_q     <= 2'b00;
                MemToReg_q   <= 2'b00;
                loadWidth_q  <= 2'b00;
                loadUnsigned_q <= 1'b0;
                storeWidth_q <= 2'b00;
                extOp_q      <= 1'b0;
                IsShift_q    <= 1'b0;
                
                // zero data as well (safe default; optional per your design)
                ReadData1_q  <= 32'b0;
                ReadData2_q  <= 32'b0;
                SignExtend_q <= 32'b0;
                OpCode_q     <= 6'b0;
                Rt_q         <= 5'b0;
                Rd_q         <= 5'b0;
                Funct_q      <= 6'b0;
                PC_q         <= 32'b0;
                PCPlus8_q    <= PCPlus8_in;
                Shamt_q      <= 32'b0;
            end 
            else begin
                // normal capture
                RegDst_q            <= RegDst_in;       
                MemToReg_q          <= MemToReg_in;
                RegWrite_q          <= RegWrite_in;
                ALUSrc_q            <= ALUSrc_in;
                extOp_q             <= extOp_in;
                ALUOp_q             <= ALUOp_in;
                MemRead_q           <= MemRead_in;
                MemWrite_q          <= MemWrite_in;
                loadWidth_q         <= loadWidth_in;
                loadUnsigned_q      <= loadUnsigned_in;
                storeWidth_q        <= storeWidth_in;  
                IsShift_q           <= IsShift_in;
                
                ReadData1_q  <= ReadData1_in;
                ReadData2_q  <= ReadData2_in;
                SignExtend_q <= SignExtend_in;
                OpCode_q     <= OpCode_in;
                Rt_q         <= Rt_in;
                Rd_q         <= Rd_in;
                Funct_q      <= Funct_in;
                PC_q         <= PC_in;
                PCPlus8_q    <= PCPlus8_in;
                Shamt_q      <= Shamt_in;
            end
        end

    end



endmodule
