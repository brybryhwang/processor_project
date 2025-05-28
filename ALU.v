module ALU (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic [1:0]  op,      // 2-bit opcode
    output logic [15:0] result,
    output logic        zero
);
    typedef enum logic [1:0] {ADD=2'b00, XOR=2'b01, MOV=2'b10} alu_op_t;

    always_comb begin
        unique case (alu_op_t'(op))
            ADD: result = a + b;
            XOR: result = a ^ b;
            MOV: result = b;       // pass-through
            default: result = 16'h0000;
        endcase
    end

    assign zero = (result == 16'h0000);
endmodule
