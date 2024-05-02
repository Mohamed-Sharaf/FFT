-------------------------------------------
-- A ROM 
-------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;


USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;


ENTITY rom_asy IS
  GENERIC( addr_width : integer := 2;
           data_width : integer := 32;
			--  ram_depth  : integer := 4;
           INIT_F: string := "tw_rom_p_8_st_1_q_8.mem"
			  );
  PORT(	
      address: IN std_logic_vector (addr_width-1 DOWNTO 0);
      data: OUT std_logic_vector (data_width-1 DOWNTO 0)
    );
END ENTITY rom_asy;


------------------------------------------
-- Initializing the ROM from a text file
------------------------------------------


ARCHITECTURE file_funct_arch OF rom_asy IS
  TYPE ram_type IS ARRAY (0 TO (2**address'length-1)) OF std_logic_vector (data_width-1 DOWNTO 0);
  
  

impure function init_ram_hex return ram_type is
  file text_file : text open read_mode is INIT_F;
  variable text_line : line;
  variable ram_content : ram_type;
 
begin
  for i in 0 to 2**address'length - 1 loop
	if(not endfile(text_file)) then
    readline(text_file, text_line);
    hread(text_line, ram_content(i));
	else
	exit;
  end if;
  end loop;
  
  return ram_content;
end function;


signal ram_hex : ram_type := init_ram_hex;


BEGIN
  memory_b: PROCESS (address) 
	variable conv :  integer range 0 to (2**address'length -1); 
  BEGIN
   conv := to_integer(unsigned(address));

      data <= ram_hex (conv);
  
  END PROCESS memory_b;
END ARCHITECTURE file_funct_arch;