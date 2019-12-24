`timescale 1ns / 1ps

module ALU(
    input [31:0]bussA, 
    input [31:0]bussB, 
    input [31:0]extended,
    input [2:0]AluOp,
    input [4:0]sa,
    input ALUSrcA, 
    input ALUSrcB,
    output reg [31:0]result,
    output sign,
    output zero,
    output reg overFlow
);

    assign zero = (result==0)?1:0;
    assign sign = result[31];
    reg [31:0]A,B;

    always @(sa, bussA, bussB, AluOp, extended)begin
        A = ALUSrcA?sa:bussA;
        B = ALUSrcB?extended:bussB;
        case(AluOp)
            0: begin
                result = A + B;          // add
                overFlow = (A[31] == B[31] && A[31] != result[31]) ? 1 : 0;
            end
            1: begin
                result = A - B;          // sub
                overFlow = (A[31] != B[31] && A[31] != result[31]) ? 1 : 0;
            end
            2: result = (A < B) ? 1 : 0; // cmp
            3:                           // slt
               result = (A < B && A[31] == B[31] ||  A[31] == 1 && B[31] == 0) ? 1 : 0;
            4: result = B << A;          // sll
            5: result = A | B;           // or
            6: result = A & B;           // and
            default: begin               // mov
                result = A;
                overFlow = B ? 1 : 0; // used once
            end
        endcase
    end
endmodule
