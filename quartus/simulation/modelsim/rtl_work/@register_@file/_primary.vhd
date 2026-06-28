library verilog;
use verilog.vl_types.all;
entity Register_File is
    port(
        clk             : in     vl_logic;
        WE3             : in     vl_logic;
        RA1             : in     vl_logic_vector(4 downto 0);
        RA2             : in     vl_logic_vector(4 downto 0);
        WA3             : in     vl_logic_vector(4 downto 0);
        WD3             : in     vl_logic_vector(31 downto 0);
        RD1             : out    vl_logic_vector(31 downto 0);
        RD2             : out    vl_logic_vector(31 downto 0)
    );
end Register_File;
