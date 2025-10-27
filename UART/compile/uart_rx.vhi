component UART_RX
	port (
		UART_RxD: in STD_LOGIC;
		BAUD_SEL: in STD_LOGIC_VECTOR (2 downto 0);
		UART_DATA: out STD_LOGIC_VECTOR (7 downto 0);
		DATA_VALID: out STD_LOGIC;
		UART_RESET: in STD_LOGIC;
		UART_CLK: in STD_LOGIC);
end component;


instance_name : UART_RX
( UART_RxD => ,
 BAUD_SEL => ,
 UART_DATA => ,
 DATA_VALID => ,
 UART_RESET => ,
 UART_CLK => );
