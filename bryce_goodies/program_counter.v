module program_counter (
    input clk,
    input reset,
    input PCWrite,
    input [15:0] PC_in,
    output reg [15:0] PC_out
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            PC_out <= 16'd0;
        else if (PCWrite)
            PC_out <= PC_in;
    end

endmodule