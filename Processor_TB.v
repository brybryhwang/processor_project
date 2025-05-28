`timescale 1ns / 1ps

module Processor_TB;

    // Inputs
    reg clk;
    reg reset;
    reg [2:0] SW;

    // Outputs
    wire [6:0] HEX0;

    // Instantiate the Unit Under Test (UUT)
    Processor uut (
        .clk(clk),
        .reset(reset),
        .SW(SW),
        .HEX0(HEX0)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize Inputs
        reset = 1;
        SW = 0;
        
        // Reset the processor
        #20;
        reset = 0;
        
        // Test ADD operation (r1 = r2 + r3)
        SW = 3'b001; // Select r1
        #100;
        
        // Test LOAD operation
        SW = 3'b000; // Select r0
        #100;
        
        // Test BEQ operation
        SW = 3'b010; // Select r2
        #100;
        
        // Test JMP operation
        SW = 3'b000; // Back to r0
        #100;
        
        $display("All tests completed");
        $finish;
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("processor_tb.vcd");
        $dumpvars(0, Processor_TB);
    end

endmodule