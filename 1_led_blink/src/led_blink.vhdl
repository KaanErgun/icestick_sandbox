library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_blink is
  port (
    clk_raw : in std_logic;
    led1, led2, led3, led4, led5 : out std_logic
  );
end led_blink;

architecture behav of led_blink is
  signal clk : std_logic;
  signal nrst, rst : std_logic := '0';
  signal counter : unsigned(23 downto 0) := (others => '0');  -- 24-bit counter for delay
  signal led_counter : unsigned(2 downto 0) := (others => '0'); -- 3-bit counter for 5 LEDs (0-4 arası)

  component pll is
    port (
      clk_in  : in std_logic;
      clk_out : out std_logic;
      locked  : out std_logic
    );
  end component pll;

begin

  -- PLL instantiation
  pll_inst : pll
    port map(
      clk_in  => clk_raw,
      clk_out => clk,
      locked  => open
    );

  -- Reset signal generation
  process (clk)
    variable cnt : unsigned (1 downto 0) := "00";
  begin
    if rising_edge(clk) then
      if cnt = 3 then
        nrst <= '1';
      else
        cnt := cnt + 1;
      end if;
    end if;
  end process;

  rst <= not nrst;

  -- LED blink process
  process (clk)
  begin
    if rst = '1' then
      counter <= (others => '0');
      led_counter <= (others => '0');
    elsif rising_edge(clk) then
      if counter = x"FFFFFF" then  -- Adjust delay here
        counter <= (others => '0');
        if led_counter = "100" then  -- Reset when reaching 5th LED (binary 4)
          led_counter <= (others => '0');
        else
          led_counter <= led_counter + 1;
        end if;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;

  -- Assign led_counter to LEDs
  led1 <= '1' when led_counter = "000" else '0';
  led2 <= '1' when led_counter = "001" else '0';
  led3 <= '1' when led_counter = "010" else '0';
  led4 <= '1' when led_counter = "011" else '0';
  led5 <= '1' when led_counter = "100" else '0';

end behav;
