`timescale 1 ps / 1 ps

module CPU
   ();
  reg clk;
  reg reset;
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
        .clk(clk),
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
        .clk(clk));
  Registers Registers_0
       (.DB(DB),
        .PC4(PC4),
        .RegDst(RegDst),
        .RegWr(RegWr),
        .WrRegDSrc(WrRegDSrc),
        .bussA(bussA1),
        .bussB(bussB1),
        .clk(clk),
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
        .clk(clk),
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
        .clk(clk),
        .nextPC(nextPC),
        .reset(reset));
  tmpReg ALUResult
       (.In(result),
        .Out(Out),
        .clk(clk));
  tmpReg bussAdata
       (.In(bussA1),
        .Out(bussA),
        .clk(clk));
  tmpReg bussBdata
       (.In(bussB1),
        .Out(bussB),
        .clk(clk));


     initial begin
          reset = 1;
          clk = 0;
          # 1 reset = 0;
          # 1000 $stop;
     end

     always #2 clk = ~clk;


endmodule
