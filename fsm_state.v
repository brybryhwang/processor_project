module fsm_state (
    input clk,
    input reset,
    input [2:0] opcode,
    output reg [3:0] state
);

localparam FETCH        = 4'd0;
localparam DECODE       = 4'd1;
localparam EXEC_LOAD    = 4'd2;
localparam EXEC_MOV     = 4'd3;
localparam EXEC_ADD     = 4'd4;
localparam EXEC_XOR     = 4'd5;
localparam EXEC_LDPC    = 4'd6;
localparam EXEC_BRANCH  = 4'd7;
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
                    OP_LOAD:   state <= EXEC_LOAD;
                    OP_MOV:    state <= EXEC_MOV;
                    OP_ADD:    state <= EXEC_ADD;
                    OP_XOR:    state <= EXEC_XOR;
                    OP_LDPC:   state <= EXEC_LDPC;
                    OP_BRANCH: state <= EXEC_BRANCH;
                    default:   state <= FETCH;
                endcase
            end
            EXEC_LOAD,
            EXEC_MOV,
            EXEC_ADD,
            EXEC_XOR,
            EXEC_LDPC: state <= INCREMENT_PC;
            EXEC_BRANCH: state <= FETCH;
            INCREMENT_PC: state <= FETCH;
            default: state <= FETCH;
        endcase
    end
end

endmodule