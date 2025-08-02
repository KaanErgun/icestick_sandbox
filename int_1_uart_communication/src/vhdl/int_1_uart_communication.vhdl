-- int_1_uart_communication.vhdl
-- Top-level VHDL file for the UART communication project
-- Integrates PLL, UART controller, and LED status indicators

library ieee;
use ieee.std_logic_1164.all;

entity int_1_uart_communication is
    port (
        clk_raw  : in  std_logic;          -- 12 MHz raw clock from oscillator
        rst      : in  std_logic;          -- Reset button (active high)
        uart_rx  : in  std_logic;          -- UART RX pin
        uart_tx  : out std_logic;          -- UART TX pin
        led1     : out std_logic;          -- LED1 - RX activity indicator
        led2     : out std_logic;          -- LED2 - TX activity indicator  
        led3     : out std_logic;          -- LED3 - Error indicator
        led4     : out std_logic           -- LED4 - Heartbeat/alive indicator
    );
end entity int_1_uart_communication;

architecture Behavioral of int_1_uart_communication is
    
    -- Internal signals
    signal clk : std_logic;                -- 60 MHz clock from PLL
    signal pll_locked : std_logic;         -- PLL lock status
    signal reset_sync : std_logic;         -- Synchronized reset
    
    -- Heartbeat counter for LED4
    signal heartbeat_counter : integer range 0 to 30_000_000 := 0;  -- 500ms at 60MHz
    signal heartbeat_led : std_logic := '0';
    
    -- PLL component declaration
    component pll is
        port (
            clk_in  : in  std_logic;
            clk_out : out std_logic;
            locked  : out std_logic
        );
    end component pll;
    
    -- UART Controller component declaration
    component uart_controller is
        generic (
            CLK_FREQ  : integer := 60_000_000;
            BAUD_RATE : integer := 9600
        );
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            uart_rx   : in  std_logic;
            uart_tx   : out std_logic;
            led_rx    : out std_logic;
            led_tx    : out std_logic;
            led_error : out std_logic
        );
    end component uart_controller;

begin

    -- PLL instantiation - converts 12MHz to 60MHz
    pll_inst : pll
        port map (
            clk_in  => clk_raw,
            clk_out => clk,
            locked  => pll_locked
        );

    -- Reset synchronization: reset when external reset is active OR PLL is not locked
    reset_sync <= rst or (not pll_locked);

    -- UART Controller instantiation
    uart_ctrl_inst : uart_controller
        generic map (
            CLK_FREQ  => 60_000_000,
            BAUD_RATE => 9600
        )
        port map (
            clk       => clk,
            rst       => reset_sync,
            uart_rx   => uart_rx,
            uart_tx   => uart_tx,
            led_rx    => led1,      -- RX activity on LED1
            led_tx    => led2,      -- TX activity on LED2
            led_error => led3       -- Error indication on LED3
        );

    -- Heartbeat LED (LED4) - indicates system is alive
    led4 <= heartbeat_led;
    
    -- Heartbeat process
    heartbeat_process: process(clk, reset_sync)
    begin
        if reset_sync = '1' then
            heartbeat_counter <= 0;
            heartbeat_led <= '0';
        elsif rising_edge(clk) then
            if heartbeat_counter < 30_000_000 - 1 then
                heartbeat_counter <= heartbeat_counter + 1;
            else
                heartbeat_counter <= 0;
                heartbeat_led <= not heartbeat_led;  -- Toggle every 500ms
            end if;
        end if;
    end process;

end architecture Behavioral;
