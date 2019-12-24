`timescale 1ns / 1ps

module ControlUnit(
    input sign,
    input zero, 
    input [5:0]op, 
    input [5:0]fun,
    input clk,
    input reset,
    input overFlow,

    output reg ALUSrcA,  
    output reg ALUSrcB,  
    output reg [2:0]ALUOp,
    output reg ExtSel,
    output reg mWR, 
    output reg DBDataSrc,
    output reg getHW,
    output reg IRWr, 
    output reg PCWr, 
    output reg [1:0]PCSrc,
    output reg RegWr,
    output reg [1:0]RegDst,
    output reg WrRegDSrc,
    output reg [2:0]state
);
    
    reg [2:0] nextState;  

    parameter [2:0] sINIT = 3'b111,
                    sIF = 3'b000,
                    sID = 3'b001,
                    sEXE = 3'b010,
                    sMEM = 3'b100,
                    sWB = 3'b011;


    initial begin
        state = sINIT;     
        nextState = sIF;                              
        PCWr = 0;  
        IRWr = 0;  
        RegWr = 0;  
        mWR = 0;
    end
    
    always@(posedge clk) begin
        if(reset) 
            state = sINIT;
        else 
            state = nextState;
    end
    
    
    always@(state, op, fun, zero, sign) begin
        //get next state
        case(state)
            sINIT: nextState = sIF;
            sIF: nextState = sID;
            sID:// jump or halt ?
                nextState = (op == 6'b000010 || op == 6'b111111 || op == 6'b000000 && fun == 6'b001000 || op == 6'b000011)? sIF: sEXE;
            sEXE:// brunch ? 
                nextState = (op == 6'b000100 || op == 6'b000101 || op == 6'b000001) ?
                            sIF: ((op == 6'b101011 || op == 6'b100011 || op == 6'b100101)? sMEM : sWB); // sw or lw or lhu?
            sMEM:// sw ?
                nextState = (op == 6'b101011) ? sIF: sWB;
            default: nextState = sIF;//sWB
        endcase
        
        //ALUSrcA: sll
        ALUSrcA = (op == 6'b000000 && fun == 6'b000000)? 1: 0;

        //ALUSrcB: addiu, andi, ori, slti, sw, lw, addi, lhu
        ALUSrcB = (op == 6'b001001 || op == 6'b001100 || op == 6'b001101 || op == 6'b001010 
        || op == 6'b101011 || op == 6'b100011 || op == 6'b001000 || op == 6'b100101) ? 1 : 0;
        
        //ExtSel: addiu, slti, sw, lw, beq, bne, bltz, addi, lhu
        ExtSel = (op == 6'b001001 || op == 6'b001010 || op == 6'b101011 || op == 6'b100011 || op == 6'b000100 || op == 6'b000101 || op == 6'b000001 || op == 6'b001000 || op == 6'b100101) ? 1 : 0; 
    
        // ALUOp: except jump and halt
        case(op)
            6'b000000: begin
                case(fun)
                    6'b100000:ALUOp = 0; //add
                    6'b100010:ALUOp = 1; //sub
                    6'b100100:ALUOp = 6; //and
                    6'b100101:ALUOp = 5; //or
                    6'b000000:ALUOp = 4; //sll
                    6'b101010:ALUOp = 3; //slt
                    6'b001011:ALUOp = 7; //mov
                    default:  ALUOp = 0;
                endcase
            end
            6'b001001:ALUOp = 0; //addiu
            6'b001100:ALUOp = 6; //andi
            6'b001101:ALUOp = 5; //ori
            6'b001010:ALUOp = 3; //slti
            6'b101011:ALUOp = 0; //sw
            6'b100011:ALUOp = 0; //lw
            6'b000100:ALUOp = 1; //beq
            6'b000101:ALUOp = 1; //bne
            6'b000001:ALUOp = 1; //bltz
            6'b001000:ALUOp = 0; //addi
            6'b100101:ALUOp = 0; //lhu
            default:  ALUOp = 0;
        endcase

        // mWR
        mWR = (state == sMEM && op == 6'b101011) ? 1 : 0; 

        // DBDataSrc
        DBDataSrc = (op == 6'b100011 || op == 6'b100101) ? 1 : 0;

        //getHW
        getHW = (op == 6'b100101) ? 1 : 0;

        // IRWr
        IRWr = (state == sIF)? 1 : 0;

        // PCWr
        PCWr = (nextState == sIF && op != 6'b111111)? 1 : 0;

        // PCSrc
        if(op == 6'b000010 || op == 6'b000011) 
            PCSrc = 3;
        else if(op == 6'b000000 && fun == 6'b001000) 
            PCSrc = 2;
        else if(op == 6'b000100 && zero || op == 6'b000101 && zero == 0 || op == 000001 && sign) 
            PCSrc = 1;
        else 
            PCSrc = 0;

        //RegWr
        if(state == sWB) begin
            case(op)
                6'b000000:begin
                    case(fun)
                        6'b100000:RegWr = overFlow ? 0 : 1; //add
                        6'b100010:RegWr = overFlow ? 0 : 1; //sub
                        6'b001011:RegWr = overFlow ? 0 : 1; //mov
                        default:  RegWr = 1;
                    endcase
                end
                6'b001001:RegWr = 1; //addiu
                6'b001100:RegWr = 1; //andi
                6'b001101:RegWr = 1; //ori
                6'b001010:RegWr = 1; //slti
                6'b100011:RegWr = 1; //lw
                6'b001000: //addi
                    RegWr = overFlow ? 0 : 1;
                6'b100101:RegWr = 1; //lhu
                default:  RegWr = 0;
            endcase
        end
        else if(state == sID && op == 6'b000011)
            RegWr = 1;
        else
            RegWr = 0;

        //RegDst
        case(op)
            6'b000011:RegDst = 0; //jal
            6'b001001:RegDst = 1; //addiu
            6'b001100:RegDst = 1; //andi
            6'b001101:RegDst = 1; //ori
            6'b001010:RegDst = 1; //slti
            6'b100011:RegDst = 1; //lw
            6'b001000:RegDst = 1; //addi
            6'b100101:RegDst = 1; //lhu
            default:  RegDst = 2; 
        endcase
        
        // WrRegDSrc
        WrRegDSrc = (op == 6'b000011) ? 1 : 0;
        
    end
endmodule