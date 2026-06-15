`timescale 1ns / 1ps

module Control_Unit(
    input  wire [6:0] op,
    input  wire [2:0] funct3,
    input  wire       funct7b5,
    input  wire       Zero,
    input  wire       stall,

    output wire [1:0] ResultSrc,
    output wire       MemWrite,
    output wire       PCSrc,
    output wire       ALUSrc,
    output wire       RegWrite,
    output wire       Jump,
    output wire [1:0] ImmSrc,
    output wire [3:0] ALUControl,
    output wire       Jalr
);

    wire [1:0] ALUop;
    wire       Branch;

    wire       MemWrite_internal;
    wire       RegWrite_internal;

    Main_Decoder Main_Decoder(
        .op        (op),
        .ResultSrc (ResultSrc),
        .MemWrite  (MemWrite_internal),
        .Branch    (Branch),
        .ALUSrc    (ALUSrc),
        .RegWrite  (RegWrite_internal),
        .Jump      (Jump),
        .ImmSrc    (ImmSrc),
        .ALUop     (ALUop)
    );

    ALU_decoder ALU_decoder(
        .opb5       (op[5]),
        .funct3     (funct3),
        .funct7b5   (funct7b5),
        .ALUOp      (ALUop),
        .ALUControl (ALUControl)
    );

    wire take_branch = (funct3 == 3'b001) ? !Zero : Zero; 
    assign PCSrc = (Branch & take_branch) | Jump | Jalr;
    assign MemWrite = stall ? 1'b0 : MemWrite_internal;
    assign RegWrite = stall ? 1'b0 : RegWrite_internal;
    assign Jalr = (op == 7'b1100111);

endmodule