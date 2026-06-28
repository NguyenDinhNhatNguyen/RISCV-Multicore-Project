library verilog;
use verilog.vl_types.all;
entity Main_Decoder is
    port(
        op              : in     vl_logic_vector(6 downto 0);
        ResultSrc       : out    vl_logic_vector(1 downto 0);
        MemWrite        : out    vl_logic;
        Branch          : out    vl_logic;
        ALUSrc          : out    vl_logic;
        RegWrite        : out    vl_logic;
        Jump            : out    vl_logic;
        ImmSrc          : out    vl_logic_vector(1 downto 0);
        ALUop           : out    vl_logic_vector(1 downto 0)
    );
end Main_Decoder;
