module ControlFSM(
    input clk,
    input reset,
    input [3:0] opcode,
    input zero,

    output reg regwrite,
    output reg alusrc,
    output reg memread,
    output reg memwrite,
    output reg memtoreg,
    output reg branch,
    output reg jump,
    output reg [2:0] aluop
);

    // FSM states
    typedef enum logic [2:0] {
        IFETCH, DECODE, EXECUTE, MEM, WB, BRANCH, JUMP
    } state_t;

    state_t current_state, next_state;

    // Instruction opcodes
    localparam [3:0]
        OP_ADD   = 4'b0000,
        OP_SUB   = 4'b0001,
        OP_AND   = 4'b0010,
        OP_OR    = 4'b0011,
        OP_MOV   = 4'b0100,
        OP_LOAD  = 4'b1000,
        OP_STORE = 4'b1001,
        OP_BEQ   = 4'b1100,
        OP_JMP   = 4'b1101;

    // ALU Operations
    localparam [2:0]
        ALU_ADD = 3'b000,
        ALU_SUB = 3'b001,
        ALU_AND = 3'b010,
        ALU_OR  = 3'b011,
        ALU_PASS = 3'b100;

    // FSM state register
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IFETCH;
        else
            current_state <= next_state;
    end

    // State transitions
    always @(*) begin
        case (current_state)
            IFETCH:  next_state = DECODE;
            DECODE: begin
                case (opcode)
                    OP_ADD, OP_SUB, OP_AND, OP_OR, OP_MOV: next_state = EXECUTE;
                    OP_LOAD, OP_STORE:                     next_state = MEM;
                    OP_BEQ:                                next_state = BRANCH;
                    OP_JMP:                                next_state = JUMP;
                    default:                               next_state = IFETCH;
                endcase
            end
            EXECUTE: next_state = WB;
            MEM:     next_state = WB;
            WB:      next_state = IFETCH;
            BRANCH:  next_state = IFETCH;
            JUMP:    next_state = IFETCH;
            default: next_state = IFETCH;
        endcase
    end

    // Control outputs
    always @(*) begin
        // Default all signals
        regwrite   = 0;
        alusrc     = 0;
        memread    = 0;
        memwrite   = 0;
        memtoreg   = 0;
        branch     = 0;
        jump       = 0;
        aluop      = ALU_ADD;

        case (current_state)
            EXECUTE: begin
                regwrite = 1;
                case (opcode)
                    OP_ADD: aluop = ALU_ADD;
                    OP_SUB: aluop = ALU_SUB;
                    OP_AND: aluop = ALU_AND;
                    OP_OR:  aluop = ALU_OR;
                    OP_MOV: aluop = ALU_PASS;
                endcase
            end
            MEM: begin
                alusrc = 1;
                if (opcode == OP_LOAD) begin
                    memread = 1;
                end else if (opcode == OP_STORE) begin
                    memwrite = 1;
                    regwrite = 0;
                end
            end
            WB: begin
                if (opcode == OP_LOAD) begin
                    regwrite = 1;
                    memtoreg = 1;
                end
            end
            BRANCH: begin
                if (zero)
                    branch = 1;
                aluop = ALU_SUB;
            end
            JUMP: begin
                jump = 1;
            end
        endcase
    end

endmodule
