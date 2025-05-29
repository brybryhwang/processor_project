module Top(
    input clk,
    input reset,
    output [15:0] result_out,
	 //Debug
	 output [15:0] debug_r0,
    output [15:0] debug_r1,
    output [15:0] debug_r2
);
    wire [2:0] state;
    wire [15:0] instr;
    wire regWrite, aluSrc, memRead, memWrite, memToReg;
    wire [1:0] aluOp;

    reg [3:0] pc;


    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 0;
        else if (state == 3'b101)  // WB state
            pc <= pc + 1;
    end

    ProgramMemory pm(pc, instr);
    FSM fsm(clk, reset, instr[15:12], regWrite, aluSrc, memRead, memWrite, memToReg, aluOp, state);
    //Datapath dp(clk, regWrite, aluSrc, memRead, memWrite, memToReg, aluOp, instr, result_out);
	 
	 Datapath dp(
        .clk(clk),
        .regWrite(regWrite),
        .aluSrc(aluSrc),
        .memRead(memRead),
        .memWrite(memWrite),
        .memToReg(memToReg),
        .aluOp(aluOp),
        .instr(instr),
        .result_out(result_out),
        .debug_r0(debug_r0),
		  .debug_r1(debug_r1),
		  .debug_r2(debug_r2)
    );

endmodule
