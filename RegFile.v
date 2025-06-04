module RegisterFile(
    input clk,
    input regWrite,
    input [2:0] rs1, rs2, rd,
    input [15:0] writeData,
    output [15:0] readData1, readData2,
	output [15:0] debug_r0, debug_r1, debug_r2,
	output reg[15:0]  regs_num
);
    reg [15:0] regs[7:0];
	 
	 //Debug
    assign debug_r0 = regs[0];
    assign debug_r1 = regs[1];
    assign debug_r2 = regs[2];

	 

    initial begin

            regs[0] = 16'd5;
			regs[1] = 16'd2;
			regs[2] = 16'd7;
			regs[3] = 16'd2;
			regs[4] = 16'd2;
			
    end
reg [3:0] i=0;
always@(posedge regWrite)begin
		regs_num<=regs[i];
		if(i<4)
		i<=i+1;
		else
		i<=0;
end
	 
    assign readData1 = regs[rs1];
    assign readData2 = regs[rs2];

/*     always @(*) begin
        if (regWrite)
            //regs[rd] = writeData;
    end*/
endmodule 
