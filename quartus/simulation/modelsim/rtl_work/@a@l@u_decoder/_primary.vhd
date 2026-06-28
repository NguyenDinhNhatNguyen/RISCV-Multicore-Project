library verilog;
use verilog.vl_types.all;
entity ALU_decoder is
    port(
        opb5            : in     vl_logic;
        funct3          : in     vl_logic_vector(2 downto 0);
        funct7b5        : in     vl_logic;
        ALUOp           : in     vl_logic_vector(1 downto 0);
        ALUControl      : out    vl_logic_vector(3 downto 0)
    );
end ALU_decoder;
