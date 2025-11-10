`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory  1
// Module - InstructionMemory.v
// Description - 32-Bit wide instruction memory.
//
// INPUT:-
// Address: 32-Bit address input port.
//
// OUTPUT:-
// Instruction: 32-Bit output port.
//
// FUNCTIONALITY:-
// Similar to the DataMemory, this module should also be byte-addressed
// (i.e., ignore bits 0 and 1 of 'Address'). All of the instructions will be 
// hard-coded into the instruction memory, so there is no need to write to the 
// InstructionMemory.  The contents of the InstructionMemory is the machine 
// language program to be run on your MIPS processor.
//
//
//we will store the machine code for a code written in C later. for now initialize 
//each entry to be its index * 3 (memory[i] = i * 3;)
//all you need to do is give an address as input and read the contents of the 
//address on your output port. 
// 
//Using a 32bit address you will index into the memory, output the contents of that specific 
//address. for data memory we are using 1K word of storage space. for the instruction memory 
//you may assume smaller size for practical purpose. you can use 128 words as the size and 
//hardcode the values.  in this case you need 7 bits to index into the memory. 
//
//be careful with the least two significant bits of the 32bit address. those help us index 
//into one of the 4 bytes in a word. therefore you will need to use bit [8-2] of the input address. 


////////////////////////////////////////////////////////////////////////////////

module InstructionMemory(Address, Instruction); 

    input [31:0] Address;        // Input Address 

    output reg [31:0] Instruction;    // Instruction at memory location Address

    //create memory (128 x 32 bit ROM)
    reg [31:0] memory [0:1024];   // one column vector with 1024 rows
                                 // each row has one 32 bit word
    
    //initialize contents
    integer i;
    
    initial begin
        // instantiate the memory with dummy information to start
        for (i = 0; i < 1024; i = i + 1) begin
             memory[i] = 0;
        end
        //$display("IMEM: loading prog.mem");
       // $readmemh("prog.mem", memory);
         // Sanity dump first few words
//          $display("IMEM[0]=%08h", memory[0]);
//          $display("IMEM[1]=%08h", memory[1]);
//          $display("IMEM[2]=%08h", memory[2]);
//          $display("IMEM[3]=%08h", memory[3]);
//          $display("IMEM[4]=%08h", memory[4]);
//          $display("IMEM[5]=%08h", memory[5]);
//          $display("IMEM[6]=%08h", memory[6]);
//          $display("IMEM[7]=%08h", memory[7]);
//          $display("IMEM[8]=%08h", memory[8]);
//          $display("IMEM[9]=%08h", memory[9]);
//          $display("IMEM[10]=%08h", memory[10]);
//          $display("IMEM[11]=%08h", memory[11]);
//     memory[0] <= 32'h20080000;	//	main:	addi	$t0, $zero, 0
memory[0] <= 32'h20080000;	//	loop:	addi	$t0, $zero, 0
memory[1] <= 32'h00000000;	//		nop
memory[2] <= 32'h00000000;	//		nop
memory[3] <= 32'h00000000;	//		nop
memory[4] <= 32'h00000000;	//		nop
memory[5] <= 32'h00000000;	//		nop
memory[6] <= 32'h20090006;	//		addi	$t1, $zero, 6
memory[7] <= 32'h00000000;	//		nop
memory[8] <= 32'h00000000;	//		nop
memory[9] <= 32'h00000000;	//		nop
memory[10] <= 32'h00000000;	//		nop
memory[11] <= 32'h00000000;	//		nop
memory[12] <= 32'h200a000a;	//		addi	$t2, $zero, 10
memory[13] <= 32'h00000000;	//		nop
memory[14] <= 32'h00000000;	//		nop
memory[15] <= 32'h00000000;	//		nop
memory[16] <= 32'h00000000;	//		nop
memory[17] <= 32'h00000000;	//		nop
memory[18] <= 32'had090000;	//		sw	$t1, 0($t0)
memory[19] <= 32'h00000000;	//		nop
memory[20] <= 32'h00000000;	//		nop
memory[21] <= 32'h00000000;	//		nop
memory[22] <= 32'h00000000;	//		nop
memory[23] <= 32'h00000000;	//		nop
memory[24] <= 32'had0a0004;	//		sw	$t2, 4($t0)
memory[25] <= 32'h00000000;	//		nop
memory[26] <= 32'h00000000;	//		nop
memory[27] <= 32'h00000000;	//		nop
memory[28] <= 32'h00000000;	//		nop
memory[29] <= 32'h00000000;	//		nop
memory[30] <= 32'h8d100000;	//		lw	$s0, 0($t0)
memory[31] <= 32'h00000000;	//		nop
memory[32] <= 32'h00000000;	//		nop
memory[33] <= 32'h00000000;	//		nop
memory[34] <= 32'h00000000;	//		nop
memory[35] <= 32'h00000000;	//		nop
memory[36] <= 32'h8d110004;	//		lw	$s1, 4($t0)
memory[37] <= 32'h00000000;	//		nop
memory[38] <= 32'h00000000;	//		nop
memory[39] <= 32'h00000000;	//		nop
memory[40] <= 32'h00000000;	//		nop
memory[41] <= 32'h00000000;	//		nop
memory[42] <= 32'h02305822;	//		sub	$t3, $s1, $s0
memory[43] <= 32'h00000000;	//		nop
memory[44] <= 32'h00000000;	//		nop
memory[45] <= 32'h00000000;	//		nop
memory[46] <= 32'h00000000;	//		nop
memory[47] <= 32'h00000000;	//		nop
memory[48] <= 32'h000b60c0;	//		sll	$t4, $t3, 3
memory[49] <= 32'h00000000;	//		nop
memory[50] <= 32'h00000000;	//		nop
memory[51] <= 32'h00000000;	//		nop
memory[52] <= 32'h00000000;	//		nop
memory[53] <= 32'h00000000;	//		nop
memory[54] <= 32'h000c6882;	//		srl	$t5, $t4, 2
memory[55] <= 32'h00000000;	//		nop
memory[56] <= 32'h00000000;	//		nop
memory[57] <= 32'h00000000;	//		nop
memory[58] <= 32'h00000000;	//		nop
memory[59] <= 32'h00000000;	//		nop
memory[60] <= 32'h200e0001;	//		addi	$t6, $zero, 1
memory[61] <= 32'h00000000;	//		nop
memory[62] <= 32'h00000000;	//		nop
memory[63] <= 32'h00000000;	//		nop
memory[64] <= 32'h00000000;	//		nop
memory[65] <= 32'h00000000;	//		nop
memory[66] <= 32'ha1ae0001;	//		sb	$t6, 1($t5)
memory[67] <= 32'h00000000;	//		nop
memory[68] <= 32'h00000000;	//		nop
memory[69] <= 32'h00000000;	//		nop
memory[70] <= 32'h00000000;	//		nop
memory[71] <= 32'h00000000;	//		nop
memory[72] <= 32'ha50d0002;	//		sh	$t5, 2($t0)
memory[73] <= 32'h00000000;	//		nop
memory[74] <= 32'h00000000;	//		nop
memory[75] <= 32'h00000000;	//		nop
memory[76] <= 32'h00000000;	//		nop
memory[77] <= 32'h00000000;	//		nop
memory[78] <= 32'h81cb0001;	//		lb	$t3, 1($t6)
memory[79] <= 32'h00000000;	//		nop
memory[80] <= 32'h00000000;	//		nop
memory[81] <= 32'h00000000;	//		nop
memory[82] <= 32'h00000000;	//		nop
memory[83] <= 32'h00000000;	//		nop
memory[84] <= 32'h85ac0002;	//		lh	$t4, 2($t5)
memory[85] <= 32'h00000000;	//		nop
memory[86] <= 32'h00000000;	//		nop
memory[87] <= 32'h00000000;	//		nop
memory[88] <= 32'h00000000;	//		nop
memory[89] <= 32'h00000000;	//		nop
memory[90] <= 32'h08000000;	//		j	loop

         
    end
    
    always @ (*) begin
       // access memory indices. 
       // Address[1:0] used for accessing individual bytes in a word
       // Address[11:2] 10 bit addresses live here
       // Address[31:12] unused addresses due to 1024 word memory
        Instruction = memory[Address[11:2]];
    end
    
    
    
endmodule
