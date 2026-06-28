library verilog;
use verilog.vl_types.all;
entity PC_Target is
    port(
        PC              : in     vl_logic_vector(31 downto 0);
        ImmExt          : in     vl_logic_vector(31 downto 0);
        PCTarget        : out    vl_logic_vector(31 downto 0)
    );
end PC_Target;
