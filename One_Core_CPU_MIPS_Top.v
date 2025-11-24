 `timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Team Members:
// Overall percent effort of each team member: 
// 
// ECE369A - Computer Architecture
// Laboratory 4 (PostLab)
// Module - InstructionDecodeUnit.v
// Description - Decodes the instruction from the instruction fetch unit
// and converts bits 15 - 0 from 16 bit to a 32 bit value. This unit passes
// its outputs to the inputs of the execute unit.
//
// INPUTS:-
// Instruction: 32-bit instruction from instruction fetch unit
// WriteData: 32-bit data to be writen to a register in the register file
// WriteRegister: 5-bit value to select 1 of 32 registers to store WriteData in 
// RegWrite: 1-bit value from the control unit determining if reg file should write
// Clk: Input clock signal
//
// OUTPUTS:-
// ReadData1: 32-bit data stored in ReadRegister1 inside the register file
// ReadData2: 32-bit data stored in ReadRegister2 inside the register file
// InstSignExtOut: 32-bit instruction value from the sign extend file
// InstMuxZero: 5-bit portion of instruction passed to mux in next stage of pipeline
// InstMuxOne: 5-bit portion of instruction passed to mux in next stage of pipeline
//
// FUNCTIONALITY:-
// The RegisterFile and SignExtend modules are not connected together here per
// the datapath pipeline. This InstructionDecodeUnit takes in an instruction and
// a control signal and passes on the values of the registers given the input and
// the instruction. This module stores write register data into the write register
// with information coming from a later stage in the pipeline

//NOTE: loadUnsigned detracts from naming convention
//
//////////////////////////////////////////////////////////////////////////////// 
 
 module One_Core_CPU_Mips_Top(Clk, Reset, PCAddDisplay, WriteDataDisplay);   
    
    input Clk, Reset;
    output [31:0] PCAddDisplay;
    output [31:0] WriteDataDisplay;
 
 // -------------------------------------Wire nets connecting submodules--------------------------------
 
    wire [31:0] IF_Instruction;
    wire [31:0] IF_PCResult;
    wire [31:0] IF_PCAddResult;
    
    //for the IF_ID register -- to be implemented with hazard detection control unit
    wire IF_ID_Enable;
    wire IF_ID_Flush;
    
    wire ID_EX_Enable;       
    assign ID_EX_Enable = 1'b1;      //always enabled       
    wire ID_EX_Flush;
    
    wire ID_PCWrite;                        //PC stalls if set to 0
    
    
    wire [31:0] ID_Instruction;
    wire [31:0] ID_InstSignExtOut;
    wire [31:0] ID_PCAddResult;
    wire [31:0] ID_ReadData1; 
    wire [31:0] ID_ReadData2;
    
    //for jump instruction
    wire [31:0] ID_JumpTarget; 
    wire [31:0] ID_JRTarget;
    wire [31:0] ID_PCPlus8;        //for Jal 
    wire [31:0] ID_Shamt;
    wire [4:0]  ID_Rs;
    wire [4:0]  ID_Rt;
    wire [4:0]  ID_Rd;
    wire [5:0]  ID_Funct;
    wire [5:0]  ID_OpCode;
    wire        ID_BranchTaken;
    wire [31:0] ID_BranchTarget;
    wire [31:0] ID_NextPC;
   
    wire [31:0] EX_ReadData1;
    wire [31:0] EX_ReadData2;
    wire [31:0] EX_InstSignExtOut;
    wire [31:0] EX_LeftShiftOut;
    wire [31:0] EX_ExecutionAdderResult;
    wire [4:0]  EX_WriteRegister;
    wire [3:0]  EX_ALUControl;
    wire [31:0] EX_ALUResult;
    wire [31:0] EX_ALUInputA;
    wire [31:0] EX_ALUInputB;
    wire [31:0] EX_RdInstMuxOut;
    wire [31:0] EX_PCAddResult;
    
    wire [31:0] EX_PCPlus8;        //for Jal 
    wire [31:0] EX_PCPlus4;        //for mux in MEM stage determining next PC value
    wire [31:0] EX_Shamt;
    wire [4:0]  EX_Rt, EX_Rd;
    wire [5:0]  EX_Funct;
    wire [5:0]  EX_OpCode;
    
    wire [31:0] MEM_MemReadData;
    wire [31:0] MEM_ALUResult;
    wire [31:0] MEM_ReadData2;
    wire [4:0]  MEM_WriteRegister;
    wire [31:0] MEM_ExecutionAdderResult;
    wire [31:0] MEM_PCPlus8, MEM_PCPlus4;                    //delete MEM_PCPlus4?
    wire [31:0] MEM_StoreData;
    
    wire [31:0] WB_ALUResult;
    wire [31:0] WB_MemReadData;
    wire [4:0]  WB_WriteRegister;
    wire [31:0] WB_WriteData;
    wire [31:0] WB_PCPlus8;
    
//----------------------------------------------- Control signals---------------------------------------------------------
    //Controls ID stage
  wire  [1:0]  ID_RegDst, ID_MemToReg;
  wire         ID_RegWrite, ID_ALUSrc, ID_Branch, ID_ExtOp;
  wire  [1:0]  ID_ALUOp;
  wire         ID_MemRead, ID_MemWrite;
  wire  [2:0]  ID_BranchType;
  wire  [1:0]  ID_LoadWidth;
  wire         ID_LoadUnsigned;
  wire  [1:0]  ID_StoreWidth;
  wire         ID_DoJump, ID_DoJR;
  wire         ID_IsShift;
  wire         ID_UsesRs;
  wire         ID_UsesRt;
  
  
  //Controls EX stage
  wire  [1:0]  EX_RegDst, EX_MemToReg;
  wire         EX_RegWrite, EX_ALUSrc, EX_ExtOp;
  wire  [1:0]  EX_ALUOp;
  wire         EX_MemRead, EX_MemWrite;
  wire  [1:0]  EX_LoadWidth;
  wire         EX_LoadUnsigned;
  wire  [1:0]  EX_StoreWidth;
  wire         EX_IsShift;
  
  //Controls MEM stage                  
  wire  [1:0]  MEM_MemToReg;
  wire         MEM_RegWrite;
  wire         MEM_MemRead, MEM_MemWrite;
  wire  [1:0]  MEM_LoadWidth;
  wire         MEM_LoadUnsigned;
  wire  [1:0]  MEM_StoreWidth;
  wire [1:0]   a;                                   // byte lane within the 32-bit word (used for Load/Store operations)
  wire [3:0]   MEM_ByteEnable;                      //used for Store Operations
  
  //Controls for WB stage               
  wire  [1:0]  WB_MemToReg;
  wire         WB_RegWrite; 
  
  //localParam
  localparam BEQ     = 3'b000,
             BNE     = 3'b001,
             BGEZ    = 3'b010,
             BGTZ    = 3'b011,
             BLEZ    = 3'b100,
             BLTZ    = 3'b101,
             BR_NONE = 3'b111;
      
  
//------------------------------------------------------- Instruction Fetch Stage of Data Path----------------------------------------------------------
    
   // Mux32Bit4To1 Mux32Bit4To1_1(IF_PCAddResult, MEM_ExecutionAdderResult, **JumpTarget**, **JRTarget**, MEM_PCSrc, IF_MuxToPCValue);  //FIXME PCSrc
    ProgramCounter ProgramCounter_1(ID_NextPC, Reset, ID_PCWrite, Clk, IF_PCResult);
    PCAdder PCAdder_1(IF_PCResult, IF_PCAddResult);
    InstructionMemory InstructionMemory_1(IF_PCResult, IF_Instruction);
    
   
    // (IF/ID) Data Path Register - Path to Stage 2
    IF_ID IF_ID_1(
        .clk           (Clk),
        .reset         (Reset),
        .enable        (IF_ID_Enable),             // later replaced by hazard/stall signal
        .flush         (IF_ID_Flush),              // flush if jump or branch is taken
        .PC_in         (IF_PCAddResult),           // usually PC + 4
        .Instruction_in(IF_Instruction),
        .PC_out        (ID_PCAddResult),
        .Instruction_out(ID_Instruction)
    );                 
    
//------------------------------------------------------ Instruction Decode Stage of Data Path-----------------------------------------------------------
    
    RegisterFile RegisterFile_1(ID_Instruction[25:21], ID_Instruction[20:16], WB_WriteRegister, WB_WriteData, WB_RegWrite, Clk, ID_ReadData1, ID_ReadData2);
    SignExtension SignExtension_1(ID_Instruction[15:0], ID_ExtOp, ID_InstSignExtOut);
    HDU HDU_1(
        .ID_Rs(ID_Rs),
        .ID_Rt(ID_Rt),
        .ID_UsesRs(ID_UsesRs),
        .ID_UsesRt(ID_UsesRt),
        .EX_RegWrite(EX_RegWrite),
        .EX_WriteRegister(EX_WriteRegister),
        .MEM_RegWrite(MEM_RegWrite),
        .MEM_WriteRegister(MEM_WriteRegister),
        .PCWrite(ID_PCWrite),
        .IF_ID_Write(IF_ID_Enable),
        .ID_EX_FlushCtrl(ID_EX_Flush)
        
        );
    
    //----------------------------------Resolve Branch & Jumps, Get NextPC value--------------------------------------
  
    BranchLogic BranchLogic1(ID_ReadData1, ID_ReadData2, ID_Branch, ID_BranchType, ID_BranchTaken); 
    assign ID_BranchTarget = {ID_InstSignExtOut << 2} + ID_PCAddResult;
   
    
    assign ID_JumpTarget  = { ID_PCAddResult[31:28], ID_Instruction[25:0], 2'b00};   //jump address
    assign ID_JRTarget    = ID_ReadData1;                 //rs value
    
    assign IF_ID_Flush    = (ID_BranchTaken | ID_DoJump | ID_DoJR) & ID_PCWrite;             //flag to control flush of IF_ID if branch or jump is taken
    
   //Priority mux to determine next PC value
    reg [31:0] next_pc;
    always @* begin
        if(ID_DoJR) begin
            next_pc = ID_JRTarget;
        end
        else if(ID_DoJump) begin
            next_pc = ID_JumpTarget;
        end
        else if(ID_BranchTaken)begin
            next_pc = ID_BranchTarget;
        end
        else begin
            next_pc = IF_PCAddResult;                     //changed from ID_ to IF_
        end
     end 
     
     assign ID_NextPC = next_pc;
   //-----------------------------------------------------------------------------------------------
       
    assign ID_PCPlus8    = ID_PCAddResult + 32'd4;                                  //write register for Jal
    assign ID_Shamt      = {27'b0, ID_Instruction[10:6]};
    
    assign ID_OpCode     = ID_Instruction[31:26];
    assign ID_Rs         = ID_Instruction[25:21];
    assign ID_Rt         = ID_Instruction[20:16];
    assign ID_Rd         = ID_Instruction[15:11];
    assign ID_Funct      = ID_Instruction[5:0];
    

    Controller Controller_1(
          .instruction(ID_Instruction),
          .RegDst(ID_RegDst),
          .MemToReg(ID_MemToReg),
          .RegWrite(ID_RegWrite),
          .ALUSrc(ID_ALUSrc),
          .Branch(ID_Branch),
          .extOp(ID_ExtOp),
          .ALUOp(ID_ALUOp),
          .MemRead(ID_MemRead),
          .MemWrite(ID_MemWrite),
          .branchType(ID_BranchType),
          .loadWidth(ID_LoadWidth),
          .loadUnsigned(ID_LoadUnsigned),
          .storeWidth(ID_StoreWidth),
          .DoJump(ID_DoJump),
          .DoJR(ID_DoJR),
          .IsShift(ID_IsShift),
          .UsesRs(ID_UsesRs),
          .UsesRt(ID_UsesRt)
        );
        

    // (ID/EX) Data Path Register - Path to Stage 3
    ID_EX ID_EX_1(
             
        // Controls
        .clk(Clk),
        .reset(Reset),
        .enable(ID_EX_Enable),
        .flush(ID_EX_Flush),
    
        // Inputs from ID stage (control)
        .RegDst_in(ID_RegDst),
        .MemToReg_in(ID_MemToReg),
        .RegWrite_in(ID_RegWrite),
        .ALUSrc_in(ID_ALUSrc),
        .extOp_in(ID_ExtOp),
        .ALUOp_in(ID_ALUOp),
        .MemRead_in(ID_MemRead),
        .MemWrite_in(ID_MemWrite),
        .loadWidth_in(ID_LoadWidth),
        .loadUnsigned_in(ID_LoadUnsigned),
        .storeWidth_in(ID_StoreWidth),
        .IsShift_in(ID_IsShift),
    
        // Inputs from ID stage (data/regs)
        .ReadData1_in(ID_ReadData1),
        .ReadData2_in(ID_ReadData2),
        .SignExtend_in(ID_InstSignExtOut),
        .OpCode_in(ID_OpCode),
        .Rt_in(ID_Rt),
        .Rd_in(ID_Rd),
        .Funct_in(ID_Funct),
        .PC_in(ID_PCAddResult),
        .PCPlus8_in(ID_PCPlus8),
        .Shamt_in(ID_Shamt),
      
    
        // Outputs to EX stage
        .RegDst_out(EX_RegDst),
        .MemToReg_out(EX_MemToReg),
        .RegWrite_out(EX_RegWrite),
        .ALUSrc_out(EX_ALUSrc),
        .extOp_out(EX_ExtOp),
        .ALUOp_out(EX_ALUOp),
        .MemRead_out(EX_MemRead),
        .MemWrite_out(EX_MemWrite),
        .loadWidth_out(EX_LoadWidth),
        .loadUnsigned_out(EX_LoadUnsigned),
        .storeWidth_out(EX_StoreWidth),
        .IsShift_out(EX_IsShift),
        
        .ReadData1_out(EX_ReadData1),
        .ReadData2_out(EX_ReadData2),
        .SignExtend_out(EX_InstSignExtOut),
        .OpCode_out(EX_OpCode),
        .Rt_out(EX_Rt),
        .Rd_out(EX_Rd),
        .Funct_out(EX_Funct),
        .PC_out(EX_PCAddResult),
        .PCPlus8_out(EX_PCPlus8),
        .Shamt_out(EX_Shamt)
    
);                
                               
                 
//---------------------------------------------------- Execution Stage of Data Path-----------------------------------------------------

    ExecutionAdder ExecutionAdder_1(EX_PCAddResult, EX_LeftShiftOut, EX_ExecutionAdderResult);
    LeftShifter LeftShifter_1(EX_InstSignExtOut, EX_LeftShiftOut);
    Mux32Bit2To1 MuxToALUInputA(EX_ReadData1, EX_ReadData2, EX_IsShift, EX_ALUInputA);                  //selects ALUInput A to be rt for shift operations
    Mux32Bit2To1 RdInstMux(EX_ReadData2, EX_InstSignExtOut, EX_ALUSrc, EX_RdInstMuxOut);                //selects rd or inst to ALU inputB
    Mux32Bit2To1 MuxToALUInputB(EX_RdInstMuxOut, EX_Shamt, EX_IsShift, EX_ALUInputB);                   //selects Shamt for ALUInputB in case for shift operation
    
    ALUControlUnit ALUControlUnit_1 (EX_ALUOp, EX_Funct, EX_OpCode, EX_ALUControl);
    ALU32Bit ALU32Bit_1(EX_ALUInputA, EX_ALUInputB, EX_ALUControl, EX_ALUResult);
    
    assign EX_PCPlus4     = EX_PCAddResult;  
    
    //mux to select Write Register
    assign EX_WriteRegister = 
        (EX_RegDst == 2'b00)? EX_Rt :   //rt
        (EX_RegDst == 2'b01)? EX_Rd :   //rd
                                5'd31;                  //$ra for Jal
    
    
    
    // (EX/MEM) Data Path Register - Path to Stage 4
   
EX_MEM EX_MEM_1 (
    .clk(Clk),
    .reset(Reset),
    .enable(1'b1),
    .flush(1'b0),

    // ----- Control -----
    .MemToReg_in(EX_MemToReg),
    .RegWrite_in(EX_RegWrite),
    .MemRead_in(EX_MemRead),
    .MemWrite_in(EX_MemWrite),
    .loadWidth_in(EX_LoadWidth),
    .loadUnsigned_in(EX_LoadUnsigned),
    .storeWidth_in(EX_StoreWidth),

    // ----- Data / flags -----
    .ALUResult_in(EX_ALUResult),
    .WriteData_in(EX_ReadData2),
    .WriteReg_in(EX_WriteRegister),
    .PCPlus8_in(EX_PCPlus8),
    .PCPlus4_in(EX_PCPlus4),

    // ----- Outputs to MEM / WB -----
    .MemToReg_out(MEM_MemToReg),
    .RegWrite_out(MEM_RegWrite),
    .MemRead_out(MEM_MemRead),
    .MemWrite_out(MEM_MemWrite),
    .loadWidth_out(MEM_LoadWidth),
    .loadUnsigned_out(MEM_LoadUnsigned),
    .storeWidth_out(MEM_StoreWidth),

    .ALUResult_out(MEM_ALUResult),
    .WriteData_out(MEM_ReadData2),
    .WriteReg_out(MEM_WriteRegister),
    .PCPlus8_out(MEM_PCPlus8),
    .PCPlus4_out(MEM_PCPlus4)
);

    
//------------------------------------------Memory Stage of Data Path-----------------------------------------------------
    
    DataMemory DataMemory_1(MEM_ALUResult, MEM_StoreData, Clk, MEM_ByteEnable, MEM_MemWrite, MEM_MemRead, MEM_MemReadData);
    
   
    
 
        // ------------- Load glue (LW/LH/LHU/LB/LBU) ----------------------------------
    // Assumes: MEM_LoadWidth: 00=word, 01=half, 10=byte
    //          MEM_LoadUnsigned: 1=unsigned (LHU/LBU), 0=signed (LH/LB)
    // Inputs:  MEM_MemReadData (32b word from memory), MEM_ALUResult (effective addr)
    assign a = MEM_ALUResult[1:0];   // byte lane within the 32-bit word
    
    reg  [31:0] raw;          // zero-extended slice before final sign/zero extend
    wire [31:0] MEM_LoadData; // final 32-bit value sent to WB
    
    always @* begin
      // defaults to avoid latches
      raw = 32'b0;
    
      case (MEM_LoadWidth)
        2'b00: begin
          // WORD (LW) - requires a == 2'b00 for alignment
          raw = MEM_MemReadData;
        end
    
        2'b01: begin
          // HALF (LH/LHU) - requires a[0] == 0
          // pick lower (a[1]==0) or upper half (a[1]==1)
          raw = (a[1] == 1'b0) ? {16'b0, MEM_MemReadData[15:0]}
                               : {16'b0, MEM_MemReadData[31:16]};
        end
    
        2'b10: begin
          // BYTE (LB/LBU) - any a is fine
          case (a)
            2'b00: raw = {24'b0, MEM_MemReadData[7:0]};
            2'b01: raw = {24'b0, MEM_MemReadData[15:8]};
            2'b10: raw = {24'b0, MEM_MemReadData[23:16]};
            2'b11: raw = {24'b0, MEM_MemReadData[31:24]};
            default: raw = 32'b0;
          endcase
        end
    
        default: raw = 32'b0;
      endcase
    end
    
    // Final sign/zero extension to 32 bits
    assign MEM_LoadData =
      (MEM_LoadWidth == 2'b01) ? (MEM_LoadUnsigned ? raw
                                                   : {{16{raw[15]}}, raw[15:0]}) :
      (MEM_LoadWidth == 2'b10) ? (MEM_LoadUnsigned ? raw
                                                   : {{24{raw[7]}},  raw[7:0]})  :
                                 raw; // word (no extension)
                                 
//--------------------------------Code for Store logic------------------------------------------------
    //wire[31:0] MEM_StoreData;          declared at top of file
    reg[31:0] rt_raw;
    reg [3:0] byte_enable;
    always @* begin
        //defaults
        rt_raw = 32'b0;            //default to avoid latching
        byte_enable = 4'b0000; 
        case(MEM_StoreWidth)
            //SW
            2'b00: begin
                 rt_raw = MEM_ReadData2; 
                 byte_enable = 4'b1111;
            end
            //SH 
            2'b01: begin
                //// position the halfword into low or high halfword
                if(a[1] == 1'b0)begin
                    rt_raw = {16'b0, MEM_ReadData2[15:0]};
                    byte_enable = 4'b0011;
                end
                else begin
                    rt_raw = {MEM_ReadData2[15:0], 16'b0};
                    byte_enable = 4'b1100;
                end
            end
            2'b10: 
                case(a)
                    2'b00: begin
                         rt_raw = {24'b0, MEM_ReadData2[7:0]};
                         byte_enable = 4'b0001;
                    end
                    2'b01: begin
                        rt_raw = {16'b0, MEM_ReadData2[7:0], 8'b0};
                        byte_enable = 4'b0010;
                    end 
                    2'b10: begin
                        rt_raw = {8'b0, MEM_ReadData2[7:0], 16'b0};
                        byte_enable = 4'b0100;
                    end
                    2'b11: begin
                        rt_raw = {MEM_ReadData2[7:0], 24'b0};
                        byte_enable = 4'b1000;
                    end
                    default: begin 
                        rt_raw = 32'b0;
                        byte_enable = 4'b0000;
                    end
                        
                   endcase
                                           
            default: begin
               //keep defaults
            end
        endcase
      end
      
      assign MEM_StoreData = rt_raw;
      assign MEM_ByteEnable = byte_enable;
    
 // -----------------------------End Store logic-----------------------------------------------------------------


 // (MEM/WB) Data Path Register - Path to Stage 5
    
    MEM_WB MEM_WB_1(
        .clk(Clk),
        .reset(Reset),
        .enable(1'b1),
        .flush(1'b0),
        
        .RegWrite_in(MEM_RegWrite),
        .MemToReg_in(MEM_MemToReg),
        .ReadDataMem_in(MEM_LoadData),                  //changed arg to LoadData
        .ALUResult_in(MEM_ALUResult),
        .RegDestination_in(MEM_WriteRegister),         //Right?
        .PCPlus8_in(MEM_PCPlus8),
        
        .RegWrite_out(WB_RegWrite),
        .MemToReg_out(WB_MemToReg),
        .ReadDataMem_out(WB_MemReadData),
        .ALUResult_out(WB_ALUResult),
        .RegDestination_out(WB_WriteRegister),
        .PCPlus8_out(WB_PCPlus8)          
        );
    
 // --------------------Write Back Stage of Data Path------------------------------------------------
    //3 way mux for data to write
    assign WB_WriteData =
        (WB_MemToReg == 2'b00)? WB_ALUResult :
        (WB_MemToReg == 2'b01)? WB_MemReadData  :
        (WB_MemToReg == 2'b10)?(WB_PCPlus8-4) :
                               32'b0 ;         //link value for Jal NOTE: changed to (WB_PCPlus8 - 4) b/c we ommitted the branch delay slot after shifting branches to ID stage
   
   assign WriteDataDisplay  = WB_WriteData;
   
   reg [31:0] pcdisplay;                    
   always @* begin
        if(Reset) begin
            pcdisplay = 32'b0;
        end
        else begin                              
            pcdisplay = WB_PCPlus8 - 8;
        end
    end
        
   assign PCAddDisplay      = pcdisplay;
   
        
endmodule
