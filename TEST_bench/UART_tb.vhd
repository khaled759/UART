library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_TOP_tb is
end UART_TOP_tb;

architecture Behavioral of UART_TOP_tb is

    -- Constants for simulation
    constant clk_period : time := 20 ns; -- 50 MHz
    constant clk_baudrate : integer := 5208; -- 50 MHz / 9600 baud

    -- Component under test
    component UART_TOP
        generic (
            clk_baudrate : integer := 5208;
            WIDTH : integer := 8
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            TX_start : in std_logic;
            TX_data_in : in std_logic_vector(7 downto 0);
            TX_data_out : out std_logic;
            TX_busy : out std_logic;
            TX_finish : out std_logic;

            RX_data_out : out std_logic_vector(7 downto 0);
            RX_finish : out std_logic
        );
    end component;

    -- Signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal TX_start    : std_logic := '0';
    signal TX_data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal TX_data_out : std_logic;
    signal TX_busy     : std_logic;
    signal TX_finish   : std_logic;

    signal RX_data_out : std_logic_vector(7 downto 0);
    signal RX_finish   : std_logic;

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- DUT instance
    DUT: UART_TOP
        generic map (
            clk_baudrate => clk_baudrate,
            WIDTH => 8
        )
        port map (
            clk => clk,
            rst => rst,
            TX_start => TX_start,
            TX_data_in => TX_data_in,
            TX_data_out => TX_data_out,
            TX_busy => TX_busy,
            TX_finish => TX_finish, 
            RX_data_out => RX_data_out,
            RX_finish => RX_finish
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset pulse
        wait for 10 ns;
        rst <= '0';
        wait for 10 ns;
        -- Load TX data
        -- Send A5
        TX_data_in <= "10100101";
        TX_start <= '1';
        wait for clk_period;
        TX_start <= '0';
        wait until TX_finish = '1';
        wait for 10 ns;

        -- Send 3C
        TX_data_in <= "00111100";
        TX_start <= '1';
        wait for clk_period;
        TX_start <= '0';
        wait until TX_finish = '1';
        wait for 10 ns;

        -- Send FF
        TX_data_in <= "11111111";
        TX_start <= '1';
        wait for clk_period;
        TX_start <= '0';
        wait until TX_finish = '1';
        wait for 10 ns;

        -- End
        wait;
    end process;

end Behavioral;
