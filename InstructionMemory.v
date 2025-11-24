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
    reg [31:0] memory [0:1023];   // one column vector with 1024 rows
                                 // each row has one 32 bit word
    
    //initialize contents
    integer i;
    
    initial begin
        // instantiate the memory with dummy information to start
        for (i = 0; i < 1024; i = i + 1) begin
             memory[i] = 0;
        end
        $display("IMEM: Loding lab6FullTest.mem");
        $readmemh("lab6FullTest.mem", memory);
          //Sanity dump first few words
          $display("IMEM[0]=%08h", memory[0]);
          $display("IMEM[1]=%08h", memory[1]);
          $display("IMEM[2]=%08h", memory[2]);
          $display("IMEM[3]=%08h", memory[3]);
          $display("IMEM[4]=%08h", memory[4]);
          $display("IMEM[5]=%08h", memory[5]);
          $display("IMEM[6]=%08h", memory[6]);
          $display("IMEM[7]=%08h", memory[7]);
          $display("IMEM[8]=%08h", memory[8]);
          $display("IMEM[9]=%08h", memory[9]);
          $display("IMEM[10]=%08h", memory[10]);
          $display("IMEM[11]=%08h", memory[11]);

         
    end
    
    always @ (*) begin
       // access memory indices. 
       // Address[1:0] used for accessing individual bytes in a word
       // Address[11:2] 10 bit addresses live here
       // Address[31:12] unused addresses due to 1024 word memory
        Instruction = memory[Address[11:2]];
    end
    
    
    
endmodule
