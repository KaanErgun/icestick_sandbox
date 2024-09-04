-- binary_counter.vhdl
-- Top-level VHDL file for the binary counter project.
-- This counter toggles each LED connected to the FPGA every 500 ms.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_counter is
    port (
        clk_raw : in std_logic;  -- Raw clock input
        rst     : in std_logic;  -- Reset input
        led1    : out std_logic; -- LED 1 output
        led2    : out std_logic; -- LED 2 output
        led3    : out std_logic; -- LED 3 output
        led4    : out std_logic; -- LED 4 output
        led5    : out std_logic  -- LED 5 output
    );
end entity binary_counter;

architecture Behavioral of binary_counter is
    signal clk : std_logic;  -- Stabilized clock output from PLL
    signal counter : unsigned(4 downto 0) := (others => '0');  -- 5-bit unsigned counter
    signal locked : std_logic;
    signal slow_clk_counter : unsigned(23 downto 0) := (others => '0');  -- 24-bit counter for slow clock
    signal slow_clk : std_logic := '0';  -- Slow clock signal for 500 ms interval

    -- PLL component declaration
    component pll is
        port (
            clk_in  : in std_logic;   -- Input clock
            clk_out : out std_logic;  -- Output stabilized clock
            locked  : out std_logic   -- PLL lock status
        );
    end component pll;

    constant SLOW_CLK_COUNT_MAX : unsigned(23 downto 0) := x"5B8D80";  -- 500ms delay count for 12 MHz clock

begin
    -- PLL instantiation
    pll_inst : pll
        port map(
            clk_in  => clk_raw,
            clk_out => clk,
            locked  => locked
        );

    -- Slow clock generation process
    slow_clock_process: process(clk, rst)
    begin
        if rst = '1' then
            slow_clk_counter <= (others => '0');  -- Reset slow clock counter
            slow_clk <= '0';  -- Reset slow clock signal
        elsif rising_edge(clk) then
            if slow_clk_counter = SLOW_CLK_COUNT_MAX then
                slow_clk_counter <= (others => '0');  -- Reset counter
                slow_clk <= not slow_clk;  -- Toggle slow clock
            else
                slow_clk_counter <= slow_clk_counter + 1;  -- Increment counter
            end if;
        end if;
    end process;

    -- LED output assignments
    led1 <= counter(0);
    led2 <= counter(1);
    led3 <= counter(2);
    led4 <= counter(3);
    led5 <= counter(4);

    -- Counter process
    process(slow_clk, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');  -- Reset the counter
        elsif rising_edge(slow_clk) then
            if locked = '1' then
                counter <= counter + 1;  -- Increment counter at every 500ms
            end if;
        end if;
    end process;
end architecture Behavioral;
