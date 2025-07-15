library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_TOP is 
    generic (clk_baudrate : integer := 5208; 
             WIDTH : integer := 8 );
    port (  clk : in std_logic;								
            rst : in std_logic;								
            TX_start : in std_logic;
            TX_data_in : in std_logic_vector(WIDTH - 1 downto 0);	
            TX_data_out : out std_logic;					
            TX_busy : out std_logic;						
            TX_finish : out std_logic;
            RX_data_out : out std_logic_vector(WIDTH - 1 downto 0);
            RX_finish : out std_logic );


end UART_TOP;

architecture structural of UART_TOP is 

    component UART_TX  -- TX compnant
        generic(clk_baudrate : integer := 5208;             
                WIDTH : integer := 8 );               
        port(	clk : in std_logic;							
                rst : in std_logic;
                TX_start : in std_logic;
                TX_data_in : in std_logic_vector(WIDTH - 1 downto 0);
                TX_data_out : out std_logic;		
                TX_busy : out std_logic;				
                TX_finish : out std_logic );
    end component;

    component UART_RX  -- RX compnant
        generic(clk_baudrate : integer := 5208;     
            WIDTH : integer := 8 );               
        port(   clk : in std_logic;
                rst : in std_logic;
                RX_data_in : in std_logic;
                RX_data_out : out std_logic_vector(WIDTH - 1 downto 0);
                RX_finish : out std_logic );
    end component;

    signal TX_out : std_logic;

begin

    TX : UART_TX generic map (clk_baudrate => clk_baudrate, WIDTH => WIDTH) port map (  clk => clk,
                                                                                        rst => rst,
                                                                                        TX_start => TX_start,
                                                                                        TX_data_in => TX_data_in,
                                                                                        TX_data_out => TX_out,
                                                                                        TX_busy => TX_busy,
                                                                                        TX_finish => TX_finish);

    RX : UART_RX generic map (clk_baudrate => clk_baudrate, WIDTH => WIDTH) port map (  clk => clk,
                                                                                        rst => rst,
                                                                                        RX_data_in => TX_out,
                                                                                        RX_data_out => RX_data_out,
                                                                                        RX_finish => RX_finish);

    TX_data_out <= TX_out;

end structural;