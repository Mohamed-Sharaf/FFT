Library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_signed.all;

entity cmx_mult is
  generic (
    AWIDTH : integer := 16;
    BWIDTH : integer := 16
  );
  port (
    clk      : in std_logic;
    reset_n  : in std_logic;
    ar       : in std_logic_vector(AWIDTH-1 downto 0);
    ai       : in std_logic_vector(AWIDTH-1 downto 0);
    br       : in std_logic_vector(BWIDTH-1 downto 0);
    bi       : in std_logic_vector(BWIDTH-1 downto 0);
    pr, pi   : out std_logic_vector(AWIDTH+BWIDTH-1 downto 0)
  );
end entity cmx_mult;

architecture Behavioral of cmx_mult is
  signal ai_d, ai_dd, ai_ddd, ai_dddd : std_logic_vector(AWIDTH-1 downto 0);
  signal ar_d, ar_dd, ar_ddd, ar_dddd : std_logic_vector(AWIDTH-1 downto 0);
  signal bi_d, bi_dd, bi_ddd, br_d, br_dd, br_ddd : std_logic_vector(BWIDTH-1 downto 0);
  signal addcommon : std_logic_vector(AWIDTH-1 downto 0);
  signal addr, addi : std_logic_vector(BWIDTH-1 downto 0);
  signal mult0, multr, multi, pr_int, pi_int : std_logic_vector(AWIDTH+BWIDTH-1 downto 0);
  signal common, commonr1, commonr2 : std_logic_vector(AWIDTH+BWIDTH-1 downto 0);

begin

  process(clk, reset_n)
  begin
    if (reset_n = '0') then
      ar_d   <= (others => '0');
      ar_dd  <= (others => '0');
      ai_d   <= (others => '0');
      ai_dd  <= (others => '0');
      br_d   <= (others => '0');
      br_dd  <= (others => '0');
      br_ddd <= (others => '0');
      bi_d   <= (others => '0');
      bi_dd  <= (others => '0');
      bi_ddd <= (others => '0');
    elsif (rising_edge(clk)) then
      ar_d   <= std_logic_vector(signed(ar));
      ar_dd  <= std_logic_vector(signed(ar_d));
      ai_d   <= std_logic_vector(signed(ai));
      ai_dd  <= std_logic_vector(signed(ai_d));
      br_d   <= std_logic_vector(signed(br));
      br_dd  <= std_logic_vector(signed(br_d));
      br_ddd <= std_logic_vector(signed(br_dd));
      bi_d   <= std_logic_vector(signed(bi));
      bi_dd  <= std_logic_vector(signed(bi_d));
      bi_ddd <= std_logic_vector(signed(bi_dd));
    end if;
  end process;

  process(clk, reset_n)
  begin
    if (reset_n = '0') then
      addcommon <= (others => '0');
      mult0     <= (others => '0');
      common    <= (others => '0');
    elsif (rising_edge(clk)) then
      addcommon <=  std_logic_vector(signed(ar_d - ai_d));
      mult0     <= addcommon * bi_dd;
      common    <= mult0;
    end if;
  end process;

  process(clk, reset_n)
  begin
    if (reset_n = '0') then
      ar_ddd   <= (others => '0');
      ar_dddd  <= (others => '0');
      addr     <= (others => '0');
      multr    <= (others => '0');
      commonr1 <= (others => '0');
      pr_int   <= (others => '0');
    elsif (rising_edge(clk)) then
      ar_ddd   <=  std_logic_vector(signed(ar_dd));
      ar_dddd  <=  std_logic_vector(signed(ar_ddd));
      addr     <=  std_logic_vector(signed(br_ddd - bi_ddd));
      multr    <=  std_logic_vector(signed(addr * ar_dddd));
      commonr1 <=  std_logic_vector(signed(common));
      pr_int   <=  std_logic_vector(signed(multr + commonr1));
    end if;
  end process;

  process(clk, reset_n)
  begin
    if (reset_n = '0') then
      ai_ddd   <= (others => '0');
      ai_dddd  <= (others => '0');
      addi     <= (others => '0');
      multi    <= (others => '0');
      commonr2 <= (others => '0');
      pi_int   <= (others => '0');
    elsif (rising_edge(clk)) then
      ai_ddd   <= std_logic_vector(signed(ai_dd));
      ai_dddd  <= std_logic_vector(signed(ai_ddd));
      addi     <= std_logic_vector(signed(br_ddd )+ signed(bi_ddd));
      multi    <= std_logic_vector(signed(addi) *signed( ai_dddd));
      commonr2 <= std_logic_vector(signed(common));
      pi_int   <= std_logic_vector(signed(multi )+ signed(commonr2));
    end if;
  end process;

  pr <= std_logic_vector(signed(pr_int));
  pi <= std_logic_vector(signed(pi_int));

end architecture Behavioral;
