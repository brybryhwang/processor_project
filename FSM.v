module FSM(
    input clk,
    input reset,
    input [3:0] opcode,
    output reg regWrite, aluSrc, memRead, memWrite, memToReg,
    output reg [1:0] aluOp,
    output reg [2:0] state
);

    parameter FETCH = 3'b000, DECODE = 3'b001, EXEC = 3'b010, MEM = 3'b011, WB = 3'b100, WAIT = 3'b101;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= FETCH;
        end else begin
            case (state)
                FETCH: state <= DECODE;
                DECODE: begin
                    case (opcode)
                        4'b0001: state <= EXEC; // ADD
                        4'b0010: state <= EXEC; // XOR
                        4'b0011: state <= MEM;  // LOAD
                        4'b0100: state <= EXEC; // MOV
                        default: state <= FETCH;
                    endcase
                end
                EXEC: state <= WB;
                MEM: state <= WB;
                WB: state <= WAIT;
					 WB: state <= FETCH;
                default: state <= FETCH;
            endcase
        end
    end

    always @(*) begin
        // Default
        regWrite = 0; aluSrc = 0; memRead = 0; memWrite = 0; memToReg = 0; aluOp = 2'b00;
        case (state)
            EXEC: begin
                case (opcode)
                    4'b0001: begin regWrite = 1; aluOp = 2'b00; end // ADD
                    4'b0010: begin regWrite = 1; aluOp = 2'b01; end // XOR
                    4'b0100: begin regWrite = 1; aluOp = 2'b11; end // MOV
                endcase
            end
            MEM: begin memRead = 1; memToReg = 1; aluSrc = 1; end
            WB: begin regWrite = 1; end
        endcase
    end
endmodule
