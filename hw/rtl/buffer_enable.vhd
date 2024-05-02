LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY buffer_enable IS
    GENERIC (stages: integer := 6);
    PORT( 
            clk, reset_n: IN std_logic;
            enable: IN std_logic;
            x: IN std_logic;
            y: OUT std_logic
        );
END ENTITY buffer_enable;

ARCHITECTURE delay OF buffer_enable IS
  
type buffer_stages is array (0 to stages-1) of std_logic;

signal buf_stages: buffer_stages;

--signal buf_stages: std_logic_vector (0 to stages-1);

BEGIN

  dl: PROCESS (clk, reset_n)
  BEGIN
    IF reset_n = '0' THEN
        rst: for i in 0 to stages-1 loop
           
            buf_stages(i) <=  '0';

        end loop rst;
           -- y <= '0';

    ELSIF rising_edge (clk) THEN
        IF (enable = '1') THEN     
        buf_stages(0) <= x;
            
            buf: for i in 0 to stages-2 loop
                
                buf_stages(i+1) <= buf_stages(i);

            end loop buf;

        END IF;
    END IF;
  END PROCESS dl;
            y <= buf_stages(stages-1);

  
END ARCHITECTURE delay;