`timescale 1ns / 1ps

module Processor_TB;

    // Inputs
    reg clk;
    reg reset;
    reg [2:0] SW;

    // Outputs
    wire [6:0] HEX0;

    // Instantiate the Processor
    Processor uut (
        .clk(clk),
        .reset(reset),
        .SW(SW),
        .HEX0(HEX0)
    );

    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize
        reset = 1;
        SW = 0;
        #20 reset = 0;

        // Monitor all signals
        $monitor("Time = %t | PC = %h | Opcode = %b | State = %s | RegOut = %h",
                 $time, uut.datapath.pc, uut.opcode, uut.control.current_state.name(), uut.reg_out);

        // Wait for first instruction (ADD r1 = r2 + r3)
        #50;
        SW = 3'b001; // Select r1
        #50;
        if (uut.reg_out !== 16'hxxxx) begin
            $display("ADD Test: r1 = %h (Expected: r2 + r3)", uut.reg_out);
        end

        // Test LOAD (r0 = mem[r1])
        SW = 3'b000; // Select r0
        #100;
        if (uut.reg_out === 16'd5) begin
            $display("LOAD Test: r0 = %d (PASS)", uut.reg_out);
        end else begin
            $display("LOAD Test: r0 = %d (FAIL, expected 5)", uut.reg_out);
        end

        // Test BEQ (branch if r1 == r2)
        SW = 3'b001; // Select r1
        #50;
        if (uut.zero) begin
            $display("BEQ Test: Branch taken (PASS)");
        end else begin
            $display("BEQ Test: Branch not taken (FAIL)");
        end

        // Test JMP (force jump to address 0)
        #50;
        if (uut.datapath.pc === 8'h00) begin
            $display("JMP Test: PC reset to 0 (PASS)");
        end else begin
            $display("JMP Test: PC = %h (FAIL)", uut.datapath.pc);
        end

        // Finish simulation
        $display("All tests completed.");
        $finish;
    end

    // Dump waveforms for GTKWave
    initial begin
        $dumpfile("processor_tb.vcd");
        $dumpvars(0, Processor_TB);
    end

endmodule