module RegisterFile(
    input clk,
    input regWrite,
    input [2:0] rs1, rs2, rd,
    input [15:0] writeData,
    output [15:0] readData1, readData2,
	 output [15:0] debug_r0, debug_r1, debug_r2
);
    reg [15:0] regs[7:0];
	 
	 //Debug
    assign debug_r0 = regs[0];
    assign debug_r1 = regs[1];
    assign debug_r2 = regs[2];

	 
	 integer i;
    initial begin
        for (i = 0; i < 8; i = i + 1)
            regs[i] = 16'b0;
    end


	 
    assign readData1 = regs[rs1];
    assign readData2 = regs[rs2];

    always @(posedge clk) begin
        if (regWrite)
            regs[rd] <= writeData;
    end
endmodule
