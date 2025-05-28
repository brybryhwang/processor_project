module Processor (
    input clk,
    input reset
);

    // === Instruction ROM ===
    // Preload instructions into memory
    reg [15:0] instr_mem [0:255];

    initial begin
        // Sample program (modify as needed)
        instr_mem[0] = 16'b000_001_0000000111;   // LOAD R1, 7
        instr_mem[1] = 16'b000_010_0000000100;   // LOAD R2, 4
        instr_mem[2] = 16'b001_011_001_010_0000; // ADD R3 = R1 + R2
        instr_mem[3] = 16'b010_100_011_001_0000; // XOR R4 = R3 ^ R1
        instr_mem[4] = 16'b011_101_100_000_0000; // MOV R5 = R4
    end

    // === Internal Wires ===
    wire [15:0] instr;          // Current instruction
    wire [2:0] alu_op;          // ALU operation selector
    wire [2:0] reg_sel_A;       // Read register A
    wire [2:0] reg_sel_B;       // Read register B
    wire [2:0] reg_write_sel;   // Write register selector
    wire reg_write_en;          // Enable register write
    wire data_in_en;            // Enable immediate data load
    wire pc_inc;                // Enable PC increment

    wire [15:0] pc_value;       // Current program counter value
    wire [7:0] imm_data;        // Immediate data from instruction

    // === Instruction Fetch ===
    assign instr = instr_mem[pc_value];
    assign imm_data = instr[7:0];

    // === Instantiate Control FSM ===
    ControlFSM control (
        .clk(clk),
        .reset(reset),
        .instr(instr),
        .alu_op(alu_op),
        .reg_sel_A(reg_sel_A),
        .reg_sel_B(reg_sel_B),
        .reg_write_sel(reg_write_sel),
        .reg_write_en(reg_write_en),
        .data_in_en(data_in_en),
        .pc_inc(pc_inc)
    );

    // === Instantiate Datapath ===
    Datapath datapath (
        .clk(clk),
        .reset(reset),
        .data_in(imm_data),
        .alu_op(alu_op),
        .reg_sel_A(reg_sel_A),
        .reg_sel_B(reg_sel_B),
        .reg_write_sel(reg_write_sel),
        .reg_write_en(reg_write_en),
        .data_in_en(data_in_en),
        .pc_inc(pc_inc),
        .pc_value(pc_value)
    );

endmodule

