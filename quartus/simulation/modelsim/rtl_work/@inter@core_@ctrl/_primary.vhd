library verilog;
use verilog.vl_types.all;
entity InterCore_Ctrl is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        icc_valid       : in     vl_logic;
        icc_write       : in     vl_logic;
        icc_addr        : in     vl_logic_vector(31 downto 0);
        icc_wdata       : in     vl_logic_vector(31 downto 0);
        icc_rdata       : out    vl_logic_vector(31 downto 0);
        irq_core0       : out    vl_logic;
        irq_core1       : out    vl_logic
    );
end InterCore_Ctrl;
