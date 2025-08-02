-- uart_tx.vhdl
-- UART Transmitter module
-- Transmits 8-bit data with 1 start bit, 8 data bits, 1 stop bit
-- Baud rate: 9600 (assuming 60MHz clock)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    generic (
        CLK_FREQ : integer := 60_000_000;  -- 60 MHz clock
        BAUD_RATE : integer := 9600        -- 9600 baud
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        tx_start  : in  std_logic;         -- Start transmission
        tx_data   : in  std_logic_vector(7 downto 0);  -- Data to transmit
        tx_busy   : out std_logic;         -- Transmission in progress
        tx_done   : out std_logic;         -- Transmission complete
        tx_out    : out std_logic          -- UART TX line
    );
end entity uart_tx;

architecture Behavioral of uart_tx is
    constant CLKS_PER_BIT : integer := CLK_FREQ / BAUD_RATE;
    
    type tx_state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal tx_state : tx_state_type := IDLE;
    
    signal clk_count : integer range 0 to CLKS_PER_BIT-1 := 0;
    signal bit_index : integer range 0 to 7 := 0;
    signal tx_data_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_done_reg : std_logic := '0';
    
begin

    tx_busy <= '1' when tx_state /= IDLE else '0';
    tx_done <= tx_done_reg;

    process(clk, rst)
    begin
        if rst = '1' then
            tx_state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            tx_data_reg <= (others => '0');
            tx_out <= '1';  -- UART idle state is high
            tx_done_reg <= '0';
            
        elsif rising_edge(clk) then
            tx_done_reg <= '0';  -- Clear done flag by default
            
            case tx_state is
                when IDLE =>
                    tx_out <= '1';  -- Idle high
                    clk_count <= 0;
                    bit_index <= 0;
                    
                    if tx_start = '1' then
                        tx_data_reg <= tx_data;
                        tx_state <= START_BIT;
                    end if;
                
                when START_BIT =>
                    tx_out <= '0';  -- Start bit is low
                    
                    if clk_count < CLKS_PER_BIT-1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        tx_state <= DATA_BITS;
                    end if;
                
                when DATA_BITS =>
                    tx_out <= tx_data_reg(bit_index);
                    
                    if clk_count < CLKS_PER_BIT-1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        
                        if bit_index < 7 then
                            bit_index <= bit_index + 1;
                        else
                            bit_index <= 0;
                            tx_state <= STOP_BIT;
                        end if;
                    end if;
                
                when STOP_BIT =>
                    tx_out <= '1';  -- Stop bit is high
                    
                    if clk_count < CLKS_PER_BIT-1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        tx_done_reg <= '1';
                        tx_state <= IDLE;
                    end if;
                    
            end case;
        end if;
    end process;

end architecture Behavioral;
