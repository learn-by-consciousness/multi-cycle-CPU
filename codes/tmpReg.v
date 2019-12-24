`timescale 1ns / 1ps

module tmpReg(
    input clk,
    input [31:0] In,
    output reg[31:0] Out
);
    always@(posedge clk) Out = In;
    initial Out = 0;

endmodule
