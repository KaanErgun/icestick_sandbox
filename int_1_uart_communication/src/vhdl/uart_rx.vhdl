-- uart_rx.vhdl
-- UART Receiver module
-- Receives 8-bit data with 1 start bit, 8 data bits, 1 stop bit
-- Baud rate: 9600 (assuming 60MHz clock)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    generic (
        CLK_FREQ : integer := 60_000_000;  -- 60 MHz clock
        BAUD_RATE : integer := 9600        -- 9600 baud
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        rx_in     : in  std_logic;         -- UART RX line
        rx_data   : out std_logic_vector(7 downto 0);  -- Received data
        rx_valid  : out std_logic;         -- Data valid flag
        rx_error  : out std_logic          -- Frame error flag
    );
end entity uart_rx;

architecture Behavioral of uart_rx is
    constant CLKS_PER_BIT : integer := CLK_FREQ / BAUD_RATE;
    constant CLKS_PER_HALF_BIT : integer := CLKS_PER_BIT / 2;
    
    type rx_state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal rx_state : rx_state_type := IDLE;
    
    signal clk_count : integer range 0 to CLKS_PER_BIT-1 := 0;
    signal bit_index : integer range 0 to 7 := 0;
    signal rx_data_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_valid_reg : std_logic := '0';
    signal rx_error_reg : std_logic := '0';
    
    -- Input synchronization
    signal rx_sync : std_logic_vector(2 downto 0) := (others => '1');
    
begin

    rx_data <= rx_data_reg;
    rx_valid <= rx_valid_reg;
    rx_error <= rx_error_reg;

    -- Synchronize input to avoid metastability
    process(clk, rst)
    begin
        if rst = '1' then
            rx_sync <= (others => '1');
        elsif rising_edge(clk) then
            rx_sync <= rx_sync(1 downto 0) & rx_in;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            rx_state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            rx_data_reg <= (others => '0');
            rx_valid_reg <= '0';
            rx_error_reg <= '0';
            
        elsif rising_edge(clk) then
            rx_valid_reg <= '0';  -- Clear valid flag by default
            rx_error_reg <= '0';  -- Clear error flag by default
            
            case rx_state is
                when IDLE =>
                    clk_count <= 0;
                    bit_index <= 0;
                    
                    -- Detect start bit (falling edge)
                    if rx_sync(2) = '1' and rx_sync(1) = '0' then
                        rx_state <= START_BIT;
                    end if;
                
                when START_BIT =>
                    -- Wait for middle of start bit to verify it's still low
                    if clk_count < CLKS_PER_HALF_BIT then
                        clk_count <= clk_count + 1;
                    else
                        if rx_sync(2) = '0' then
                            -- Valid start bit, proceed to data bits
                            clk_count <= 0;
                            rx_state <= DATA_BITS;
                        else
                            -- False start bit, return to idle
                            rx_state <= IDLE;
                        end if;
                    end if;
                
                when DATA_BITS =>
                    if clk_count < CLKS_PER_BIT-1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        
                        -- Sample data bit at middle of bit period
                        rx_data_reg(bit_index) <= rx_sync(2);
                        
                        if bit_index < 7 then
                            bit_index <= bit_index + 1;
                        else
                            bit_index <= 0;
                            rx_state <= STOP_BIT;
                        end if;
                    end if;
                
                when STOP_BIT =>
                    if clk_count < CLKS_PER_BIT-1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        
                        -- Check stop bit
                        if rx_sync(2) = '1' then
                            -- Valid stop bit
                            rx_valid_reg <= '1';
                        else
                            -- Frame error
                            rx_error_reg <= '1';
                        end if;
                        
                        rx_state <= IDLE;
                    end if;
                    
            end case;
        end if;
    end process;

end architecture Behavioral;
