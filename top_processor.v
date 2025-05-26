module top_processor (
    input clk,
    input reset,
    input [2:0] opcode,
    input [15:0] DataIn,
    input [2:0] reg_sel_A,
    input [2:0] reg_sel_B,
    input [2:0] reg_dst,
    output [3:0] state, 
    output [15:0] result_out
);

    wire RegWrite, IRWrite, PCWrite;
    wire [1:0] ALUOp;

    processor_fsm fsm (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .state(state),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .IRWrite(IRWrite),
        .PCWrite(PCWrite)
    );

    datapath dp (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .DataIn(DataIn),
        .reg_sel_A(reg_sel_A),
        .reg_sel_B(reg_sel_B),
        .reg_dst(reg_dst),
        .bus_out(result_out)
    );

endmodule