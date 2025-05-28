`timescale 1ns/1ps
// -----------------------------------------------------------------------------
//  tb_Processor – self-checking test bench for the 4-instruction CPU
//  Program inside Datapath ROM:
//     0 : LOAD  r0 ← mem[0]   (5)
//     1 : LOAD  r1 ← mem[1]   (3)
//     2 : ADD   r2 ← r1 + r0  (8)
//     3 : XOR   r2 ← r2 ^ r0  (13)
//     4 : MOV   r4 ← r0       (5)
//  Expected register results after WB stage:
//     R0 = 5,  R1 = 3,  R2 = 13,  R4 = 5
// -----------------------------------------------------------------------------
module tb_Processor;
    //--- DUT ports
    logic        clk, reset;
    logic [2:0]  SW;
    wire  [6:0]  HEX0;

    //--- Instantiate DUT
    Processor dut (
        .clk   (clk),
        .reset (reset),
        .SW    (SW),
        .HEX0  (HEX0)
    );

    //--- 100 MHz clock (10 ns period)
    always #5 clk = ~clk;
    

    //--- Stimulus & checks
    initial begin
        // ---------- reset sequence ----------
        clk   = 0;
        reset = 1;
        SW    = 3'b000;
        #50;                 // keep reset high for two cycles
        reset = 0;
        
        

        // ---------- optional: cycle SW so HEX0 shows regs 0-7 ----------
        fork
            repeat (8) begin
                #40;         // change every 4 clk cycles
                SW = SW + 3'd1;
            end
        join_none

        // ---------- wait long enough for 5 instructions to finish ----------
        #200;                // 20 clock cycles (safe margin)

        // ---------- stop the SW sweep ----------
        SW = 3'd0;

        // ---------- self-check ----------
        if (dut.datapath.reg_file[0] !== 16'd5)   test_fail("R0", dut.datapath.reg_file[0], 16'd5);
        if (dut.datapath.reg_file[1] !== 16'd3)   test_fail("R1", dut.datapath.reg_file[1], 16'd3);
        if (dut.datapath.reg_file[2] !== 16'd13)  test_fail("R2", dut.datapath.reg_file[2], 16'd13);
        if (dut.datapath.reg_file[4] !== 16'd5)   test_fail("R4", dut.datapath.reg_file[4], 16'd5);

        $display("\n*** TEST PASSED ***\n");
        $finish;
    end

    //--- task: report mismatch & abort
    task automatic test_fail
        (input string      regname,
         input logic [15:0] actual,
         input logic [15:0] expected);
    begin
        $error("\n*** TEST FAILED: %s = %0d, expected %0d ***\n",
               regname, actual, expected);
        $finish;
    end
    endtask
endmodule
