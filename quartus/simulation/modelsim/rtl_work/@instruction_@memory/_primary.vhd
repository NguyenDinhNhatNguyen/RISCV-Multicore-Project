library verilog;
use verilog.vl_types.all;
entity Instruction_Memory is
    generic(
        FILE_NAME       : string  := "instructions.txt"
    );
    port(
        A               : in     vl_logic_vector(31 downto 0);
        RD              : out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FILE_NAME : constant is 1;
end Instruction_Memory;
