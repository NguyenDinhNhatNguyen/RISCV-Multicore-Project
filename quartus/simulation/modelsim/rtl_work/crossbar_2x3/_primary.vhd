library verilog;
use verilog.vl_types.all;
entity crossbar_2x3 is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        m0_valid        : in     vl_logic;
        m0_write        : in     vl_logic;
        m0_addr         : in     vl_logic_vector(31 downto 0);
        m0_wdata        : in     vl_logic_vector(31 downto 0);
        m0_rdata        : out    vl_logic_vector(31 downto 0);
        m0_grant        : out    vl_logic;
        m0_stall        : out    vl_logic;
        m0_error        : out    vl_logic;
        m1_valid        : in     vl_logic;
        m1_write        : in     vl_logic;
        m1_addr         : in     vl_logic_vector(31 downto 0);
        m1_wdata        : in     vl_logic_vector(31 downto 0);
        m1_rdata        : out    vl_logic_vector(31 downto 0);
        m1_grant        : out    vl_logic;
        m1_stall        : out    vl_logic;
        m1_error        : out    vl_logic;
        s0_valid        : out    vl_logic;
        s0_write        : out    vl_logic;
        s0_addr         : out    vl_logic_vector(31 downto 0);
        s0_wdata        : out    vl_logic_vector(31 downto 0);
        s0_rdata        : in     vl_logic_vector(31 downto 0);
        s1_valid        : out    vl_logic;
        s1_write        : out    vl_logic;
        s1_addr         : out    vl_logic_vector(31 downto 0);
        s1_wdata        : out    vl_logic_vector(31 downto 0);
        s1_rdata        : in     vl_logic_vector(31 downto 0);
        s2_valid        : out    vl_logic;
        s2_write        : out    vl_logic;
        s2_addr         : out    vl_logic_vector(31 downto 0);
        s2_wdata        : out    vl_logic_vector(31 downto 0);
        s2_rdata        : in     vl_logic_vector(31 downto 0)
    );
end crossbar_2x3;
