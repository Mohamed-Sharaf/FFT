-------------------------------------------
-- A ROM  
-------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;


USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY tw_rom IS
  GENERIC( addr_width : integer := 2;
           data_width : integer := 32;
           INIT_F: string := "tw_rom_p_8_st_1_q_8.mem"
           );
  PORT(	
      address: IN std_logic_vector (addr_width-1 DOWNTO 0);
      tw_real: OUT std_logic_vector ((data_width/2)-1 DOWNTO 0);
      tw_img: OUT std_logic_vector ((data_width/2)-1 DOWNTO 0)
    );
END ENTITY tw_rom;


------------------------------------------
-- Initializing the ROM from a text file
------------------------------------------

ARCHITECTURE funct_arch_complex OF tw_rom IS
   signal data_s : std_logic_vector ((data_width)-1 DOWNTO 0);
	
  COMPONENT rom_asy
  
		GENERIC( addr_width : integer := 2;
           data_width : integer := 32;
           INIT_F: string := "tw_rom_p_8_st_1_q_8.mem"
			  );
    PORT(
      address : IN std_logic_vector(addr_width-1 downto 0);          
      data : OUT std_logic_vector(data_width-1 downto 0)
      );
    END COMPONENT;

BEGIN

  Inst_rom_asy: rom_asy 
    generic map (
      addr_width => addr_width,
      data_width => data_width,
      INIT_F => INIT_F
    ) 
    PORT MAP(
      address => address,
      data => data_s
    );
	 
tw_real <= data_s ((data_width/2)-1 downto 0);
tw_img <= data_s (data_width-1 downto data_width/2);
END ARCHITECTURE funct_arch_complex;
