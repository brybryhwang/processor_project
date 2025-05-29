module ALU(
    input [15:0] a, b,
    input [1:0] aluOp,
    output reg [15:0] result
);
    always @(*) begin
        case (aluOp)
            2'b00: result = a + b;
            2'b01: result = a ^ b;
            2'b11: result = b;
            default: result = 0;
        endcase
    end
endmodule