module top_processor_full_tb;

    reg clk = 0;
    reg reset;
    wire [3:0] state;
    wire [15:0] datapath_out;

    // Instantiate the full processor
    top_processor_full uut (
        .clk(clk),
        .reset(reset),
        .state(state),
        .datapath_out(datapath_out)
    );

    // Clock generation: toggle every 5 time units
    always #5 clk = ~clk;

    initial begin
        $dumpfile("top_processor_full.vcd");
        $dumpvars(0, top_processor_full_tb);

        $display("\n--- Starting Full Processor Simulation ---\n");

        // Reset processor
        reset = 1;
        #10;
        reset = 0;

        // Run for several clock cycles
        // Enough time to fetch and execute all instructions in memory
        #200;

        $display("\nFinal Datapath Output = %d", datapath_out);
        $display("Check if R1 and R3 were loaded correctly using LOAD instruction.");
        $stop;
    end

endmodule
