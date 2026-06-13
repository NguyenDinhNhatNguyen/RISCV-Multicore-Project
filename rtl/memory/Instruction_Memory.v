module Instruction_Memory #(
    parameter FILE_NAME = "instructions.txt"
) (
    input [31:0]  A,
    output [31:0] RD
);
   
   reg [31:0] I_MEM_BLOCK[255:0];

   initial begin
      $readmemh(FILE_NAME, I_MEM_BLOCK);
/*
      I_MEM_BLOCK[0] = 32'h02000093; // addi x1, x0, 0x20
      I_MEM_BLOCK[1] = 32'h01100113; // addi x2, x0, 0x11
      I_MEM_BLOCK[2] = 32'h0020A023; // sw   x2, 0(x1)
      I_MEM_BLOCK[3] = 32'h0000A183; // lw   x3, 0(x1)
      I_MEM_BLOCK[4] = 32'h00100213; // addi x4, x0, 0x01
      I_MEM_BLOCK[5] = 32'h0040A223; // sw   x4, 4(x1)
      I_MEM_BLOCK[6] = 32'h0000006F; // jal  x0, 0
*/
   end

   assign RD = I_MEM_BLOCK[A[31:2]];
endmodule