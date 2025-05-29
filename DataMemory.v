module DataMemory(
    input clk,
    input memRead,
    input memWrite,
    input [15:0] addr,
    input [15:0] writeData,
    output reg [15:0] readData
);
    reg [15:0] mem [0:255]; // 256 x 16-bit data memory
	 
	 initial begin
        mem[5] = 16'd10;  // So LOAD R0, 5 will load value 10
        mem[2] = 16'd3;   // So LOAD R1, 2 will load value 3
    end


    always @(posedge clk) begin
        if (memWrite)
            mem[addr[7:0]] <= writeData;  // Use lower bits of addr as index
    end

    always @(*) begin
        if (memRead)
            readData = mem[addr[7:0]];
        else
            readData = 16'b0;
    end
endmodule
