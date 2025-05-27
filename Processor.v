module Processor (
    input clk,
    input reset,
    input [2:0] SW,          // Register select input
    output [6:0] HEX0        // 7-segment output
);
    wire regwrite, alusrc, memread, memwrite, memtoreg, branch, jump;
    wire [2:0] aluop;
    wire [3:0] opcode;
    wire [15:0] reg_out;
    wire zero;

    // FSM instance
    ControlFSM control (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .zero(zero),
        .regwrite(regwrite),
        .alusrc(alusrc),
        .memread(memread),
        .memwrite(memwrite),
        .memtoreg(memtoreg),
        .branch(branch),
        .jump(jump),
        .aluop(aluop)
    );

    // Datapath instance
    Datapath datapath (
        .clk(clk),
        .reset(reset),
        .regwrite(regwrite),
        .alusrc(alusrc),
        .memread(memread),
        .memwrite(memwrite),
        .memtoreg(memtoreg),
        .branch(branch),
        .jump(jump),
        .aluop(aluop),
        .data_in(16'b0),          // Optional external data in
        .reg_select(SW),
        .reg_out(reg_out),
        .opcode(opcode),
        .zero(zero)
    );

    // HEX Display (only lower 4 bits shown)
    HexDisplay display (
        .in(reg_out[3:0]),
        .out(HEX0)
    );
endmodule
