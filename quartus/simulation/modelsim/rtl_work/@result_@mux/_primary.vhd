library verilog;
use verilog.vl_types.all;
entity Result_Mux is
    port(
        ALUResult       : in     vl_logic_vector(31 downto 0);
        ReadData        : in     vl_logic_vector(31 downto 0);
        PC_Plus_4       : in     vl_logic_vector(31 downto 0);
        ResultSrc       : in     vl_logic_vector(31 downto 0);
        Result          : out    vl_logic_vector(31 downto 0)
    );
end Result_Mux;
