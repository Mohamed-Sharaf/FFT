Library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity cmx_adder is

 generic (
    data_width : integer := 32);



  Port (
  x   : in  STD_LOGIC_VECTOR (data_width-1 downto 0);
  y   : in  STD_LOGIC_VECTOR (data_width-1 downto 0);
  sub : in std_logic;
  z   : out  STD_LOGIC_VECTOR (data_width-1 downto 0)
  
  );
end cmx_adder;


architecture behav of cmx_adder is
  
  signal x_real : STD_LOGIC_VECTOR ((data_width/2)-1 downto 0);
  signal x_im : STD_LOGIC_VECTOR ((data_width/2)-1 downto 0);
  
  signal y_real : STD_LOGIC_VECTOR ((data_width/2)-1 downto 0);
  signal y_im : STD_LOGIC_VECTOR ((data_width/2)-1 downto 0);

  --signal z_real : STD_LOGIC_VECTOR (15 downto 0);
  --signal z_im : STD_LOGIC_VECTOR (15 downto 0);
  
  
begin

    x_real <= x((data_width/2)-1 downto 0);
    x_im <= x(data_width-1 downto (data_width/2));
    
    y_real <= y((data_width/2)-1 downto 0);
    y_im <= y(data_width-1 downto (data_width/2));

    --adding : process(x, y, sub)
    adding : process(x_real, x_im, y_real, y_im, sub)


    variable z_real : STD_LOGIC_VECTOR ((data_width/2)-1 downto 0) := (others => '0');
    variable z_im : STD_LOGIC_VECTOR ((data_width/2)-1 downto 0) := (others => '0');

    begin
     

      if sub='1' then                               --subtraction
        z_im := std_logic_vector (unsigned(x_im) - unsigned(y_im));    --im part
        z_real := std_logic_vector (unsigned(x_real) - unsigned(y_real)); --real part

        z(data_width-1 downto (data_width/2)) <= z_im;
        z((data_width/2)-1 downto 0) <= z_real;

        
      else
       z_im := std_logic_vector (unsigned(x_im) + unsigned(y_im));
       z_real := std_logic_vector (unsigned(x_real) + unsigned(y_real));
       
       z(data_width-1 downto (data_width/2)) <= z_im;
       z((data_width/2)-1 downto 0) <= z_real; 
      end if;

    --z(31 downto 16) <= z_im;
    --z(15 downto 0) <= z_real;

    end process adding;
    
   
  end architecture behav;