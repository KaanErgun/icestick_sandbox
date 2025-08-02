-- uart_controller.vhdl
-- UART Controller module
-- Manages UART TX and RX operations
-- Implements echo functionality - received data is transmitted back

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_controller is
    generic (
        CLK_FREQ : integer := 60_000_000;  -- 60 MHz clock
        BAUD_RATE : integer := 9600        -- 9600 baud
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        uart_rx   : in  std_logic;         -- UART RX line
        uart_tx   : out std_logic;         -- UART TX line
        led_rx    : out std_logic;         -- LED indicates RX activity
        led_tx    : out std_logic;         -- LED indicates TX activity
        led_error : out std_logic          -- LED indicates error
    );
end entity uart_controller;

architecture Behavioral of uart_controller is
    
    -- UART TX component
    component uart_tx is
        generic (
            CLK_FREQ : integer := 60_000_000;
            BAUD_RATE : integer := 9600
        );
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            tx_start  : in  std_logic;
            tx_data   : in  std_logic_vector(7 downto 0);
            tx_busy   : out std_logic;
            tx_done   : out std_logic;
            tx_out    : out std_logic
        );
    end component;
    
    -- UART RX component
    component uart_rx is
        generic (
            CLK_FREQ : integer := 60_000_000;
            BAUD_RATE : integer := 9600
        );
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            rx_in     : in  std_logic;
            rx_data   : out std_logic_vector(7 downto 0);
            rx_valid  : out std_logic;
            rx_error  : out std_logic
        );
    end component;
    
    -- Internal signals
    signal tx_start_sig : std_logic := '0';
    signal tx_data_sig : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_busy_sig : std_logic;
    signal tx_done_sig : std_logic;
    
    signal rx_data_sig : std_logic_vector(7 downto 0);
    signal rx_valid_sig : std_logic;
    signal rx_error_sig : std_logic;
    
    -- LED control signals
    signal led_rx_counter : integer range 0 to 6_000_000 := 0;  -- 100ms at 60MHz
    signal led_tx_counter : integer range 0 to 6_000_000 := 0;  -- 100ms at 60MHz
    signal led_error_counter : integer range 0 to 30_000_000 := 0;  -- 500ms at 60MHz
    
    signal led_rx_reg : std_logic := '0';
    signal led_tx_reg : std_logic := '0';
    signal led_error_reg : std_logic := '0';
    
    -- Echo state machine
    type echo_state_type is (IDLE, WAIT_TX_READY, TRANSMIT);
    signal echo_state : echo_state_type := IDLE;
    
begin

    -- Instantiate UART TX
    uart_tx_inst : uart_tx
        generic map (
            CLK_FREQ => CLK_FREQ,
            BAUD_RATE => BAUD_RATE
        )
        port map (
            clk => clk,
            rst => rst,
            tx_start => tx_start_sig,
            tx_data => tx_data_sig,
            tx_busy => tx_busy_sig,
            tx_done => tx_done_sig,
            tx_out => uart_tx
        );
    
    -- Instantiate UART RX
    uart_rx_inst : uart_rx
        generic map (
            CLK_FREQ => CLK_FREQ,
            BAUD_RATE => BAUD_RATE
        )
        port map (
            clk => clk,
            rst => rst,
            rx_in => uart_rx,
            rx_data => rx_data_sig,
            rx_valid => rx_valid_sig,
            rx_error => rx_error_sig
        );
    
    -- Output LED signals
    led_rx <= led_rx_reg;
    led_tx <= led_tx_reg;
    led_error <= led_error_reg;
    
    -- Echo functionality and LED control
    process(clk, rst)
    begin
        if rst = '1' then
            echo_state <= IDLE;
            tx_start_sig <= '0';
            tx_data_sig <= (others => '0');
            
            led_rx_counter <= 0;
            led_tx_counter <= 0;
            led_error_counter <= 0;
            led_rx_reg <= '0';
            led_tx_reg <= '0';
            led_error_reg <= '0';
            
        elsif rising_edge(clk) then
            
            -- Default: clear tx_start
            tx_start_sig <= '0';
            
            -- Echo state machine
            case echo_state is
                when IDLE =>
                    if rx_valid_sig = '1' then
                        -- Data received, prepare to echo it back
                        tx_data_sig <= rx_data_sig;
                        echo_state <= WAIT_TX_READY;
                        
                        -- Activate RX LED
                        led_rx_reg <= '1';
                        led_rx_counter <= 6_000_000 - 1;
                    end if;
                
                when WAIT_TX_READY =>
                    if tx_busy_sig = '0' then
                        -- TX is ready, start transmission
                        tx_start_sig <= '1';
                        echo_state <= TRANSMIT;
                        
                        -- Activate TX LED
                        led_tx_reg <= '1';
                        led_tx_counter <= 6_000_000 - 1;
                    end if;
                
                when TRANSMIT =>
                    if tx_done_sig = '1' then
                        -- Transmission complete
                        echo_state <= IDLE;
                    end if;
            end case;
            
            -- Handle RX error
            if rx_error_sig = '1' then
                led_error_reg <= '1';
                led_error_counter <= 30_000_000 - 1;
            end if;
            
            -- LED timers
            if led_rx_counter > 0 then
                led_rx_counter <= led_rx_counter - 1;
            else
                led_rx_reg <= '0';
            end if;
            
            if led_tx_counter > 0 then
                led_tx_counter <= led_tx_counter - 1;
            else
                led_tx_reg <= '0';
            end if;
            
            if led_error_counter > 0 then
                led_error_counter <= led_error_counter - 1;
            else
                led_error_reg <= '0';
            end if;
            
        end if;
    end process;

end architecture Behavioral;
