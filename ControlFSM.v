// -----------------------------------------------------------------------------
//  ControlFSM_debug – 5-state controller with verbose $display traces
//  Instructions : ADD(00) XOR(01) MOV(10) LOAD(11)
// -----------------------------------------------------------------------------
module ControlFSM (
    input  logic        clk,
    input  logic        reset,
    input  logic [1:0]  opcode,     // from IR
    input  logic        zero,       // reserved

    // ---- to Datapath ----
    output logic        regwrite,
    output logic        alusrc,
    output logic        memread,
    output logic        memwrite,
    output logic        memtoreg,
    output logic [1:0]  aluop,
    output logic        pc_en,
    output logic        ir_write
);

    //---------------- enums ---------------------------------------------------
    typedef enum logic [2:0] { IFETCH, DECODE, EXECUTE, MEM, WB } state_t;

    localparam  OP_ADD  = 2'b00,
                OP_XOR  = 2'b01,
                OP_MOV  = 2'b10,
                OP_LOAD = 2'b11;

    localparam  ALU_ADD  = 2'b00,
                ALU_XOR  = 2'b01,
                ALU_PASS = 2'b10;

    //---------------- state register -----------------------------------------
    state_t s, s_next;

    always_ff @(posedge clk or posedge reset)
        if (reset) s <= IFETCH;
        else       s <= s_next;

    //---------------- next-state ---------------------------------------------
    always_comb begin
        unique case (s)
            IFETCH : s_next = DECODE;
            DECODE : s_next = EXECUTE;
            EXECUTE: s_next = (opcode == OP_LOAD) ? MEM : WB;
            MEM    : s_next = WB;
            WB     : s_next = IFETCH;
            default: s_next = IFETCH;
        endcase
    end

    //---------------- output defaults ----------------------------------------
    always_comb begin
        // safe defaults
        regwrite = 0; alusrc = 0; memread = 0; memwrite = 0; memtoreg = 0;
        aluop    = ALU_ADD; pc_en = 0; ir_write = 0;

        unique case (s)

            IFETCH : begin
                pc_en    = 1;   // PC++
                ir_write = 1;   // IR latch
            end

            EXECUTE : begin
                unique case (opcode)
                    OP_ADD : begin regwrite=1; aluop=ALU_ADD;  end
                    OP_XOR : begin regwrite=1; aluop=ALU_XOR;  end
                    OP_MOV : begin regwrite=1; aluop=ALU_PASS; end
                    OP_LOAD: begin alusrc=1;   aluop=ALU_PASS; end
                endcase
            end

            MEM : if (opcode==OP_LOAD) begin
                alusrc   = 1;
                memread  = 1;
                memtoreg = 1;
            end

            WB  : if (opcode==OP_LOAD) begin
                regwrite = 1;
                memtoreg = 1;
            end
        endcase
    end

    //------------------------  DEBUG PRINTS  ----------------------------------
    always_ff @(posedge clk) begin
        $display("[FSM] t=%0t  state=%0d->%0d  op=%0d  rw=%0b memR=%0b memW=%0b aluop=%0d",
                 $time, s, s_next, opcode, regwrite, memread, memwrite, aluop);
    end
endmodule
