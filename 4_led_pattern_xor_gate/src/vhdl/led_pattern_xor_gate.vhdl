-- led_pattern_xor_gate.vhdl
-- This is the top-level VHDL file for the led_pattern_xor_gate project.
-- The LED is controlled using an XOR gate with two input buttons.

library ieee;
use ieee.std_logic_1164.all;

entity led_pattern_xor_gate is
    port (
        clk_raw : in std_logic;
        rst : in std_logic;
        button1 : in std_logic;
        button2 : in std_logic;
        led : out std_logic
    );
end entity led_pattern_xor_gate;

architecture Behavioral of led_pattern_xor_gate is
    signal clk : std_logic;
    signal xor_output : std_logic;

    -- PLL component declaration
    component pll is
        port (
            clk_in  : in std_logic;
            clk_out : out std_logic;
            locked  : out std_logic
        );
    end component pll;

    -- XOR gate component declaration
    component xor_gate is
        port (
            button1 : in std_logic;
            button2 : in std_logic;
            xor_output : out std_logic
        );
    end component xor_gate;

begin

    -- PLL instantiation
    pll_inst : pll
        port map(
            clk_in  => clk_raw,
            clk_out => clk,
            locked  => open
        );

    -- XOR gate instantiation
    xor_gate_inst : xor_gate
        port map(
            button1 => button1,
            button2 => button2,
            xor_output => xor_output
        );

    -- Assign the XOR gate output to the LED
    led <= xor_output;

end architecture Behavioral;
