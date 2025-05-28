module instruction_register (
    input clk,
    input IRWrite,
    input [15:0] instruction_in,
    output reg [15:0] instruction_out
);

    always @(posedge clk) begin
        if (IRWrite)
            instruction_out <= instruction_in;
    end

endmodule
