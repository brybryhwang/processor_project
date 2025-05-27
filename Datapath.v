module Datapath (
    input clk,
    input reset,
    input regwrite,
    input alusrc,
    input memread,
    input memwrite,
    input memtoreg,
    input branch,
    input jump,
    input [2:0] aluop,

    input [15:0] data_in,         // External data input for memory (optional)
    input [2:0] reg_select,       // For HEX display
    output [15:0] reg_out,        // Value of selected register
    output [3:0] opcode,          // Output to FSM
    output zero                  // From ALU
);

    // Program Counter
    reg [7:0] pc;
    wire [15:0] instruction;
    wire [15:0] alu_result;
    wire [15:0] reg_data1, reg_data2;
    wire [15:0] write_data;
    wire [15:0] mem_data;
    wire [15:0] alu_input2;
    wire [2:0] rs, rt, rd;

    // Instruction ROM (you can replace this with RAM for more flexibility)
    reg [15:0] rom [0:255];
    initial begin
        // Example: add r1, r2, r3 → opcode = 0000, rs=r2, rt=r3, rd=r1
        rom[0] = 16'b0000_010_011_001_000;  // add r1 = r2 + r3
        rom[1] = 16'b1000_000_001_000_000;  // load r0, mem[r1]
        // Add more instructions as needed
    end
    assign instruction = rom[pc];
    assign opcode = instruction[15:12];
    assign rs = instruction[11:9];
    assign rt = instruction[8:6];
    assign rd = instruction[5:3];
    
    // Program Counter Logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 0;
        else if (jump)
            pc <= instruction[7:0];     // For jmp instruction
        else if (branch && zero)
            pc <= pc + instruction[7:0]; // Relative branch
        else
            pc <= pc + 1;
				
				
	 reg [15:0] instr_mem [0:31];
	 initial begin
	 	  instr_mem[0] = 16'b1000001000000000; // load r1, addr 0
		  instr_mem[1] = 16'b1000010000000001; // load r2, addr 1
	 	  instr_mem[2] = 16'b0000011001010000; // add  r3 = r1 + r2
		  instr_mem[3] = 16'b1001011000000010; // store r3 → addr 2
		  instr_mem[4] = 16'b1010001010000000; // beq r1, r2, next
		  instr_mem[5] = 16'b1011000000000000; // jmp to 0
		  instr_mem[6] = 16'b0100100011000000; // mov r4 = r3
	 end
	 
	 // Data Memory Initialization
	 reg [15:0] data_mem [0:31];
	 initial begin
		  data_mem[0] = 16'd5;   // mem[0] = 5
		  data_mem[1] = 16'd3;   // mem[1] = 3
		  data_mem[2] = 16'd0;   // result goes here
	 end

			
	  			
	
