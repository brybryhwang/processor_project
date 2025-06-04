module Testbench;
    reg clk = 0;
    reg reset = 1;
    wire [15:0] result_out;

    Top uut(clk, reset, result_out);

    always #5 clk = ~clk;

    initial begin
        #10 reset = 0;
        #100 $stop;
    end
endmodule
