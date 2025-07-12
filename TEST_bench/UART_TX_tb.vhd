library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_UART_TX is
end tb_UART_TX;

architecture behavior of tb_UART_TX is

    -- Component Declaration
    component UART_TX
        generic(clk_baudrate : integer := 5208);
        port(
            clk : in std_logic;
            rst : in std_logic;
            TX_start : in std_logic;
            TX_data_in : in std_logic_vector(7 downto 0);
            TX_data_out : out std_logic;
            TX_busy : out std_logic;
            TX_finish : out std_logic
        );
    end component;

    -- Testbench signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal TX_start    : std_logic := '0';
    signal TX_data_out : std_logic;
    signal TX_busy     : std_logic;
    signal TX_finish   : std_logic;
    signal TX_data_in  : std_logic_vector(7 downto 0) := (others => '0');

    constant clk_baudrate : integer := 10;  -- Use a small value for quick sim

begin

    -- Instantiate the UART_TX module
    uut: UART_TX
        generic map(clk_baudrate => clk_baudrate)
        port map(
            clk => clk,
            rst => rst,
            TX_start => TX_start,
            TX_data_in => TX_data_in,
            TX_data_out => TX_data_out,
            TX_busy => TX_busy,
            TX_finish => TX_finish
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the module
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        -- Send a byte
        TX_data_in <= "10101010";
        TX_start <= '1';
        wait for 10 ns;
        TX_start <= '0';

        wait until TX_finish = '1';
        wait for 50 ns;
        wait;
    end process;

end behavior;

