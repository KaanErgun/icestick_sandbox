-- LED Breathing Effect Generator (VHDL Version)
-- 
-- This module demonstrates breathing effect for LEDs using PWM.
-- LEDs fade in and out smoothly like breathing with different speeds.
-- 
-- Features:
-- - Smooth PWM-based brightness transitions
-- - Different breathing speeds for each LED
-- - Sine-wave-like brightness curves

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_brightness_control_with_pwm is
    Port (
        clk_12mhz : in STD_LOGIC;
        leds : out STD_LOGIC_VECTOR(4 downto 0)
    );
end led_brightness_control_with_pwm;

architecture Behavioral of led_brightness_control_with_pwm is
    
    -- Component declarations
    component pll
        Port (
            clk_in : in STD_LOGIC;
            clk_out : out STD_LOGIC;
            locked : out STD_LOGIC
        );
    end component;
    
    -- PLL signals
    signal clk_60mhz : STD_LOGIC;
    signal pll_locked : STD_LOGIC;
    
    -- PWM counter for all LEDs (slower PWM for smoother effect)
    signal pwm_counter : unsigned(11 downto 0) := (others => '0');  -- 12-bit for ~15kHz PWM
    
    -- Breathing control signals for each LED (much slower breathing)
    signal breath_counter_1 : unsigned(25 downto 0) := (others => '0');  -- ~1.1 second period
    signal breath_counter_2 : unsigned(26 downto 0) := (others => '0');  -- ~2.2 second period  
    signal breath_counter_3 : unsigned(27 downto 0) := (others => '0');  -- ~4.5 second period
    signal breath_counter_4 : unsigned(28 downto 0) := (others => '0');  -- ~9 second period
    signal breath_counter_5 : unsigned(29 downto 0) := (others => '0');  -- ~18 second period
    
    -- Brightness levels for each LED (8-bit for PWM comparison)
    signal brightness_1 : unsigned(7 downto 0);
    signal brightness_2 : unsigned(7 downto 0);
    signal brightness_3 : unsigned(7 downto 0);
    signal brightness_4 : unsigned(7 downto 0);
    signal brightness_5 : unsigned(7 downto 0);
    
    -- LED output registers
    signal led_outputs : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    
    -- Breathing lookup table (sine-wave approximation)
    type breathing_lut_type is array (0 to 255) of unsigned(7 downto 0);
    constant breathing_lut : breathing_lut_type := (
        -- First quarter: 0 to peak (0-63)
        to_unsigned(0,8), to_unsigned(0,8), to_unsigned(1,8), to_unsigned(2,8), to_unsigned(3,8), to_unsigned(5,8), to_unsigned(6,8), to_unsigned(8,8), to_unsigned(10,8), to_unsigned(12,8), to_unsigned(15,8), to_unsigned(17,8), to_unsigned(20,8), to_unsigned(23,8), to_unsigned(26,8), to_unsigned(30,8),
        to_unsigned(34,8), to_unsigned(38,8), to_unsigned(42,8), to_unsigned(47,8), to_unsigned(52,8), to_unsigned(57,8), to_unsigned(62,8), to_unsigned(68,8), to_unsigned(74,8), to_unsigned(80,8), to_unsigned(86,8), to_unsigned(93,8), to_unsigned(100,8), to_unsigned(107,8), to_unsigned(114,8), to_unsigned(122,8),
        to_unsigned(130,8), to_unsigned(138,8), to_unsigned(146,8), to_unsigned(155,8), to_unsigned(164,8), to_unsigned(173,8), to_unsigned(182,8), to_unsigned(192,8), to_unsigned(202,8), to_unsigned(212,8), to_unsigned(222,8), to_unsigned(233,8), to_unsigned(244,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8),
        to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8),
        -- Second quarter: peak continues (64-127)
        to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8),
        to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8),
        to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8),
        to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8),
        -- Third quarter: peak to fade (128-191)
        to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8),
        to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8),
        to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(255,8), to_unsigned(244,8), to_unsigned(233,8), to_unsigned(222,8),
        to_unsigned(212,8), to_unsigned(202,8), to_unsigned(192,8), to_unsigned(182,8), to_unsigned(173,8), to_unsigned(164,8), to_unsigned(155,8), to_unsigned(146,8), to_unsigned(138,8), to_unsigned(130,8), to_unsigned(122,8), to_unsigned(114,8), to_unsigned(107,8), to_unsigned(100,8), to_unsigned(93,8), to_unsigned(86,8),
        -- Fourth quarter: fade to 0 (192-255)
        to_unsigned(80,8), to_unsigned(74,8), to_unsigned(68,8), to_unsigned(62,8), to_unsigned(57,8), to_unsigned(52,8), to_unsigned(47,8), to_unsigned(42,8), to_unsigned(38,8), to_unsigned(34,8), to_unsigned(30,8), to_unsigned(26,8), to_unsigned(23,8), to_unsigned(20,8), to_unsigned(17,8), to_unsigned(15,8),
        to_unsigned(12,8), to_unsigned(10,8), to_unsigned(8,8), to_unsigned(6,8), to_unsigned(5,8), to_unsigned(3,8), to_unsigned(2,8), to_unsigned(1,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8),
        to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8),
        to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8), to_unsigned(0,8)
    );
    
begin

    -- Instantiate PLL
    pll_inst: pll
        Port map (
            clk_in => clk_12mhz,
            clk_out => clk_60mhz,
            locked => pll_locked
        );
    
    -- PWM counter - runs at 60MHz, creates ~15kHz PWM frequency
    pwm_counter_process: process(clk_60mhz)
    begin
        if rising_edge(clk_60mhz) then
            if pll_locked = '1' then
                pwm_counter <= pwm_counter + 1;
            end if;
        end if;
    end process;
    
    -- Breathing counter 1 (fastest breathing - ~1.1 second period)
    breath_counter_1_process: process(clk_60mhz)
    begin
        if rising_edge(clk_60mhz) then
            if pll_locked = '1' then
                breath_counter_1 <= breath_counter_1 + 1;
            else
                breath_counter_1 <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Breathing counter 2 (2.2 second period)
    breath_counter_2_process: process(clk_60mhz)
    begin
        if rising_edge(clk_60mhz) then
            if pll_locked = '1' then
                breath_counter_2 <= breath_counter_2 + 1;
            else
                breath_counter_2 <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Breathing counter 3 (4.5 second period)
    breath_counter_3_process: process(clk_60mhz)
    begin
        if rising_edge(clk_60mhz) then
            if pll_locked = '1' then
                breath_counter_3 <= breath_counter_3 + 1;
            else
                breath_counter_3 <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Breathing counter 4 (9 second period)
    breath_counter_4_process: process(clk_60mhz)
    begin
        if rising_edge(clk_60mhz) then
            if pll_locked = '1' then
                breath_counter_4 <= breath_counter_4 + 1;
            else
                breath_counter_4 <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Breathing counter 5 (18 second period)
    breath_counter_5_process: process(clk_60mhz)
    begin
        if rising_edge(clk_60mhz) then
            if pll_locked = '1' then
                breath_counter_5 <= breath_counter_5 + 1;
            else
                breath_counter_5 <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Generate brightness levels from breathing counters
    brightness_1 <= breathing_lut(to_integer(breath_counter_1(25 downto 18)));
    brightness_2 <= breathing_lut(to_integer(breath_counter_2(26 downto 19)));
    brightness_3 <= breathing_lut(to_integer(breath_counter_3(27 downto 20)));
    brightness_4 <= breathing_lut(to_integer(breath_counter_4(28 downto 21)));
    brightness_5 <= breathing_lut(to_integer(breath_counter_5(29 downto 22)));
    
    -- PWM generation for each LED
    pwm_generation_process: process(clk_60mhz)
    begin
        if rising_edge(clk_60mhz) then
            if pll_locked = '1' then
                -- LED 0: Fastest breathing
                if pwm_counter(11 downto 4) < brightness_1 then
                    led_outputs(0) <= '1';
                else
                    led_outputs(0) <= '0';
                end if;
                
                -- LED 1: Medium-fast breathing
                if pwm_counter(11 downto 4) < brightness_2 then
                    led_outputs(1) <= '1';
                else
                    led_outputs(1) <= '0';
                end if;
                
                -- LED 2: Medium breathing
                if pwm_counter(11 downto 4) < brightness_3 then
                    led_outputs(2) <= '1';
                else
                    led_outputs(2) <= '0';
                end if;
                
                -- LED 3: Slow breathing
                if pwm_counter(11 downto 4) < brightness_4 then
                    led_outputs(3) <= '1';
                else
                    led_outputs(3) <= '0';
                end if;
                
                -- LED 4: Very slow breathing
                if pwm_counter(11 downto 4) < brightness_5 then
                    led_outputs(4) <= '1';
                else
                    led_outputs(4) <= '0';
                end if;
            else
                led_outputs <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Output assignment
    leds <= led_outputs;

end Behavioral;
