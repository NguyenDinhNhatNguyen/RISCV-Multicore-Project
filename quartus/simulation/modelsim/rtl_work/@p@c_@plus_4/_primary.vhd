library verilog;
use verilog.vl_types.all;
entity PC_Plus_4 is
    port(
        PC              : in     vl_logic_vector(31 downto 0);
        PCPlus4         : out    vl_logic_vector(31 downto 0)
    );
end PC_Plus_4;
