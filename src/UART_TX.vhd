library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity UART_TX is
    generic(clk_baudrate : integer := 5208;                 -- Baud rate clock cycles for 9600 baud with a 50 MHz clock
            WIDTH : integer := 8 );               
    port(	clk : in std_logic;								-- Clock signal
            rst : in std_logic;								-- active high reset
            TX_start : in std_logic;
            TX_data_in : in std_logic_vector(WIDTH - 1 downto 0);	-- 8 bit data to be sent
            TX_data_out : out std_logic;					-- data sent through TX bus
            TX_busy : out std_logic;						-- active when transmitter is sending data
            TX_finish : out std_logic );                    -- active when transmission is finished
end UART_TX;


architecture Behavioral of UART_TX is

    type state_type is (IDLE_state, START_state, DATA_tx_state, STOP_state);
    signal state : state_type := IDLE_state;
	signal count_bit : integer range 0 to WIDTH - 1 := 0;								-- used for counting the number of bits sent
	signal count_clk : integer range 0 to (clk_baudrate-1) := 0;            -- to count clocks between evert tx
	signal TX_in : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal TX_out : std_logic := '1';                                       
	signal TX_active : std_logic := '0';                                    -- high when transmission is on
	signal TX_end : std_logic := '0';                                       -- high if the transmission ended

begin

    TX_data_out <= TX_out;
    TX_busy <= TX_active;
    TX_finish <= TX_end;

    process (clk, rst)
    begin
        if rst = '1' then
            state <= IDLE_state;
            count_bit <= 0;
            count_clk <= 0;
            TX_out <= '1';
            TX_active <= '0';
            TX_end <= '0';
            elsif rising_edge(clk) then
            case state is 
                when IDLE_state => 
                    count_bit <= 0;
                    count_clk <= 0;
                    TX_out <= '1';
                    TX_active <= '0';
                    TX_end <= '0';
                    if TX_start = '1' then
                        state <= START_state;
                        TX_in <= TX_data_in;
                    else
                        state <= IDLE_state;
                    end if;
                
                when START_state =>
                    TX_out <= '0';
			        TX_active <= '1';
                    if count_clk < clk_baudrate - 1 then 
                        count_clk <= count_clk + 1;
                        state <= START_state;
                    else
                        state <= DATA_tx_state;
                        count_clk <= 0;
                    end if;
                when DATA_tx_state =>
                    TX_out <= TX_in(count_bit);
                    if count_clk < clk_baudrate - 1 then
                        count_clk <= count_clk + 1;
                        state <= DATA_tx_state;
                    else
                        count_clk <= 0;
                        if count_bit < 7 then
                            state <= DATA_tx_state;  
                            count_bit <= count_bit + 1;
                        else
                            state <= STOP_state;
                            count_bit <= 0;
                        end if;
                    end if;
                when STOP_state =>
                    TX_out <= '1';
                    if count_clk < clk_baudrate - 1 then
                        count_clk <= count_clk + 1;
                        state <= STOP_state;
                    else
                        TX_active <= '0';
                        TX_end <= '1';
                        state <= IDLE_state;
                    end if;

                when others => 
                    state <= IDLE_state;
            end case;
        end if;
    end process;

end Behavioral;