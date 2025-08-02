-- shift_register_led_pattern.vhdl
-- This is the top-level VHDL file for the shift_register_led_pattern project.
-- Implements a shift register that sequentially lights up LEDs in a pattern.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_register_led_pattern is
    port (
        clk_raw : in std_logic;  -- Raw clock input
        rst     : in std_logic;  -- Reset input (optional)
        led1    : out std_logic; -- LED 1 output
        led2    : out std_logic; -- LED 2 output
        led3    : out std_logic; -- LED 3 output
        led4    : out std_logic; -- LED 4 output
        led5    : out std_logic  -- LED 5 output
    );
end entity shift_register_led_pattern;

architecture Behavioral of shift_register_led_pattern is
    signal clk : std_logic;  -- Stabilized clock output from PLL
    signal locked : std_logic;
    signal shift_register : std_logic_vector(4 downto 0) := "10000";  -- 5-bit shift register, start with first LED on
    signal slow_clk_counter : unsigned(23 downto 0) := (others => '0');  -- 24-bit counter for slow clock
    signal slow_clk : std_logic := '0';  -- Slow clock signal for visible LED shifting

    -- PLL component declaration
    component pll is
        port (
            clk_in  : in std_logic;   -- Input clock
            clk_out : out std_logic;  -- Output stabilized clock
            locked  : out std_logic   -- PLL lock status
        );
    end component pll;

    -- Constant for slow clock generation (approximately 500ms at 12 MHz)
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
    led1 <= shift_register(0);
    led2 <= shift_register(1);
    led3 <= shift_register(2);
    led4 <= shift_register(3);
    led5 <= shift_register(4);

    -- Shift register process
    shift_process: process(slow_clk, rst)
    begin
        if rst = '1' then
            shift_register <= "10000";  -- Reset to initial pattern (only first LED on)
        elsif rising_edge(slow_clk) then
            -- Shift the register to the left, and wrap around
            shift_register <= shift_register(3 downto 0) & shift_register(4);
        end if;
    end process;
end architecture Behavioral;
