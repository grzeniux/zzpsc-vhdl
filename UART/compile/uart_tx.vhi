component UART_TX
	port (
		UART_DATA: in STD_LOGIC_VECTOR (7 downto 0);
		DATA_VALID: in STD_LOGIC;
		BAUD_SEL: in STD_LOGIC_VECTOR (2 downto 0);
		UART_TxD: out STD_LOGIC;
		UART_RESET: in STD_LOGIC;
		UART_CLK: in STD_LOGIC);
end component;


instance_name : UART_TX
( UART_DATA => ,
 DATA_VALID => ,
 BAUD_SEL => ,
 UART_TxD => ,
 UART_RESET => ,
 UART_CLK => );
