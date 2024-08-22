-- and.vhdl
-- This module performs an AND operation on two input signals.

library ieee;
use ieee.std_logic_1164.all;

entity and_gate is
    port (
        button1 : in std_logic;
        button2 : in std_logic;
        and_output : out std_logic
    );
end entity and_gate;

architecture Behavioral of and_gate is
begin
    and_output <= button1 and button2;
end architecture Behavioral;
