-- xor_gate.vhdl
-- This is the VHDL file for the XOR gate component.
-- The output is HIGH when the inputs are different.

library ieee;
use ieee.std_logic_1164.all;

entity xor_gate is
    port (
        button1 : in std_logic;
        button2 : in std_logic;
        xor_output : out std_logic
    );
end entity xor_gate;

architecture Behavioral of xor_gate is
begin

    -- XOR gate logic
    xor_output <= button1 xor button2;

end architecture Behavioral;
