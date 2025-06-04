`timescale 1ns / 1ps



module reg_file(
   input clock,
	input [23:0] data,
	input [15:0] result,
	output reg [7:0] a,
	output reg [7:0] b,
	output reg [7:0] y
);
	reg [7:0] reg_x, reg_y;
	
	always @(posedge clock) begin
		
		a = data[23:16];
		b = data[15:8];
		
		reg_x = result[15:8];
		y = result[7:0];
		
	end

endmodule
