// -----------------------------------------------------------------------------
//  Processor_debug – top wrapper with $display hooks
// -----------------------------------------------------------------------------
module Processor(
    input  logic        clk,
    input  logic        reset,
    input  logic [2:0]  SW,
    output logic [6:0]  HEX0
);

    //----------- wires --------------------------------------------------------
    logic        regwrite, alusrc, memread, memwrite, memtoreg;
    logic [1:0]  aluop;
    logic        pc_en, ir_write;
    logic [1:0]  opcode;
    logic        zero;
    logic [15:0] reg_out;

    //----------- Controller ---------------------------------------------------
    ControlFSM ctrl (
        .clk       (clk),
        .reset     (reset),
        .opcode    (opcode),
        .zero      (zero),

        .regwrite  (regwrite),
        .alusrc    (alusrc),
        .memread   (memread),
        .memwrite  (memwrite),
        .memtoreg  (memtoreg),
        .aluop     (aluop),
        .pc_en     (pc_en),
        .ir_write  (ir_write)
    );

    Datapath datapath (
        .clk        (clk),
        .reset      (reset),

        .regwrite   (regwrite),
        .alusrc     (alusrc),
        .memread    (memread),
        .memwrite   (memwrite),
        .memtoreg   (memtoreg),
        .aluop      (aluop),
        .pc_en      (pc_en),
        .ir_write   (ir_write),

        .reg_select (SW),
        .reg_out    (reg_out),

        .opcode     (opcode),
        .zero       (zero)
    );

    //----------- HEX display --------------------------------------------------
    HexDisplay disp (.in(reg_out[3:0]), .out(HEX0));

    always_ff @(posedge clk)
        $display("[TOP] t=%0t  pc_en=%0b ir_w=%0b rw=%0b memR=%0b memW=%0b reg_out=%h",
                 $time, pc_en, ir_write, regwrite, memread, memwrite, reg_out);
endmodule
