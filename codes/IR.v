`timescale 1ns / 1ps

module IR(
    input clk,
    input IRWr,
    input [31:0]Instruction,
    output reg [31:0] IRInstruction
);
        
    always@(posedge clk)
        if(IRWr) 
            IRInstruction = Instruction;
     
endmodule