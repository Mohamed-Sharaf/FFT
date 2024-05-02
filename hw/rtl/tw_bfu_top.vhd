LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;



entity tw_bfu_top is

    generic (
		FFT_POINTS : integer := 8;
		FFT_STAGE  : integer := 1;
        data_width : integer := 32;
		MULT_CYC   : integer := 6;
		ROM_FILE   : string  := "tw_rom_p_8_st_1_q_8.mem"
    );

    port (
        clk : IN std_logic;
		reset_n : IN std_logic;
        IN_1: IN std_logic_vector (data_width-1 DOWNTO 0);
        IN_2: IN std_logic_vector (data_width-1 DOWNTO 0);
		in_valid: IN std_logic;
        OUT_PLUS: OUT std_logic_vector (data_width-1 DOWNTO 0);
        OUT_MINUS: OUT std_logic_vector (data_width-1 DOWNTO 0);
		OUT_EN: OUT std_logic
    );

end tw_bfu_top ;

architecture arch_tw of tw_bfu_top is

	function LOG2(a:INTEGER) return INTEGER is -- COUNT should be >0
		variable TEMP:INTEGER;
		variable COUNT:INTEGER := a;
		
		begin
		if  COUNT = 1 or COUNT = 0 then  -- trivial rejection and acceptance
			return COUNT;
		 end if;
		  TEMP:=0;
		  while COUNT>1 loop
			TEMP:=TEMP+1;
			COUNT:=(COUNT /2);
		  end loop;
		  return TEMP;
		end;


--constant  num_addr : integer :=(FFT_POINTS srl 1);
	--constant  num_addr : integer := to_integer (to_bitvector (FFT_POINTS) srl FFT_STAGE);
	constant for_shift : integer := (2** FFT_STAGE);
	constant  num_addr : integer := (FFT_POINTS)/ for_shift;
	constant  tw_addr_bits : integer := LOG2(num_addr);
	

	signal tw_count, tw_addr_count : std_logic_vector(tw_addr_bits-1 downto 0);

	COMPONENT bfu_top
	generic (
        data_width : integer := 32;
        addr_width : integer := 2;           --=8
		Q_POINT    : integer := 8;
		MULT_CYC   : integer := 6;
		INIT_F: string := "tw_rom_p_8_st_1_q_8.mem"
    );

    port (
        clk : IN std_logic;
		reset_n : IN std_logic;
        IN_1: IN std_logic_vector (data_width-1 DOWNTO 0);
        IN_2: IN std_logic_vector (data_width-1 DOWNTO 0);
		in_valid: IN std_logic;
        tw_addr: IN std_logic_vector (addr_width-1 DOWNTO 0);
        OUT_PLUS: OUT std_logic_vector (data_width-1 DOWNTO 0);
        OUT_MINUS: OUT std_logic_vector (data_width-1 DOWNTO 0);
		OUT_EN: OUT std_logic
    );
	END COMPONENT;

begin

	--tw_generate: if (tw_addr_bits > 0) generate

	Inst_tw_bfu: bfu_top
	generic map(
        data_width => data_width,
        addr_width => tw_addr_bits,          
		INIT_F => ROM_FILE
    )

    port map(
        clk => clk,
		reset_n => reset_n,
        IN_1 => IN_1,
        IN_2 => IN_2,
		in_valid => in_valid,
        tw_addr => tw_addr_count,
        OUT_PLUS => OUT_PLUS,
        OUT_MINUS => OUT_MINUS,
		OUT_EN => OUT_EN
    );

--	else generate
--
--	Inst_bfu: bfu_top
--	generic map(
--        data_width => data_width,
--        addr_width => tw_addr_bits,          
--		INIT_F => ROM_FILE
--    )
--
--    port map(
--        clk => clk,
--		reset_n => reset_n,
--        IN_1 => IN_1,
--        IN_2 => IN_2,
--		in_valid => in_valid,
--        tw_addr => "00",
--        OUT_PLUS => OUT_PLUS,
--        OUT_MINUS => OUT_MINUS,
--		OUT_EN => OUT_EN
--    );
--
--	end generate tw_generate;
			
	address_counter: PROCESS (clk, reset_n)
	BEGIN
	  IF reset_n = '0' THEN
		  
		tw_count <= (others => '0');
  
	  ELSIF rising_edge (clk) THEN
	  
		IF (in_valid = '1') THEN 
		 
			tw_count <=std_logic_vector(to_unsigned(to_integer(unsigned( tw_count )) + 1, tw_addr_bits));
			  
		  END IF;
	  
	  END IF;
	END PROCESS address_counter;
	
	tw_addr_count <= tw_count when(tw_addr_bits > 0) else (others => '0');

end architecture ; -- arch