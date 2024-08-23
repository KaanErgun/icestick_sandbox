-- or_gate.vhdl
-- This is the VHDL file for the OR gate component.
-- The output is HIGH when either or both inputs are HIGH.

library ieee;
use ieee.std_logic_1164.all;

entity or_gate is
    port (
        button1 : in std_logic;
        button2 : in std_logic;
        or_output : out std_logic
    );
end entity or_gate;

architecture Behavioral of or_gate is
begin

    -- OR gate logic
    or_output <= button1 or button2;

end architecture Behavioral;
