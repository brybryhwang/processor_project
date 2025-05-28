module top_processor_full (
    input clk,
    input reset,
    output [3:0] state,
    output [15:0] datapath_out
);

    // Internal signals
    wire [15:0] PC_out;
    wire [15:0] instruction;
    wire [15:0] IR_out;

    wire [2:0] opcode = IR_out[15:13];      // top 3 bits of instruction
    wire [2:0] reg_dst = IR_out[12:10];     // destination register
    wire [2:0] reg_sel_B = IR_out[9:7];     // source register B
    wire [2:0] reg_sel_A = IR_out[12:10];   // same as destination in 2-operand design
    wire [15:0] DataIn = {13'd0, IR_out[2:0]}; // fake immediate data (3-bit for demo)

    wire RegWrite, PCWrite, IRWrite;
    wire [1:0] ALUOp;

    // Instantiate FSM
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

    // Program Counter
    wire [15:0] PC_in = PC_out + 1;
    program_counter pc (
        .clk(clk),
        .reset(reset),
        .PCWrite(PCWrite),
        .PC_in(PC_in),
        .PC_out(PC_out)
    );

    // Instruction Memory
    instruction_memory imem (
        .clk(clk),
        .address(PC_out),
        .instruction(instruction)
    );

    // Instruction Register
    instruction_register ir (
        .clk(clk),
        .IRWrite(IRWrite),
        .instruction_in(instruction),
        .instruction_out(IR_out)
    );

    // Datapath
    datapath dp (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .DataIn(DataIn),
        .reg_sel_A(reg_sel_A),
        .reg_sel_B(reg_sel_B),
        .reg_dst(reg_dst),
        .bus_out(datapath_out)
    );

endmodule
