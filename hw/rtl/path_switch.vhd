Library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.numeric_std.all;


entity path_switch is

  generic (
    FFT_POINTS  : integer := 8;
    DELAY_CTRL  : integer := 1;           
    
    data_width  : integer := 32
  );

  port (
      clk : IN std_logic;
      reset_n : IN std_logic;
      in_valid: IN std_logic;
      IN_1: IN std_logic_vector (data_width-1 DOWNTO 0);
      IN_2: IN std_logic_vector (data_width-1 DOWNTO 0);
      OUT_1: OUT std_logic_vector (data_width-1 DOWNTO 0);
      OUT_2: OUT std_logic_vector (data_width-1 DOWNTO 0);
      OUT_EN: OUT std_logic
  );

end path_switch ;

ARCHITECTURE mix_delay OF path_switch IS

-- function log2_unsigned ( x : natural ) return natural is
--   variable temp : natural := x ;
--   variable n : natural := 0 ;
-- begin
--   while temp > 1 loop
--       temp := temp / 2 ;
--       n := n + 1 ;
--   end loop ;
--   return n ;
-- end function log2_unsigned ;

function LOG2(a:INTEGER) return INTEGER is -- COUNT should be >0
  variable TEMP:INTEGER;
  variable COUNT:INTEGER := a;
  
  begin
    TEMP:=0;
    while COUNT>1 loop
      TEMP:=TEMP+1;
      COUNT:=(COUNT /2);
    end loop;
    return�TEMP;
  end;

constant  count_width : integer := LOG2(FFT_POINTS);
constant IO_BUF_DEL  : integer := (2**DELAY_CTRL);
signal IN_2_new : std_logic_vector (data_width-1 DOWNTO 0);

signal mux_out_br1 : std_logic_vector (data_width-1 DOWNTO 0);  -- branch 1
signal mux_out_br2 : std_logic_vector (data_width-1 DOWNTO 0);
signal mux_sw_condition : std_logic;

signal buf_w_count : std_logic_vector(count_width-1 downto 0);

COMPONENT buffer_dl
	GENERIC (
    bit_width: integer := 32;
    stages: integer := 6
    );
	PORT(
		clk : IN std_logic;
		reset_n : IN std_logic;
    enable : IN std_logic;
		x : IN std_logic_vector(31 downto 0);          
		y : OUT std_logic_vector(31 downto 0)
		);
END COMPONENT;


COMPONENT buffer_enable
	GENERIC (stages: integer := 6);
	
	PORT(
		clk : IN std_logic;
		reset_n : IN std_logic;
		enable : IN std_logic;
		x : IN std_logic;          
		y : OUT std_logic
		);
	END COMPONENT;


BEGIN



Inst_buffer_enable: buffer_enable

generic map (stages => IO_BUF_DEL)
 PORT MAP(
		clk => clk,
		reset_n => reset_n,
		enable => '1',
		x =>  in_valid,
		y => OUT_EN
	);


Inst_buffer_minus: buffer_dl 
	generic map (
		bit_width => data_width,
    stages => IO_BUF_DEL
		)
	PORT MAP(
		clk => clk,
		reset_n => reset_n,
    enable => '1',
		x => IN_2,
		y => IN_2_new
	);

Inst_buffer_plus: buffer_dl 
	generic map (
		bit_width => data_width,
    stages => IO_BUF_DEL
		)
	PORT MAP(
		clk => clk,
		reset_n => reset_n,
    enable => '1',
		x => mux_out_br1,
		y => OUT_1
	);


control_counter: PROCESS (clk, reset_n)
  BEGIN
    IF reset_n = '0' THEN
        
      buf_w_count <= (others => '0');

    ELSIF rising_edge (clk) THEN
    
      IF (in_valid = '1') THEN 
       -- buf_w_count <= std_logic_vector ((unsigned(buf_w_count)) + '1');
		  buf_w_count <=std_logic_vector(to_unsigned(to_integer(unsigned( buf_w_count )) + 1, count_width));
			--buf_w_count <= buf_w_count + '1';
		END IF;
    
    END IF;
  END PROCESS control_counter;

-- switch: PROCESS (mux_sw_condition)
--   BEGIN

  mux_sw_condition <= not buf_w_count(DELAY_CTRL);

  mux_out_br1 <= IN_1 when (mux_sw_condition = '1') else IN_2_new;
  mux_out_br2 <= IN_2_new when (mux_sw_condition = '1') else IN_1;

  OUT_2 <= mux_out_br2;

END ARCHITECTURE mix_delay;