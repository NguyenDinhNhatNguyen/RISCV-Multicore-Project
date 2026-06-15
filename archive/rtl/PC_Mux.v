`timescale 1ns / 1ps

module PC_Mux (
	       input wire [31:0]  PC_Plus_4,PC_Target,
	       input wire 	  PCSrc,
	       output wire [31:0] PC_Next
	       );

   assign PC_Next = PCSrc ? PC_Target : PC_Plus_4;

endmodule