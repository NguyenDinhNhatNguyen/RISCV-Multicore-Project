library verilog;
use verilog.vl_types.all;
entity RISCV_Core is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        ext_irq         : in     vl_logic;
        Instr           : in     vl_logic_vector(31 downto 0);
        PC              : out    vl_logic_vector(31 downto 0);
        gnt             : in     vl_logic;
        mem_rdata       : in     vl_logic_vector(31 downto 0);
        mem_req         : out    vl_logic;
        mem_wen         : out    vl_logic;
        mem_addr        : out    vl_logic_vector(31 downto 0);
        mem_wdata       : out    vl_logic_vector(31 downto 0)
    );
end RISCV_Core;
