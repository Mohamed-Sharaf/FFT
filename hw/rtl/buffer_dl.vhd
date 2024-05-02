----------------------------------------------------------------
-- Entity declaration for a buffer_delay with a variable word width.
----------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY buffer_dl IS
    GENERIC (bit_width: integer := 1;
             stages: integer := 6);
    PORT( 
            clk, reset_n: IN std_logic;
            enable: IN std_logic;
            x: IN std_logic_vector (bit_width-1 DOWNTO 0);
            y: OUT std_logic_vector (bit_width-1 DOWNTO 0)
        );
END ENTITY buffer_dl;

ARCHITECTURE delay OF buffer_dl IS
  
type buffer_stages is array (0 to stages-1) of std_logic_vector (bit_width-1 downto 0);

signal buf_stages: buffer_stages;

BEGIN

  dl: PROCESS (clk, reset_n)
  BEGIN
    IF reset_n = '0' THEN
        rst: for i in 0 to stages-1 loop
           
            buf_stages(i) <= (others => '0');

        end loop rst;
--            y <= buf_stages(stages-1);
--
    ELSIF rising_edge (clk) THEN
        IF (enable = '1') THEN     
        buf_stages(0) <= x;
            
            buf: for i in 0 to stages-2 loop
                
                buf_stages(i+1) <= buf_stages(i);

            end loop buf;

--            y <= buf_stages(stages-1);
        END IF;
    END IF;
  END PROCESS dl;

  y <= buf_stages(stages-1);
  
END ARCHITECTURE delay;