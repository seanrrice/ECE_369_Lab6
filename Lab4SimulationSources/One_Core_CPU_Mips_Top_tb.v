`timescale 1ns / 1ps

module One_Core_CPU_Mips_Top_tb;

  reg Clk   = 0;
  reg Reset = 1;

  // DUT
  One_Core_CPU_Mips_Top dut(.Clk(Clk), .Reset(Reset));

  // 100 MHz clock
  always #5 Clk = ~Clk;

  integer cycle = 0;

  // Init + reset
  initial begin
    // If your InstructionMemory uses $readmemh internally with a file
    // like "lab6_test1.hex", you don't need to preload anything here.
    // Just make sure the file path in InstructionMemory is correct.

    // Reset for 2 cycles
    Reset = 1;
    repeat (2) @(posedge Clk);
    Reset = 0;

    // Run for some cycles then finish
    repeat (80) @(posedge Clk);  // a bit longer now, since we have stalls + loop
    $finish;
  end

  // Wave dump (for GTKWave / Vivado sim)
  initial begin
    $dumpfile("One_Core_CPU_Mips_Top_tb.vcd");
    $dumpvars(0, One_Core_CPU_Mips_Top_tb);
  end

  // Main monitor: track cycles, stalls, and WB commits
  always @(posedge Clk) begin
    if (Reset) begin
      cycle <= 0;
    end else begin
      cycle <= cycle + 1;

      // --- STALL monitor (data hazards) ---
      // Assumes PCWrite/IF_ID_Write/ID_EX_FlushCtrl are wires in top-level.
      if (dut.ID_PCWrite == 1'b0) begin
        $display("[%0t] C%0d STALL: PCWrite=0, IF_ID_Write=%b, ID_EX_FlushCtrl=%b, PC=%0d",
                 $time, cycle, dut.IF_ID_Enable, dut.ID_EX_Flush, dut.IF_PCResult);
      end

      // --- Branch / jump monitor (resolved in ID) ---
      // Assumes these exist in your ID stage / top:
      if (dut.ID_BranchTaken) begin
        $display("[%0t] C%0d BRANCH taken at PC=%0d -> next PC=%0d",
                 $time, cycle, dut.ID_PCAddResult - 4, dut.ID_NextPC);
      end
      if (dut.ID_DoJump) begin
        $display("[%0t] C%0d JUMP at PC=%0d -> next PC=%0d",
                 $time, cycle, dut.ID_PCPlus8 - 8, dut.ID_NextPC);
      end

      // --- Commit log from WB stage (your original) ---
      if (dut.WB_RegWrite) begin
        $display("[%0t] C%0d WB: R[%0d] <= %0d  (PC=%0d)",
                 $time, cycle, dut.WB_WriteRegister, $signed(dut.WB_WriteData), dut.WB_PCPlus8 - 8);
      end
      else if (dut.MEM_MemWrite) begin
        $display("[%0t] C%0d Store: MemWrite=1 (PC=%0d)",
                 $time, cycle, dut.MEM_PCPlus8 - 8);
      end
    end
  end

endmodule
