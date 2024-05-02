LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity bfu_top is

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

end bfu_top ;

architecture arch of bfu_top is

	constant rm_im_width: integer := data_width / 2;
   
	signal c_plus_wire: std_logic_vector (data_width-1 DOWNTO 0) ;
	signal c_minus_wire: std_logic_vector (data_width-1 DOWNTO 0) ;

	signal c_minus_real: std_logic_vector (rm_im_width-1 DOWNTO 0) ;--:= c_minus_wire (rm_im_width-1 downto 0);
   	signal c_minus_img: std_logic_vector (rm_im_width-1 DOWNTO 0) ;--:= c_minus_wire (data_width-1 downto rm_im_width);


   	signal mult_result_real: std_logic_vector (data_width-1 DOWNTO 0);
   	signal mult_result_img: std_logic_vector (data_width-1 DOWNTO 0);

    
   	signal tw_real : std_logic_vector(15 downto 0);
   	signal tw_img : std_logic_vector(15 downto 0);

	signal scaled_mult_real : std_logic_vector (data_width-1 DOWNTO 0) ;--:= std_logic_vector(unsigned (mult_result_real) srl Q_POINT);
	signal scaled_mult_img : std_logic_vector (data_width-1 DOWNTO 0) ;--:= std_logic_vector(unsigned (mult_result_img) srl Q_POINT);
	
	
	COMPONENT tw_rom
	GENERIC( addr_width : integer := 2;
           data_width : integer := 32;
           INIT_F: string := "tw_rom_p_8_st_1_q_8.mem"
           );
	PORT(
		address : IN std_logic_vector(addr_width - 1 downto 0);          
		tw_real : OUT std_logic_vector((data_width/2)-1 downto 0);
		tw_img : OUT std_logic_vector((data_width/2)-1 downto 0)
		);
	END COMPONENT;

    COMPONENT cmx_mult
	generic (
		AWIDTH : integer := 16;
		BWIDTH : integer := 16
	  );
	PORT(
		clk : IN std_logic;
		reset_n : IN std_logic;
		ar : IN std_logic_vector(15 downto 0);
		ai : IN std_logic_vector(15 downto 0);
		br : IN std_logic_vector(15 downto 0);
		bi : IN std_logic_vector(15 downto 0);          
		pr : OUT std_logic_vector(31 downto 0);
		pi : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

    COMPONENT buffer_dl
	GENERIC (bit_width: integer := 32;
             stages: integer := 6);
	PORT(
		clk : IN std_logic;
		reset_n : IN std_logic;
		enable: IN std_logic;
		x : IN std_logic_vector(31 downto 0);          
		y : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	COMPONENT bfu_add_sub
	generic (
        data_width : integer := 32
    );
	PORT(
		IN_1 : IN std_logic_vector(31 downto 0);
		IN_2 : IN std_logic_vector(31 downto 0);          
		OUT_PLUS : OUT std_logic_vector(31 downto 0);
		OUT_MINUS : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;




component buffer_enable
    GENERIC (stages: integer := 6);
    PORT( 
            clk, reset_n: IN std_logic;
            enable: IN std_logic;
            x: IN std_logic;
            y: OUT std_logic
        );
END component buffer_enable;



begin

	Inst_tw_rom: tw_rom 
	generic map (
		addr_width => addr_width,
		data_width => data_width,
		INIT_F => INIT_F
	)
	PORT MAP(
		address => tw_addr ,     --address => tw_addr
		tw_real => tw_real,
		tw_img => tw_img
	);
    
    Inst_cmx_mult: cmx_mult 
	generic map (
		AWIDTH => rm_im_width,
		BWIDTH => rm_im_width
	)
	PORT MAP(
		clk => clk,
		reset_n => reset_n,
		ar => c_minus_real,
		ai => c_minus_img,
		br => tw_real,
		bi => tw_img,
		pr => mult_result_real,
		pi => mult_result_img
	);

	Inst_bfu_add_sub: bfu_add_sub 
	generic map (
		data_width => data_width
		)
	PORT MAP(
		IN_1 => IN_1,
		IN_2 => IN_2,
		OUT_PLUS => c_plus_wire,
		OUT_MINUS => c_minus_wire
			);

	Inst_buffer_dl: buffer_dl 
	generic map (
		bit_width => data_width,
		stages => MULT_CYC
		)
	PORT MAP(
		clk => clk,
		reset_n => reset_n,
		enable => '1',
		x => c_plus_wire,
		y => OUT_PLUS
	);

	

inst_buf_enable: buffer_enable
    GENERIC map (stages  => MULT_CYC)
    PORT map( 
            clk => clk,
				reset_n =>reset_n,
            enable => '1',
            x=> in_valid,
            y=> OUT_EN
        );





	c_minus_real <= c_minus_wire (rm_im_width-1 downto 0);
	c_minus_img  <= c_minus_wire (data_width-1 downto rm_im_width);

	scaled_mult_real <= std_logic_vector(unsigned (mult_result_real) srl Q_POINT);
	scaled_mult_img  <= std_logic_vector(unsigned (mult_result_img) srl Q_POINT);

	OUT_MINUS <= (scaled_mult_img (15 downto 0) & scaled_mult_real (15 downto 0) );

end architecture ; -- arch