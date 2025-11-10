`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - data_memory.v
// Description - 32-Bit wide data memory.
//
// INPUTS:-
// Address: 32-Bit address input port.
// WriteData: 32-Bit input port.
// Clk: 1-Bit Input clock signal.
// MemWrite: 1-Bit control signal for memory write.
// MemRead: 1-Bit control signal for memory read.
//
// OUTPUTS:-
// ReadData: 32-Bit registered output port.
//
// FUNCTIONALITY:-
// Design the above memory similar to the 'RegisterFile' model in the previous 
// assignment.  Create a 1K memory, for which we need 10 bits.  In order to 
// implement byte addressing, we will use bits Address[11:2] to index the 
// memory location. The 'WriteData' value is written into the address 
// corresponding to Address[11:2] in the positive clock edge if 'MemWrite' 
// signal is 1. 'ReadData' is the value of memory location Address[11:2] if 
// 'MemRead' is 1, otherwise, it is 0x00000000. The reading of memory is not 
// clocked.
//
// you need to declare a 2d array. in this case we need an array of 1024 (1K)  
// 32-bit elements for the memory.   
// for example,  to declare an array of 256 32-bit elements, declaration is: reg[31:0] memory[0:255]
// if i continue with the same declaration, we need 8 bits to index to one of 256 elements. 
// however , address port for the data memory is 32 bits. from those 32 bits, least significant 2 
// bits help us index to one of the 4 bytes within a single word. therefore we only need bits [9-2] 
// of the "Address" input to index any of the 256 words. 
////////////////////////////////////////////////////////////////////////////////

module DataMemory(Address, WriteData, Clk, ByteEnable, MemWrite, MemRead, ReadData); 

    input [31:0] Address; 	// Input Address 
    input [31:0] WriteData; // Data that needs to be written into the address 
    input Clk;
    input [3:0] ByteEnable; // selects bytes to write over for store operations
    input MemWrite; 		// Control signal for memory write 
    input MemRead; 			// Control signal for memory read 

    output wire[31:0] ReadData; // Contents of memory location at Address
    integer i;

    /* Please fill in the implementation here */
    //declare memory
    reg[31:0]memory[0:1023];
    wire[9:0] idx = Address[11:2];
    
    initial begin
    
    for (i = 0; i < 1024; i = i + 1) begin
        memory[i] = 32'h0;
    end
    end
    
    //Asynchronous read
   assign ReadData = MemRead ? memory[idx] : 32'h0000_0000;

    
   //Byte mask build for store logic
   wire[31:0] byte_mask = 
        { {8{ByteEnable[3]}}, {8{ByteEnable[2]}}, {8{ByteEnable[1]}}, {8{ByteEnable[0]}} };
   always@ (posedge Clk) begin
    if (MemWrite) begin
        if(ByteEnable == 4'b1111)begin                      //store word
             memory[idx] <= WriteData;
        end
        else if (ByteEnable != 4'b0000) begin               //store approprite byte, preserve other bytes using bit masking
            memory[idx] <= (memory[idx] & ~byte_mask) | (WriteData & byte_mask);
        end
            //else: ByteEnable == 4'b0 -> no write
     end
   end
endmodule
