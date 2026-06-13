`timescale 1ns / 1ps

module ALU_Mux(
    input  wire [31:0] WD,
    input  wire [31:0] ImmExt,
    input  wire        ALUSrc,

    output wire [31:0] B
);

    assign B = ALUSrc ? ImmExt : WD;

endmodule