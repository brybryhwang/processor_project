module ProgramMemory(
    input [3:0] addr,
    output [15:0] instr
);
    reg [15:0] mem[0:15];
    assign instr = mem[addr];
    initial begin
        mem[0] = 16'b0011_000_000_000_101; // LOAD R0, 5
        mem[1] = 16'b0011_001_000_001_010; // LOAD R1, 2
        mem[2] = 16'b0001_010_000_001_000; // ADD R2 = R0 + R1
        mem[3] = 16'b0010_011_000_010_000; // XOR R3 = R0 ^ R2
        mem[4] = 16'b0100_100_000_001_000; // MOV R4 = R1
    end
endmodule
