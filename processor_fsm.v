module processor_fsm (
    input clk,
    input reset,
    input [2:0] opcode,
    output reg [3:0] state,
    output reg RegWrite,
    output reg [1:0] ALUOp,
    output reg IRWrite,
    output reg PCWrite
);

localparam FETCH        = 4'd0;
localparam DECODE       = 4'd1;
localparam LOAD         = 4'd2;
localparam MOV          = 4'd3;
localparam ADD          = 4'd4;
localparam XOR          = 4'd5;
localparam LDPC         = 4'd6;
localparam BRANCH       = 4'd7;
localparam INCREMENT_PC = 4'd8;

localparam OP_LOAD   = 3'b000;
localparam OP_MOV    = 3'b001;
localparam OP_ADD    = 3'b010;
localparam OP_XOR    = 3'b011;
localparam OP_LDPC   = 3'b100;
localparam OP_BRANCH = 3'b101;

always @(posedge clk or posedge reset) begin
    if (reset)
        state <= FETCH;
    else begin
        case (state)
            FETCH: state <= DECODE;
            DECODE: begin
                case (opcode)
                    OP_LOAD:   state <= LOAD;
                    OP_MOV:    state <= MOV;
                    OP_ADD:    state <= ADD;
                    OP_XOR:    state <= XOR;
                    OP_LDPC:   state <= LDPC;
                    OP_BRANCH: state <= BRANCH;
                    default:   state <= FETCH;
                endcase
            end
            LOAD,
            MOV,
            ADD,
            XOR,
            LDPC: state <= INCREMENT_PC;
            BRANCH: state <= FETCH;
            INCREMENT_PC: state <= FETCH;
            default: state <= FETCH;
        endcase
    end
end

always @(*) begin
    RegWrite = 0;
    ALUOp = 2'b00;
    IRWrite = 0;
    PCWrite = 0;

    case (state)
        FETCH: begin
            IRWrite = 1;
        end
        LOAD: begin
            RegWrite = 1;
            ALUOp = 2'b00; // Assume ALU pass-through for load
        end
        MOV: begin
            RegWrite = 1;
            ALUOp = 2'b10; // MOV
        end
        ADD: begin
            RegWrite = 1;
            ALUOp = 2'b00; // ADD
        end
        XOR: begin
            RegWrite = 1;
            ALUOp = 2'b01; // XOR
        end
        LDPC: begin
            RegWrite = 1;
        end
        BRANCH: begin
            PCWrite = 1;
        end
        INCREMENT_PC: begin
            PCWrite = 1;
        end
    endcase
end

endmodule