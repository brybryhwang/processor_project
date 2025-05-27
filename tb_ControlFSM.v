`timescale 1ns / 1ps
module tb_ControlFSM;
    reg clk, reset;
    reg [3:0] opcode;
    reg zero;
    wire regwrite, alusrc, memread, memwrite, memtoreg, branch, jump;
    wire [2:0] aluop;

    ControlFSM uut (
        .clk(clk), .reset(reset), .opcode(opcode), .zero(zero),
        .regwrite(regwrite), .alusrc(alusrc), .memread(memread),
        .memwrite(memwrite), .memtoreg(memtoreg),
        .branch(branch), .jump(jump), .aluop(aluop)
    );

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        reset = 1; #10;
        reset = 0; opcode = 4'b0000; zero = 0; #20; // ADD
        opcode = 4'b1000; #20; // LOAD
        opcode = 4'b1001; #20; // STORE
        opcode = 4'b1010; zero = 1; #20; // BEQ
        opcode = 4'b1011; #20; // JUMP
        $finish;
    end
endmodule
