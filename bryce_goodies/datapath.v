module datapath (
    input clk,
    input reset,
    input RegWrite,
    input LoadDirect,
    input [1:0] ALUOp,
    input [15:0] DataIn,
    input [2:0] reg_sel_A, reg_sel_B, reg_dst,
    output reg [15:0] bus_out
);

reg [15:0] registers [0:7];
reg [15:0] regA, regB;
reg [15:0] ALUResult;

// Read registers A and B
always @(*) begin
    regA = registers[reg_sel_A];
    regB = registers[reg_sel_B];
end

// ALU
always @(*) begin
    case (ALUOp)
        2'b00: ALUResult = regA + regB;       // ADD
        2'b01: ALUResult = regA ^ regB;       // XOR
        2'b10: ALUResult = regB;              // MOV (Ry to Rx)
        default: ALUResult = 16'h0000;
    endcase
end

// Write result to register
always @(posedge clk) begin
    if (reset) begin
        registers[0] <= 0;
        registers[1] <= 0;
    end else if (RegWrite) begin
        if (LoadDirect)
            registers[reg_dst] <= DataIn;       // LOAD
        else
            registers[reg_dst] <= ALUResult;    // ALU result
    end
end

// Output bus value
always @(*) begin
    bus_out = registers[reg_dst];
end

endmodule