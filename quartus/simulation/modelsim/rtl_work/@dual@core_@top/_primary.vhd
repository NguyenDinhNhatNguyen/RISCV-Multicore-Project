library verilog;
use verilog.vl_types.all;
entity DualCore_Top is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        dummy_out       : out    vl_logic_vector(31 downto 0)
    );
end DualCore_Top;
