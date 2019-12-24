`timescale 1ns / 1ps

module Registers(
    input clk, 
    input RegWr, 
    input [1:0]RegDst,
    input WrRegDSrc,
    input getHW,
    input [4:0]rs,
    input [4:0]rt,
    input [4:0]rd,
    input [31:0]DB,
    input [31:0]PC4,
    output [31:0]bussA, 
    output [31:0]bussB
);
    reg [4:0] rw;
    reg [31:0] registers[31:0];
    integer i;
    always @(*)begin
        case(RegDst)
            0: rw = 31;
            1: rw = rt;
            2: rw = rd;
            default:rw = 31;
        endcase
    end
    assign bussA = registers[rs];
    assign bussB = registers[rt];
    always @(posedge clk)  //
        if (RegWr && rw)
            registers[rw] = WrRegDSrc? PC4: ( getHW?  {16'b0, DB[31:16]}:DB);
    initial 
        for(i = 0; i < 32; i = i + 1)
            registers[i] <= 0;
endmodule
