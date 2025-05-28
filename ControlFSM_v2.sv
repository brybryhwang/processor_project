timescale 1ns/1ps

module ControlFSM_v2 (
    input  logic       clk,
    input  logic       reset_n,
    input  logic [3:0] opcode,
    input  logic       zero,

    output logic       reg_write,
    output logic       alu_src,
    output logic       mem_read,
    output logic       mem_write,



    output logic       mem_to_reg,
    output logic       pc_write,
    output logic [1:0] pc_src,   // <-- NEW: 00=PC+1  01=branch  10=jump  11=ldpc
    output logic [3:0] alu_op    // <-- NEW: pass directly to ALU (lower 3 bits for legacy ALU)
);

    /* ---------- opcode map ---------- */
	typedef enum logic [3:0] {
        OP_ADD   = 4'h0, OP_SUB  = 4'h1, OP_AND = 4'h2, OP_OR  = 4'h3,
        OP_MOV   = 4'h4, OP_XOR  = 4'h5,              // 4'h6/7 reserved for shifts
        OP_LOAD  = 4'h8, OP_STORE= 4'h9,
        OP_LDPC  = 4'hA,
        OP_BEQ   = 4'hC, OP_JMP  = 4'hD
	} op_t;

    /* ---------- state enum ---------- */
	typedef enum logic [3:0] {
		S_FETCH  = 4'h0,
		S_DECODE = 4'h1,
		S_EXEC_R = 4'h2,
		S_ADDR   = 4'h3,
		S_MEM_RD = 4'h4,
		S_MEM_WR = 4'h5,
		S_WB_ALU = 4'h6,
		S_WB_MEM = 4'h7,
		S_BRANCH = 4'h8,
		S_JUMP   = 4'h9,
		S_LDPC   = 4'hA
	} state_t;

	(* keep, preserve *) state_t state, nxt;

    /* ---------- state register ---------- */
	always_ff @(posedge clk or negedge reset_n)
		if (!reset_n) state <= S_FETCH;
      else          state <= nxt;

    /* ---------- next-state logic ---------- */
	always_comb begin
      nxt = state;
      unique case (state)
			S_FETCH  : nxt = S_DECODE;

				S_DECODE : unique case (opcode)
                           OP_LOAD , OP_STORE : nxt = S_ADDR;
                           OP_BEQ             : nxt = S_BRANCH;
                           OP_JMP             : nxt = S_JUMP;
                           OP_LDPC            : nxt = S_LDPC;
                           default            : nxt = S_EXEC_R;
                       endcase

            S_EXEC_R : nxt = S_WB_ALU;
            S_ADDR   : nxt = (opcode==OP_LOAD) ? S_MEM_RD : S_MEM_WR;
            S_MEM_RD : nxt = S_WB_MEM;

            default  : nxt = S_FETCH;  // S_MEM_WR, S_WB_ALU, S_WB_MEM, S_BRANCH, S_JUMP, S_LDPC
			endcase
    end

    /* ---------- output logic ---------- */
    always_comb begin
        /* defaults (inactive) */
        reg_write  = 0;
        alu_src    = 0;
        mem_read   = 0;
        mem_write  = 0;
        mem_to_reg = 0;
        pc_write   = 0;
        pc_src     = 2'b00;
        alu_op     = opcode;   // R-type: use opcode directly

        unique case (state)
            S_FETCH : mem_read = 1;             // fetch instr

            S_ADDR  : begin
                          alu_src = 1; alu_op = OP_ADD;    // base+offset
                      end

            S_MEM_RD : mem_read  = 1;
            S_MEM_WR : mem_write = 1;

            S_WB_ALU : reg_write = 1;
            S_WB_MEM : begin reg_write = 1; mem_to_reg = 1; end

            S_BRANCH : begin
                          alu_op  = OP_SUB;
                          pc_src  = 2'b01;
                          pc_write= zero;                  // conditional
                      end

            S_JUMP   : begin pc_src = 2'b10; pc_write = 1; end
            S_LDPC   : begin pc_src = 2'b11; pc_write = 1; end
        endcase
    end

endmodule