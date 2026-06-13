`timescale 1ns / 1ps

module Data_Memory(
    input  wire        clk,
    input  wire        WE,
    input  wire [31:0] A,
    input  wire [31:0] WD,

    output wire [31:0] RD
);

    reg [31:0] RAM [63:0];

    assign RD = RAM[A[31:2]]; // word aligned

    //only for testing, wont synthesize
    //addi s0, zero, 0
    //lw s0, 0(s0)
    //lh s1, 0(s0)
    //lb s2, 0(s0)
    //sw s0, 63(s0)

    initial begin
        RAM[32'h00_00_00_00] = 32'hFACEFACE;
        RAM[1]               = 32'h00000002;
        RAM[2]               = 32'h00000003;

        RAM[63]              = 32'h000000063;  // Should be replaced by FACE
    end

    always @(posedge clk) begin
        if (WE)
            RAM[A[31:2]] <= WD;
    end

endmodule