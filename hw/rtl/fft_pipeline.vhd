Library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.numeric_std.all;

entity fft_pipeline is

   generic (
		FFT_POINTS : integer := 8;
        data_width : integer := 32;
		MULT_CYC   : integer := 6
    );

    port (
        clk : IN std_logic;
		reset_n : IN std_logic;
        IN_a: IN std_logic_vector (data_width-1 DOWNTO 0);
        IN_b: IN std_logic_vector (data_width-1 DOWNTO 0);
		in_valid: IN std_logic;
        OUT_PLUS_r: OUT std_logic_vector (data_width-1 DOWNTO 0);
        OUT_MINUS_r: OUT std_logic_vector (data_width-1 DOWNTO 0);
		OUT_en_r: OUT std_logic
    );

end fft_pipeline ;


ARCHITECTURE struct OF fft_pipeline IS

function LOG2(a:INTEGER) return INTEGER is -- COUNT should be >0
    variable TEMP:INTEGER;
    variable COUNT:INTEGER := a;
    
    begin
      TEMP:=0;
      while COUNT>1 loop
        TEMP:=TEMP+1;
        COUNT:=(COUNT /2);
      end loop;
      return TEMP;
    end;

constant tw_stages : integer := LOG2(FFT_POINTS);

TYPE data_con_type IS ARRAY (1 TO tw_stages ) OF std_logic_vector (data_width-1 DOWNTO 0);
TYPE En_con_type IS ARRAY (1 TO tw_stages ) OF std_logic;
TYPE ce_con_type IS ARRAY (1 TO tw_stages-1 ) OF std_logic;

signal OUT_PLUS: data_con_type;
signal OUT_MINUS: data_con_type;

signal OUT_a: data_con_type;
signal OUT_b: data_con_type;

signal OUT_EN: En_con_type;
signal OUT_ce: ce_con_type;

-----------------------------------------------------------------------------------


component tw_bfu_top

    generic (
		FFT_POINTS : integer := 8;
		FFT_STAGE  : integer := 1;
        data_width : integer := 32;
		MULT_CYC   : integer := 6;
		ROM_FILE   : string  := ""
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
end component tw_bfu_top;



component path_switch

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

end component path_switch ;

-----------------------------------------------------------------------------------------

begin 
	tw_bfu_top_1: tw_bfu_top

 generic map (
		FFT_POINTS => 8,
		FFT_STAGE  => 1,
        data_width => 32,
		MULT_CYC   => 6,
		ROM_FILE   => "tw_rom_p_" & integer'image(FFT_POINTS) & "_st_1_q_8.mem"
    )

    port map(
        clk => clk,
		reset_n =>reset_n,
        IN_1 =>IN_a,
        IN_2 =>IN_b,
		in_valid =>in_valid,
        OUT_PLUS =>OUT_PLUS(1),
        OUT_MINUS =>OUT_MINUS(1),
		OUT_EN => OUT_EN(1)
    );
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------


    tw_bfu_loop : for i in 2 to tw_stages generate

        switch_unit : path_switch

        generic map(
          FFT_POINTS => FFT_POINTS,
          DELAY_CTRL => (tw_stages - i),    
          data_width  => data_width
        )
      
        port map(
            clk => clk,
            reset_n=> reset_n,
            in_valid =>OUT_EN(i-1),
            IN_1 =>OUT_PLUS(i-1),
            IN_2 =>OUT_MINUS(i-1),
            OUT_1 =>OUT_a(i-1),
            OUT_2 =>OUT_b(i-1),
            OUT_EN =>OUT_ce(i-1)
        );

        --------------------------------------------------------------------------------------------------------
        --------------------------------------------------------------------------------------------------------
        --------------------------------------------------------------------------------------------------------
        tw_bfu_unit : tw_bfu_top

        generic map (
               FFT_POINTS => FFT_POINTS,
               FFT_STAGE  => i,
               data_width => data_width,
               MULT_CYC   => MULT_CYC,
               ROM_FILE   => "tw_rom_p_" & integer'image(FFT_POINTS) & "_st_" & integer'image(i) & "_q_8.mem"
           )
       
           port map(
               clk => clk,
               reset_n =>reset_n,
               IN_1 =>OUT_a(i-1),
               IN_2 =>OUT_b(i-1),
               in_valid =>OUT_ce(i-1),
               OUT_PLUS =>OUT_PLUS(i),
               OUT_MINUS =>OUT_MINUS(i),
               OUT_EN => OUT_EN(i)
           );

    end generate tw_bfu_loop;

        OUT_PLUS_r <= OUT_PLUS (tw_stages);
        OUT_MINUS_r <= OUT_MINUS (tw_stages);
		OUT_en_r <= OUT_EN (tw_stages);

  END ARCHITECTURE struct;