`timescale 1ns / 1ps

module Controller(
  input  wire [31:0] instruction,
  output reg  [1:0]  RegDst, MemToReg,
  output reg         RegWrite, ALUSrc, Branch, extOp,
  output reg  [1:0]  ALUOp,                          
  output reg         MemRead, MemWrite,
  output reg  [2:0]  branchType,
  output reg  [1:0]  loadWidth,
  output reg         loadUnsigned,
  output reg  [1:0]  storeWidth,
  //for jumps
  output reg         DoJump,
  output reg         DoJR,
  output reg         IsShift,
  output reg         UsesRs,
  output reg         UsesRt
);

  // Primary opcodes
  localparam OP_RTYPE = 6'b000000,
             OP_LW    = 6'b100011,
             OP_SW    = 6'b101011,
             OP_BEQ   = 6'b000100,
             OP_BNE   = 6'b000101,
             OP_ADDI  = 6'b001000,
             OP_ANDI  = 6'b001100,
             OP_ORI   = 6'b001101,
             OP_SLTI  = 6'b001010,
             OP_J     = 6'b000010,
             OP_JAL   = 6'b000011,
             OP_LB    = 6'b100000,
             OP_LH    = 6'b100001,
             OP_SB    = 6'b101000,
             OP_SH    = 6'b101001,
             OP_BLEZ  = 6'b000110,
             OP_BGTZ  = 6'b000111,
             OP_REGI  = 6'b000001,
             OP_XORI  = 6'b001110,
             OP_MUL   = 6'b011100;

  // R-type funct
  localparam FUNCT_JR   = 6'b001000,
             FUNCT_SLL  = 6'b000000,
             FUNCT_SRL  = 6'b000010;
             

  // Branch types
  localparam BEQ     = 3'b000,
             BNE     = 3'b001,
             BGEZ    = 3'b010,
             BGTZ    = 3'b011,
             BLEZ    = 3'b100,
             BLTZ    = 3'b101,
             BR_NONE = 3'b111;

  // MemtoReg
  localparam M2R_MEM = 2'b01,                //changed
             M2R_ALU = 2'b00,
             M2R_PC8 = 2'b10;

  // RegDst
  localparam RD_RT = 2'b00,
             RD_RD = 2'b01,
             RD_RA = 2'b10;
             



  wire [5:0] opcode = instruction[31:26];
  wire [4:0] rt     = instruction[20:16];
  wire [5:0] funct  = instruction[5:0];
  wire [4:0] rs     = instruction[25:21];

  always @* begin
    // ---------- Safe defaults ----------
    RegDst       = RD_RT;
    RegWrite     = 1'b0;
    ALUSrc       = 1'b0;
    ALUOp        = 2'b00;
    MemRead      = 1'b0;
    MemWrite     = 1'b0;
    MemToReg     = M2R_ALU;
    Branch       = 1'b0;
    branchType   = BR_NONE;
    loadWidth    = 2'b00;
    loadUnsigned = 1'b0;
    storeWidth   = 2'b00;
    extOp        = 1'b1;              //sign extend by default
    DoJump       = 1'b0;
    DoJR         = 1'b0;
    IsShift      = 1'b0;
    UsesRs       = 1'b0;
    UsesRt       = 1'b0;
    
  //-------------------------NOP------------------------------------------
  
   if(instruction == 32'h0000_0000) begin    
        //keep defaults 
    end
    else case (opcode)
   // -------------------- R-TYPE -----------------------------------
   
      OP_RTYPE: begin
        if (funct == FUNCT_JR) begin
          DoJR = 1'b1;
          UsesRs = 1'b1;
        end
        else if ((funct == FUNCT_SLL || funct == FUNCT_SRL) && (rs == 5'b0)) begin    //shift operation
            IsShift = 1'b1;
            RegDst   = RD_RD;
            RegWrite = 1'b1;
            ALUOp    = 2'b10;
            UsesRt   = 1'b1;
            
        end
        else begin                      //regular R-Type
          RegDst   = RD_RD;
          RegWrite = 1'b1;
          ALUOp    = 2'b10;
          UsesRs   = 1'b1;
          UsesRt   = 1'b1;
        end
      end
    //----------------------MUL----------------------------
      OP_MUL: begin
         RegDst   = RD_RD;
         RegWrite = 1'b1;
         ALUOp    = 2'b01;     //special case bc mul and srl have same opcode
         UsesRs   = 1'b1;
         UsesRt   = 1'b1;
      end
        
      // ---------------- BRANCHES ----------------
      OP_BEQ: begin
        Branch     = 1'b1;
        branchType = BEQ;
        UsesRs     = 1'b1;
        UsesRt     = 1'b1;
      end

      OP_BNE: begin
        Branch     = 1'b1;
        branchType = BNE;
        UsesRs     = 1'b1;
        UsesRt     = 1'b1;
      end

      OP_BLEZ: begin
        Branch     = 1'b1;
        branchType = BLEZ;
        UsesRs     = 1'b1;
      end

      OP_BGTZ: begin
        Branch     = 1'b1;
        branchType = BGTZ;
        UsesRs     = 1'b1;
      end

      OP_REGI: begin
        Branch = 1'b1;
        UsesRs = 1'b1;
        case (rt)
          5'b00000: begin
             branchType = BLTZ;
          end
          5'b00001:begin
             branchType = BGEZ;
          end
        default:  branchType = BR_NONE;
       endcase
      end

      // ---------------- JUMPS ----------------
      OP_J: begin
        DoJump = 1'b1;
      end

      OP_JAL: begin
        DoJump = 1'b1;        //behaves like J (causes jump)
        RegWrite = 1'b1;      // we'll write to $ra in WB
        RegDst   = RD_RA;     // choose $ra as destination
        MemToReg = M2R_PC8;   // choose PC+8 as write data
      end

      // ---------------- IMMEDIATES ----------------
      OP_ADDI: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b00;
        UsesRs   = 1'b1;
      end

      OP_ANDI: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b11;
        extOp    = 1'b0;
        UsesRs   = 1'b1;
      end

      OP_ORI: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b11;
        extOp    = 1'b0;
        UsesRs   = 1'b1;
      end

      OP_XORI: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b11;
        extOp    = 1'b0;
        UsesRs   = 1'b1;
      end

      OP_SLTI: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b11;
        UsesRs   = 1'b1;
      end

      // ---------------- LOADS ----------------
      OP_LW: begin
        RegWrite   = 1'b1;
        ALUSrc     = 1'b1;
        MemRead    = 1'b1;
        MemToReg   = M2R_MEM;
        loadWidth  = 2'b00;
        UsesRs     = 1'b1;
      end

      OP_LB: begin
        RegWrite   = 1'b1;
        ALUSrc     = 1'b1;
        MemRead    = 1'b1;
        MemToReg   = M2R_MEM;
        loadWidth  = 2'b10;
        loadUnsigned = 1'b0;
        UsesRs       = 1'b1;
      end

      OP_LH: begin
        RegWrite   = 1'b1;
        ALUSrc     = 1'b1;
        MemRead    = 1'b1;
        MemToReg   = M2R_MEM;
        loadWidth  = 2'b01;
        loadUnsigned = 1'b0;
        UsesRs       = 1'b1;
      end

      // ---------------- STORES ----------------
      OP_SW: begin
        ALUSrc    = 1'b1;
        MemWrite  = 1'b1;
        storeWidth = 2'b00;
        UsesRs     = 1'b1;
        UsesRt     = 1'b1;
      end

      OP_SB: begin
        ALUSrc    = 1'b1;
        MemWrite  = 1'b1;
        storeWidth = 2'b10;
        UsesRs     = 1'b1;
        UsesRt     = 1'b1;
      end

      OP_SH: begin
        ALUSrc    = 1'b1;
        MemWrite  = 1'b1;
        storeWidth = 2'b01;
        UsesRs     = 1'b1;
        UsesRt     = 1'b1;
      end

      // ---------------- DEFAULT ----------------
      default: begin
        // Keep defaults
      end
    endcase
  end

endmodule
