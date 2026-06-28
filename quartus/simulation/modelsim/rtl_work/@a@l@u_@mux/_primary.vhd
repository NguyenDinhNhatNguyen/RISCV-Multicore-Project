library verilog;
use verilog.vl_types.all;
entity ALU_Mux is
    port(
        WD              : in     vl_logic_vector(31 downto 0);
        ImmExt          : in     vl_logic_vector(31 downto 0);
        ALUSrc          : in     vl_logic;
        B               : out    vl_logic_vector(31 downto 0)
    );
end ALU_Mux;
