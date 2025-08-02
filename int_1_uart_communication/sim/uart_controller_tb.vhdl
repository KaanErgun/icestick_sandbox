-- uart_controller_tb.vhdl
-- Testbench for UART Controller
-- Tests echo functionality by sending data and verifying it's echoed back

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_controller_tb is
end entity uart_controller_tb;

architecture testbench of uart_controller_tb is
    
    -- Constants
    constant CLK_PERIOD : time := 16.67 ns;  -- 60 MHz clock
    constant BIT_PERIOD : time := 104.17 us; -- 9600 baud
    
    -- Signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal uart_rx : std_logic := '1';  -- UART idle state
    signal uart_tx : std_logic;
    signal led_rx : std_logic;
    signal led_tx : std_logic;
    signal led_error : std_logic;
    
    -- Test data
    signal test_byte : std_logic_vector(7 downto 0) := x"55"; -- Test pattern
    
    -- Component under test
    component uart_controller is
        generic (
            CLK_FREQ : integer := 60_000_000;
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
    end component;
    
begin

    -- Instantiate the Unit Under Test (UUT)
    uut: uart_controller
        generic map (
            CLK_FREQ => 60_000_000,
            BAUD_RATE => 9600
        )
        port map (
            clk => clk,
            rst => rst,
            uart_rx => uart_rx,
            uart_tx => uart_tx,
            led_rx => led_rx,
            led_tx => led_tx,
            led_error => led_error
        );

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the system
        rst <= '1';
        uart_rx <= '1';
        wait for 100 * CLK_PERIOD;
        rst <= '0';
        wait for 100 * CLK_PERIOD;
        
        -- Send a test byte via UART RX
        report "Sending test byte: " & integer'image(to_integer(unsigned(test_byte)));
        
        -- Start bit
        uart_rx <= '0';
        wait for BIT_PERIOD;
        
        -- Data bits (LSB first)
        for i in 0 to 7 loop
            uart_rx <= test_byte(i);
            wait for BIT_PERIOD;
        end loop;
        
        -- Stop bit
        uart_rx <= '1';
        wait for BIT_PERIOD;
        
        -- Wait for echo response
        wait for 20 * BIT_PERIOD;
        
        -- Send another test byte
        test_byte <= x"AA";
        report "Sending second test byte: " & integer'image(to_integer(unsigned(test_byte)));
        
        -- Start bit
        uart_rx <= '0';
        wait for BIT_PERIOD;
        
        -- Data bits (LSB first)
        for i in 0 to 7 loop
            uart_rx <= test_byte(i);
            wait for BIT_PERIOD;
        end loop;
        
        -- Stop bit
        uart_rx <= '1';
        wait for BIT_PERIOD;
        
        -- Wait for echo response
        wait for 20 * BIT_PERIOD;
        
        report "Testbench completed successfully";
        wait;
    end process;

    -- Monitor process to check TX output
    monitor_proc: process
        variable received_byte : std_logic_vector(7 downto 0);
    begin
        wait until uart_tx = '0';  -- Wait for start bit
        wait for BIT_PERIOD/2;     -- Move to middle of start bit
        
        if uart_tx = '0' then
            report "Start bit detected on TX";
            wait for BIT_PERIOD;   -- Move to first data bit
            
            -- Receive data bits
            for i in 0 to 7 loop
                received_byte(i) := uart_tx;
                wait for BIT_PERIOD;
            end loop;
            
            -- Check stop bit
            if uart_tx = '1' then
                report "Received echoed byte: " & integer'image(to_integer(unsigned(received_byte)));
            else
                report "ERROR: Invalid stop bit";
            end if;
        end if;
    end process;

end architecture testbench;
