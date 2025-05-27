`timescale 1ns/1ps

module tb_FSMonly;

    //--------------------------------------------------------------------
    // 1. Local clock & reset
    //--------------------------------------------------------------------
    logic clk = 0;
    logic reset_n = 0;            // ACTIVE-LOW, matches ControlFSM port

    // 100 MHz clock (10 ns period)
    always #5 clk = ~clk;

    //--------------------------------------------------------------------
    // 2. Stimulus signals
    //--------------------------------------------------------------------
    logic [3:0] opcode = 4'hF;    // idle value when no instruction
    logic       zero   = 0;       // ALU zero flag (only for BEQ)

    //--------------------------------------------------------------------
    // 3. Wire up all FSM outputs (they are not checked for Mark-1,
    //    but declaring them avoids “unconnected port” warnings)
    //--------------------------------------------------------------------
    logic        reg_write;
    logic        alu_src;
    logic        mem_read;
    logic        mem_write;
    logic        mem_to_reg;
    logic        pc_write;
    logic [1:0]  pc_src;
    logic [3:0]  alu_op;
    // (Add more wires if you later enlarge the FSM)

    //--------------------------------------------------------------------
    // 4. DUT – explicit port mapping
    //--------------------------------------------------------------------
    ControlFSM_v2 dut (
        .clk        (clk),
        .reset_n    (reset_n),
        .opcode     (opcode),
        .zero       (zero),

        .reg_write  (reg_write),
        .alu_src    (alu_src),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .pc_write   (pc_write),
        .pc_src     (pc_src),
        .alu_op     (alu_op)
    );

    //--------------------------------------------------------------------
    // 5. Helper task – send one opcode (and optional zero flag)
    //--------------------------------------------------------------------
    task automatic send (input logic [3:0] op, input logic z = 0);
        @(negedge clk);
        opcode = op;
        zero   = z;
        @(negedge clk);            // hold one full cycle
        opcode = 4'hF;             // idle (unused opcode)
        zero   = 0;  
    endtask

    //--------------------------------------------------------------------
    // 6. Stimulus sequence
    //--------------------------------------------------------------------
    initial begin
        //----------------------------------------------------------------
        // global reset
        //----------------------------------------------------------------
        repeat (2) @(negedge clk);   // two cycles low reset_n
        reset_n = 1;

        //----------------------------------------------------------------
        // run six representative instructions
        //----------------------------------------------------------------
        send(4'h0 );        // ADD    → EXEC_R → WB_ALU
        send(4'h8 );        // LOAD   → ADDR → MEM_RD → WB_MEM
        send(4'h9 );        // STORE  → ADDR → MEM_WR
        send(4'hC , 1);     // BEQ taken → BRANCH
        send(4'hD );        // JMP    → JUMP
        send(4'hA );        // LDPC   → LDPC

        
    end

endmodule
