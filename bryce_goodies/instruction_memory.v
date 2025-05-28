module instruction_memory (
    input clk,
    input [15:0] address,
    output reg [15:0] instruction
);

    reg [15:0] memory [0:255];

    initial begin
        // Load sample program into memory (e.g., manually encoded instructions)
        memory[0] = 16'b000_001_000_0000000; // LOAD R1, #0 (fake immediate example)
        memory[1] = 16'b000_011_000_0000001; // LOAD R3, #1
        memory[2] = 16'b010_001_011_0000000; // ADD R1, R3
        memory[3] = 16'b011_001_011_0000000; // XOR R1, R3
        memory[4] = 16'b001_010_001_0000000; // MOV R2, R1
    end

    always @(posedge clk) begin
        instruction <= memory[address];
    end

endmodule
