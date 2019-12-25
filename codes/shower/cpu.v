`timescale 1 ps / 1 ps

module shower(
     input clk_machine,
     input clk_hand,
     input [1:0]sw_hand,
     input reset,
     output [3:0]ands,
     output [7:0]light,
     output reg[4:0]state_light
);
  

  wire [2:0]state; 
  wire overFlow;
  wire [31:0]result;
  wire sign;
  wire zero;
  wire [2:0]ALUOp;
  wire ALUSrcA;
  wire ALUSrcB;
  wire DBDataSrc;
  wire ExtSel;
  wire IRWr;
  wire [1:0]PCSrc;
  wire PCWr;
  wire [1:0]RegDst;
  wire RegWr;
  wire WrRegDSrc;
  wire getHW;
  wire mWR;
  wire [31:0]IRInstruction;
  wire [31:0]bussA;
  wire [31:0]bussA1;
  wire [31:0]bussB;
  wire [31:0]bussB1;
  wire [31:0]DB;
  wire [31:0]DataOut;
  wire [5:0]fun;
  wire [15:0]imm16;
  wire [25:0]imm26;
  wire [5:0]op;
  wire [4:0]rd;
  wire [4:0]rs;
  wire [4:0]rt;
  wire [4:0]sa;
  wire [31:0]imm32;
  wire [31:0]Instruction;
  wire [31:0]PC;
  wire [31:0]PC4;
  wire [31:0]nextPC;
  wire [31:0]Out;


//ÏÔÊ¾Ä£¿é

wire [15:0]tobeprint;
wire [1:0]the_sw;
wire [15:0]num0;
wire [15:0]num1;
wire [15:0]num2;
wire [15:0]num3;
wire [7:0]the_display_data;
assign the_display_data = (the_sw[1])?(the_sw[0]?tobeprint[15:12]:tobeprint[11:8]):(the_sw[0]?tobeprint[7:4]:tobeprint[3:0]);

     binding_32_32 getNum0(.data1(PC), .data2(nextPC), .data(num0));
     binding_5_32 getNum1(.data1(rs), .data2(bussA1), .data(num1));
     binding_5_32 getNum2(.data1(rt), .data2(bussB1), .data(num2));
     binding_32_32 getNum3(.data1(result), .data2(DB), .data(num3));
    
    selector the_selector(
        .data0(num0),
        .data1(num1),
        .data2(num2),
        .data3(num3),
        .data_out(tobeprint),
        .sw(sw_hand)
    );
    clk_div divider(.I_clk(clk_machine),.sw(the_sw),.ands(ands));
    led thelight( .display_data(the_display_data), .dispcode(light) );


     always @(state)begin
        state_light[0] = (state==0 || state == 7) ? 1 : 0;
        state_light[1] = (state==1 || state == 7) ? 1 : 0;
        state_light[2] = (state==2 || state == 7) ? 1 : 0;
        state_light[3] = (state==3 || state == 7) ? 1 : 0;
        state_light[4] = (state==4 || state == 7) ? 1 : 0;
     end

//CPUÄ£¿é

  ALU ALU_0
       (.ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .AluOp(ALUOp),
        .bussA(bussA),
        .bussB(bussB),
        .extended(imm32),
        .overFlow(overFlow),
        .result(result),
        .sa(sa),
        .sign(sign),
        .zero(zero));
  ControlUnit ControlUnit_0
       (.ALUOp(ALUOp),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .DBDataSrc(DBDataSrc),
        .ExtSel(ExtSel),
        .IRWr(IRWr),
        .PCSrc(PCSrc),
        .PCWr(PCWr),
        .RegDst(RegDst),
        .RegWr(RegWr),
        .WrRegDSrc(WrRegDSrc),
        .clk(clk_hand),
        .fun(fun),
        .getHW(getHW),
        .mWR(mWR),
        .op(op),
        .overFlow(overFlow),
        .reset(reset),
        .sign(sign),
        .zero(zero),
        .state(state));
  IR IR_0
       (.IRInstruction(IRInstruction),
        .IRWr(IRWr),
        .Instruction(Instruction),
        .clk(clk_hand));
  Registers Registers_0
       (.DB(DB),
        .PC4(PC4),
        .RegDst(RegDst),
        .RegWr(RegWr),
        .WrRegDSrc(WrRegDSrc),
        .bussA(bussA1),
        .bussB(bussB1),
        .clk(clk_hand),
        .getHW(getHW),
        .rd(rd),
        .rs(rs),
        .rt(rt));
  dataMemory dataMemory_0
       (.DB(DB),
        .DBDataSrc(DBDataSrc),
        .Daddr(Out),
        .DataIn(bussB),
        .DataOut(DataOut),
        .clk(clk_hand),
        .mWR(mWR));
  decoder decoder_0
       (.fun(fun),
        .imm16(imm16),
        .imm26(imm26),
        .instruction(IRInstruction),
        .op(op),
        .rd(rd),
        .rs(rs),
        .rt(rt),
        .sa(sa));
  extend extend_0
       (.ExtSel(ExtSel),
        .imm16(imm16),
        .imm32(imm32));
  instructionMemory instructionMemory_0
       (.Instruction(Instruction),
        .ReadAddress(PC));
  npc npc_0
       (.Imm26(imm26),
        .Imm32(imm32),
        .PC(PC),
        .PC4(PC4),
        .PCSrc(PCSrc),
        .PCWr(PCWr),
        .bussA(bussA1),
        .clk(clk_hand),
        .nextPC(nextPC),
        .reset(reset));
  tmpReg ALUResult
       (.In(result),
        .Out(Out),
        .clk(clk_hand));
  tmpReg bussAdata
       (.In(bussA1),
        .Out(bussA),
        .clk(clk_hand));
  tmpReg bussBdata
       (.In(bussB1),
        .Out(bussB),
        .clk(clk_hand));




endmodule
