`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2025 04:35:22 PM
// Design Name: 
// Module Name: One_Core_CPU_Mips_Top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module One_Core_CPU_Mips_Top_tb;

  reg Clk = 0;
  reg Reset = 1;

  // DUT
  One_Core_CPU_Mips_Top dut(.Clk(Clk), .Reset(Reset));

  // 100 MHz clock
  always #5 Clk = ~Clk;

  // Program (hex encodings)
  // 0: ADDI $t1,$zero,1      -> 0x20090001
  // 1: SLL  $t0,$t1,4        -> 0x00094100
  // 2: SRL  $t2,$t0,1        -> 0x00085042
  // 3: BEQ  $zero,$zero,-1   -> 0x1000FFFF   (infinite loop)
//  localparam [31:0] PROG_3 = 32'h1000_FFFF;
//  localparam [31:0] PROG_2 = 32'h0008_5042;
//  localparam [31:0] PROG_1 = 32'h0009_4100;
//  localparam [31:0] PROG_0 = 32'h2009_0001;


  // Init + reset
  initial begin
    // preload instruction memory (hierarchical reference to IMEM array)
    // Adjust "mem" to your internal name if different.
    // If your InstructionMemory uses $readmemh internally, comment this block.
//    dut.InstructionMemory_1.memory[0] = PROG_0; // address 0x00000000
//    dut.InstructionMemory_1.memory[1] = PROG_1; // address 0x00000004
//    dut.InstructionMemory_1.memory[2] = PROG_2; // address 0x00000008
//    dut.InstructionMemory_1.memory[3] = PROG_3; // address 0x0000000C

    // Reset for 2 cycles
    Reset = 1;
    repeat (2) @(posedge Clk);
    Reset = 0;

    // Run a bit, then finish
    repeat (40) @(posedge Clk);
    $finish;
  end

  // Wave dump (optional, for GTKWave)
  initial begin
    $dumpfile("One_Core_CPU_Mips_Top_tb.vcd");
    $dumpvars(0, One_Core_CPU_Mips_Top_tb);
  end

  // Simple commit log from WB stage
  // Prints when a register write happens
  always @(posedge Clk) begin
    if (!Reset && dut.WB_RegWrite) begin
      $display("[%0t] WB: R[%0d] <= %0d  (PC=%0d)",
               $time, dut.WB_WriteRegister, dut.WB_WriteData, dut.IF_PCResult);
      end
    else if(!Reset && dut.MEM_MemWrite) begin
       $display("No register written (Store)   (PC=%0d)", dut.IF_PCResult);
    end
    else if (!Reset && dut.MEM_BranchTaken) begin
        $display("No register written (Branch)   (PC=%0d)", dut.IF_PCResult);
    end
    else if (!Reset && dut.MEM_DoJump) begin
        $display("No register written (Jump)   (PC=%0d)", dut.IF_PCResult);
    end
    
  end
endmodule


  
