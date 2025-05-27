`timescale 1ns / 1ps
module tb_ALU;
    reg [15:0] a, b;
    reg [2:0] op;
    wire [15:0] result;
    wire zero;

    ALU uut (
        .a(a), .b(b), .op(op),
        .result(result), .zero(zero)
    );

    initial begin
        // Test ADD
        a = 5; b = 10; op = 3'b000;
        #10;

        // Test SUB (non-zero)
        a = 10; b = 5; op = 3'b001;
        #10;

        // Test SUB (zero)
        a = 8; b = 8; op = 3'b001;
        #10;

        // Test AND
        a = 16'hF0F0; b = 16'h0F0F; op = 3'b010;
        #10;

        // Test OR
        a = 16'hF0F0; b = 16'h0F0F; op = 3'b011;
        #10;

        // Test MOV (pass b)
        a = 0; b = 16'hABCD; op = 3'b100;
        #10;

        $finish;
    end
endmodule
