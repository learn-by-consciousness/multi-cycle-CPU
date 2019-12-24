`timescale 1ns / 1ps

module npc(
    input clk,
    input reset,
    input PCWr,
    input [1:0]PCSrc,
    input [31:0]Imm32,
    input [25:0]Imm26,
    input [31:0]bussA,
    output reg[31:0]PC,
    output reg[31:0]nextPC,
    output reg[31:0]PC4
    );
    
    
    always @(posedge clk, posedge reset)begin
        if(PCWr)
            PC=nextPC;
        if(reset)
            PC = 0;
    end

    always @(PC, Imm26, Imm32, bussA, reset, PCWr, PCSrc)begin
        PC4 = PC + 4;
        case (PCSrc)
            1:  nextPC = PC4 + (Imm32 << 2);
            2:  nextPC = bussA;
            3:  nextPC = {nextPC[31:28],Imm26,2'b0};
            default: nextPC = PC4;
        endcase

        if(reset)
            nextPC = 0;
    end

    initial begin
        PC <= 0;
        nextPC <= 0;
    end
endmodule
