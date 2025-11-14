`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 03:52:39 PM
// Design Name: 
// Module Name: HDU
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


module HDU(
    //ID
    input wire [4:0] ID_Rs, ID_Rt,
    input wire ID_UsesRs,               //lets us know if a hazards actually obtains
    input wire ID_UsesRt,
    
    //EX
    input wire EX_RegWrite,
    input wire [4:0] EX_WriteRegister,
    
    //MEM
    input wire MEM_RegWrite,
    input wire [4:0] MEM_WriteRegister,
    
    //Controls
    output reg PCWrite,
    output reg IF_ID_Write,
    output reg ID_EX_FlushCtrl
    
    );
    
    //Conflicts
  
   wire Haz_EX_Rs = (ID_UsesRs && EX_RegWrite && (EX_WriteRegister != 5'b0) && (EX_WriteRegister == ID_Rs));
   wire Haz_EX_Rt = (ID_UsesRt && EX_RegWrite && (EX_WriteRegister != 5'b0) && (EX_WriteRegister == ID_Rt));
   
   wire Haz_MEM_Rs = (ID_UsesRs && MEM_RegWrite && (MEM_WriteRegister != 5'b0) && (MEM_WriteRegister == ID_Rs));
   wire Haz_MEM_Rt = (ID_UsesRt && MEM_RegWrite && (MEM_WriteRegister != 5'b0) && (MEM_WriteRegister == ID_Rt));
   
   wire DataHazard = Haz_EX_Rs | Haz_EX_Rt | Haz_MEM_Rs | Haz_MEM_Rt;
   
   always @* begin
        if (DataHazard) begin
            PCWrite = 1'b0;                 //stalls PC
            IF_ID_Write = 1'b0;             //stalls IF_ID    CHECK IF CORRECT
            ID_EX_FlushCtrl = 1'b1;         //flush ID_EX if Data hazard detected (inserts a bubble)
        end else begin
            PCWrite = 1'b1;
            IF_ID_Write = 1'b1;
            ID_EX_FlushCtrl = 1'b0;      
       end
    end
            
endmodule


