`timescale 1ns / 1ps

module dataMemory(
    input clk,
    input [31:0]DataIn,
    input [31:0]Daddr,
    input mWR,
    input DBDataSrc,
    output [31:0]DataOut,
    output [31:0]DB
);
    
    integer i;  
    reg [7:0] memory [0:1023];      
    assign DataOut = Daddr<1021?{memory[Daddr],memory[Daddr+1],memory[Daddr+2],memory[Daddr+3]}:0;
    assign DB = DBDataSrc?DataOut:Daddr;

    always @(posedge clk)begin 
        if(mWR && Daddr < 1021)begin
            memory[Daddr] = DataIn[31:24];
            memory[Daddr+1] = DataIn[23:16];
            memory[Daddr+2] = DataIn[15:8];
            memory[Daddr+3] = DataIn[7:0];
        end
    end
    

    initial begin
        for (i = 0; i < 1024; i = i + 1) memory[i] = 0;
    end
endmodule
