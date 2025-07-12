library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity UART_RX is 
    generic(clk_baudrate : integer := 5208;             -- Baud rate clock cycles for 9600 baud with a 50 MHz clock
            WIDTH : integer := 8 );               
    port(   clk : in std_logic;
            rst : in std_logic;
            RX_data_in : in std_logic;
            RX_data_out : out std_logic_vector(WIDTH - 1 downto 0);
            RX_finish : out std_logic );
end UART_RX;

architecture Behavioral of UART_RX is

    type state_type is (IDLE_state, START_state, DATA_rx_state, STOP_state);
    signal state : state_type := IDLE_state;
    signal count_bit : integer range 0 to WIDTH - 1 := 0;
    signal count_clk : integer range 0 to (clk_baudrate-1) := 0;
    signal RX_out : std_logic_vector(WIDTH - 1 downto 0);
    signal RX_end : std_logic := '0';

begin 
    RX_finish <= RX_end;
    RX_data_out <= RX_out;

    process (clk, rst)
    begin
        if rst = '1' then
            state <= IDLE_state;
            count_bit <= 0;
            count_clk <= 0;
            RX_out <= (others => '0');
            RX_end <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE_state => 
                    count_bit <= 0;
                    count_clk <= 0;
                    RX_out <= (others => '0');
                    RX_end <= '0';
                    if RX_data_in = '0' then
                        state <= START_state;
                    else
                        state <= IDLE_state;
                    end if;
                when START_state => 
                    if count_clk = (clk_baudrate - 1) / 2 then
                        if RX_data_in = '0' then
                            count_clk <= 0;	
					        state <= DATA_rx_state;
                        else
                            state <= IDLE_state;
                        end if;
                    else
                        count_clk <= count_clk + 1;
                        state <= START_state;
                    end if;
                when DATA_rx_state =>
                    if count_clk < clk_baudrate - 1 then
                        count_clk <= count_clk + 1;
                        state <= DATA_rx_state;
                    else
                        RX_data_out(count_bit) <= RX_data_in;
                        count_clk <= 0;
                        if count_bit < WIDTH - 1 then
                            count_bit <= count_bit + 1;
                            state <= DATA_rx_state;
                        else
                            count_bit <= 0;
                            state <= STOP_state;
                        end if;
                    end if;
                when STOP_state => 
                    if count_clk < clk_baudrate - 1 then
                        count_clk <= count_clk + 1;
                        state <= STOP_state;
                    else
                        if RX_data_in = '1' then
                            count_clk <= 0;
                            state <= IDLE_state;
                            RX_end <= '1';
                        else
                            state <= IDLE_state;
                        end if;
                    end if;
            end case;
        end if;
    end process;

end Behavioral;