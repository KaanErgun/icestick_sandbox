-- led_pattern_and_gate.vhdl
-- This is the top-level VHDL file for the led_pattern_and_gate project.
-- The LED is controlled using an AND gate with two input buttons.

library ieee;
use ieee.std_logic_1164.all;

entity led_pattern_and_gate is
    port (
        clk_raw : in std_logic;
        rst : in std_logic;
        button1 : in std_logic;
        button2 : in std_logic;
        led : out std_logic
    );
end entity led_pattern_and_gate;

architecture Behavioral of led_pattern_and_gate is
    signal clk : std_logic;
    signal and_output : std_logic;

    -- PLL component declaration
    component pll is
        port (
            clk_in  : in std_logic;
            clk_out : out std_logic;
            locked  : out std_logic
        );
    end component pll;

    -- AND gate component declaration
    component and_gate is
        port (
            button1 : in std_logic;
            button2 : in std_logic;
            and_output : out std_logic
        );
    end component and_gate;

begin

    -- PLL instantiation
    pll_inst : pll
        port map(
            clk_in  => clk_raw,
            clk_out => clk,
            locked  => open
        );

    -- AND gate instantiation
    and_gate_inst : and_gate
        port map(
            button1 => button1,
            button2 => button2,
            and_output => and_output
        );

    -- Assign the AND gate output to the LED
    led <= and_output;

end architecture Behavioral;
