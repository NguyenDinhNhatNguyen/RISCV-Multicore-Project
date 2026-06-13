`timescale 1ns / 1ps

module PC (	
		input wire 	   clk, reset, stall,
		input wire [31:0]  PCNext,
		output wire [31:0] PC );
   
   reg [31:0] 			   PCReg;

   always@(posedge clk or negedge reset) begin
	  if (!reset) begin
      PCReg <= 32'h0;
    end
	  else begin 
      if (stall == 1'b0) begin 
        PCReg <= PCNext;
      end
    end
   end

   assign PC = PCReg;

endmodule
