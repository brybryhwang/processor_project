module Datapath(
    input clk,
    input regWrite, aluSrc, memRead, memWrite, memToReg,
    input [1:0] aluOp,
    input [15:0] instr,
    output [15:0] result_out,
	 //Debug
	 output [15:0] debug_r0,
    output [15:0] debug_r1,
    output [15:0] debug_r2
);
    wire [2:0] rs1 = instr[11:9];
    wire [2:0] rs2 = instr[8:6];
    wire [2:0] rd = instr[5:3];
    wire [5:0] imm = instr[5:0];
    wire [15:0] imm_sext = {{10{imm[5]}}, imm};  // Sign extension

    wire [15:0] readData1, readData2, aluInB, aluResult, memReadData, writeData;


    RegisterFile rf(clk, regWrite, rs1, rs2, rd, writeData, readData1, readData2,debug_r0,debug_r1,debug_r2);

    assign aluInB = aluSrc ? imm_sext : readData2;
    ALU alu(readData1, aluInB, aluOp, aluResult);

    DataMemory dmem(clk, memRead, memWrite, aluResult, readData2, memReadData);

    assign writeData = memToReg ? memReadData : aluResult;
    assign result_out = writeData;
endmodule
