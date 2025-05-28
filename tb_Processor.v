`timescale 1ns / 1ps
module tb_Processor;
    reg clk, reset;
    reg [2:0] SW;
    wire [6:0] HEX0;

    Processor uut (
        .clk(clk),
        .reset(reset),
        .SW(SW),
        .HEX0(HEX0)
    );

    initial begin
        clk = 0; forever #10 clk = ~clk;
    end

    initial begin
        reset = 1; SW = 3'b000; #20;
        reset = 0;

        // Run for a few instructions
        repeat (10) begin
            #20;
        end

        $finish;
    end

        initial begin

        $dumpfile("<<chosen_output_file_name>>.vcd");

        $dumpvars(0, <<signals_you_want_to_test>>);

        #1000 

        $finish;

        end
        
endmodule
