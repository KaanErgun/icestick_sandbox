-- led_pattern_xor_gate.vhdl
-- This is the top-level VHDL file for the led_pattern_xor_gate project.
-- All LEDs are initialized to HIGH, with a PLL for clock stabilization.

library ieee;
use ieee.std_logic_1164.all;

entity led_pattern_xor_gate is
    port (
        clk_raw : in std_logic;
        rst : in std_logic;
        led : out std_logic
    );
end entity led_pattern_xor_gate;

architecture Behavioral of led_pattern_xor_gate is
    signal clk : std_logic;
    signal led_signal : std_logic := '1'; -- Initialize the LED signal to HIGH

    -- PLL component declaration
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

    -- Assign the signal to the output port
    led <= led_signal;

    led_process: process(clk, rst)
    begin
        if rst = '1' then
            led_signal <= '1'; -- Set LED to HIGH on reset
        elsif rising_edge(clk) then
            -- Logic for LED control (can be customized here)
            led_signal <= not led_signal;
        end if;
    end process;
end architecture Behavioral;
