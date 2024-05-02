LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity bfu_add_sub is

    generic (
        data_width : integer := 32
    );

    port (
        IN_1: IN std_logic_vector (data_width-1 DOWNTO 0);
        IN_2: IN std_logic_vector (data_width-1 DOWNTO 0);
        OUT_PLUS: OUT std_logic_vector (data_width-1 DOWNTO 0);
        OUT_MINUS: OUT std_logic_vector (data_width-1 DOWNTO 0)
    );

end bfu_add_sub ;

architecture arch of bfu_add_sub is

    COMPONENT cmx_adder
	PORT(
		x : IN std_logic_vector(31 downto 0);
		y : IN std_logic_vector(31 downto 0);
		sub : IN std_logic;          
		z : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;



begin

	Inst_cmx_adder: cmx_adder PORT MAP(
		x => IN_1,
		y => IN_2,
		sub => '0',
		z => OUT_PLUS
	);


	Inst_cmx_subtractor: cmx_adder PORT MAP(
		x => IN_1,
		y => IN_2,
		sub => '1',
		z => OUT_MINUS
	);

end architecture ; -- arch