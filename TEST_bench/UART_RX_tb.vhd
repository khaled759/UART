library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_RX_tb is
end UART_RX_tb;

architecture test of UART_RX_tb is

    constant clk_period : time := 20 ns;           -- 50 MHz
    constant baud_period : time := 5208 * clk_period;

    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal RX_data_in  : std_logic := '1';  -- idle line = '1'
    signal RX_data_out : std_logic_vector(7 downto 0);
    signal RX_finish   : std_logic;

    -- Component under test
    component UART_RX
        generic (
            clk_baudrate : integer := 5208;
            WIDTH : integer := 8
        );
        port (
            clk          : in std_logic;
            rst          : in std_logic;
            RX_data_in   : in std_logic;
            RX_data_out  : out std_logic_vector(WIDTH - 1 downto 0);
            RX_finish    : out std_logic
        );
    end component;

begin

    -- Instantiate the DUT
    DUT: UART_RX
        port map (
            clk         => clk,
            rst         => rst,
            RX_data_in  => RX_data_in,
            RX_data_out => RX_data_out,
            RX_finish   => RX_finish
        );

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


    stim_proc: process
    begin
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Send start bit
        RX_data_in <= '0';
        wait for baud_period;

        -- Send data bits for 0xA5 = "10100101"
        RX_data_in <= '1'; wait for baud_period; -- Bit 0
        RX_data_in <= '0'; wait for baud_period; -- Bit 1
        RX_data_in <= '1'; wait for baud_period; -- Bit 2
        RX_data_in <= '0'; wait for baud_period; -- Bit 3
        RX_data_in <= '0'; wait for baud_period; -- Bit 4
        RX_data_in <= '1'; wait for baud_period; -- Bit 5
        RX_data_in <= '0'; wait for baud_period; -- Bit 6
        RX_data_in <= '1'; wait for baud_period; -- Bit 7

        -- Send stop bit
        RX_data_in <= '1'; wait for baud_period;

        wait for 10 * clk_period;
        wait;
    end process;
end test;
