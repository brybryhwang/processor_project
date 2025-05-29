module ProgramMemory(
    input [3:0] addr,
    output [15:0] instr
);
    reg [15:0] mem[0:15];
    assign instr = mem[addr];
    initial begin
        mem[0] = 16'b0011000000000101; // LOAD R0, 5
        mem[1] = 16'b0011000100000010; // LOAD R1, 2
        mem[2] = 16'b0001001000000000; // ADD R2 = R0 + R1
        mem[3] = 16'b0010001100000000; // XOR R3 = R0 ^ R2
    end
endmodule
