// ============================================================================
//  Datapath – 4-instruction (LOAD / MOV / ADD / XOR) multi-cycle CPU core
//  ▪ 8 × 16-bit register file
//  ▪ PC & IR controlled by ControlFSM (pc_en, ir_write)
//  ▪ branch / jump not implemented
//  ▪ Embedded $display statements for step-by-step debug
// ============================================================================
module Datapath (
    //---------------- Clock / Reset ----------------
    input  logic        clk,
    input  logic        reset,

    //---------------- Control from FSM -------------
    input  logic        regwrite,
    input  logic        alusrc,
    input  logic        memread,
    input  logic        memwrite,
    input  logic        memtoreg,
    input  logic [1:0]  aluop,
    input  logic        pc_en,
    input  logic        ir_write,

    //---------------- External ---------------------
    input  logic [2:0]  reg_select,   // which register to display
    output logic [15:0] reg_out,      // value -> HEX

    //---------------- Feedback to FSM --------------
    output logic [1:0]  opcode,
    output logic        zero
);

    //==========================================================================
    // 1. Program Counter (only synchronous reset)
    //==========================================================================
    logic [7:0] pc;
    

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 8'd0;
        else if (pc_en)
            pc <= pc + 8'd1;
    end

    // Debug: show PC advance (IF stage)
    always_ff @(posedge clk)
        if (pc_en)
            $display("[IF ] time=%0t  pc=%0d", $time, pc);

    //==========================================================================
    // 2. Instruction ROM  +  Instruction Register (IR)
    //    —— ROM **only** driven here (single driver)
    //==========================================================================
    logic [15:0] instr_mem [0:255];

    initial begin
        // Clear all locations
        foreach (instr_mem[i]) instr_mem[i] = 16'h0000;

        // --- Tiny program for self-test ---
        // opcode[15:14] | rs | rt | rd | imm[7:0]
        instr_mem[0] = 16'hC000; // LOAD r0, [0]
        instr_mem[1] = 16'hC201; // LOAD r1, [1]
        instr_mem[2] = 16'h0280; // ADD  r2 = r1 + r0
        instr_mem[3] = 16'h2280; // XOR  r2 = r2 ^ r0
        instr_mem[4] = 16'h1100; // MOV  r4 = r0
    end

    logic [15:0] instr_bus = instr_mem[pc];
    logic [15:0] instruction;

    always_ff @(posedge clk)
        if (ir_write)
            instruction <= instr_bus;

    // Debug: show fetched and latched instruction
    always_ff @(posedge clk)
        if (ir_write) begin
            $display("[ID ] time=%0t  pc=%0d  instr=%h", $time, pc, instr_bus);
        end

    //==========================================================================
    // 3. Decode fields
    //==========================================================================
    assign opcode = instruction[15:14];
    logic [2:0] rs = instruction[13:11];
    logic [2:0] rt = instruction[10:8];
    logic [2:0] rd = instruction[7:5];
    logic [7:0] imm8 = instruction[7:0];

    //==========================================================================
    // 4. Register file  (single always_ff — reset + write)
    //==========================================================================
    logic [15:0] reg_file [0:7];
    logic [15:0] reg_data1, reg_data2, write_data;

    always_ff @(posedge clk) begin
        integer i;
        if (reset)
            for (i = 0; i < 8; i++) reg_file[i] <= 16'h0000;
        else if (regwrite)
            reg_file[rd] <= write_data;
    end

    assign reg_data1 = reg_file[rs];
    assign reg_data2 = reg_file[rt];
    assign reg_out   = reg_file[reg_select];

    // Debug: write-back stage
    always_ff @(posedge clk)
        if (regwrite)
            $display("[WB ] time=%0t  rd=%0d  wdata=%h", $time, rd, write_data);

    //==========================================================================
    // 5. ALU
    //==========================================================================
    logic [15:0] alu_in2 = alusrc ? {8'h00, imm8} : reg_data2;
    logic [15:0] alu_result;

    always_comb
        case (aluop)
            2'b00 : alu_result = reg_data1 + alu_in2; // ADD
            2'b01 : alu_result = reg_data1 ^ alu_in2; // XOR
            2'b10 : alu_result = alu_in2;             // PASS / MOV / addr
            default: alu_result = 16'h0000;
        endcase

    assign zero = (alu_result == 16'h0000);

    // Debug: execute stage
    always_ff @(posedge clk)
        if (aluop != 2'b00 || regwrite)   // simple filter
            $display("[EX ] time=%0t  ALUres=%h  op=%0d", $time, alu_result, aluop);

    //==========================================================================
    // 6. Data memory (single always_ff — reset + read/write)
    //==========================================================================
    logic [15:0] data_mem [0:31];
    logic [15:0] mem_data_r;

    always_ff @(posedge clk) begin
        integer j;
        if (reset) begin
            for (j = 0; j < 32; j++) data_mem[j] <= 16'h0000;
            data_mem[0] <= 16'd5;
            data_mem[1] <= 16'd3;
            mem_data_r  <= 16'h0000;
        end
        else begin
            if (memwrite)
                data_mem[alu_result[4:0]] <= reg_data2;     // STORE
            mem_data_r <= data_mem[alu_result[4:0]];        // sync READ
        end
    end

    // Debug: memory stage
    always_ff @(posedge clk)
        if (memread)
            $display("[MEM] time=%0t  addr=%0d  rdata=%h",
                     $time, alu_result[4:0], mem_data_r);

    //==========================================================================
    // 7. Write-back mux
    //==========================================================================
    assign write_data = memtoreg ? mem_data_r : alu_result;

endmodule
