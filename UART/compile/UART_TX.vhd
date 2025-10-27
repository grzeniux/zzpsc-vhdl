-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : UART
-- Author      : Jerzy Kasperek & Pawe³ J. Rajda
-- Company     : AGH Kraków
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/GP/UART/UART/compile/UART_TX.vhd
-- Generated   : Mon Oct 27 17:06:00 2025
-- From        : C:/My_Designs/GP/UART/UART/src/UART_TX.asf
-- By          : Active-HDL 15 FSM Code Generator ver. 6.0
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity UART_TX is 
	port (
		UART_DATA: in STD_LOGIC_VECTOR (7 downto 0);
		DATA_VALID: in STD_LOGIC;
		BAUD_SEL: in STD_LOGIC_VECTOR (2 downto 0);
		UART_TxD: out STD_LOGIC;
		UART_RESET: in STD_LOGIC;
		UART_CLK: in STD_LOGIC
);
end UART_TX;

architecture UART_TX of UART_TX is

constant CLOCK: INTEGER := 1_843_200;
-- diagram signals declarations
signal BIT_CNT: INTEGER;
signal BIT_DEL: INTEGER;
signal ONE_BIT: INTEGER;
signal ONE_BIT_DEL: INTEGER;
signal SHFT_REG: STD_LOGIC_VECTOR (7 downto 0);

-- USER DEFINED ENCODED state machine: Transmit
type Transmit_type is (
	IDLE, START, WAIT_ONE, SEND_BIT
);
signal Transmit: Transmit_type;

attribute ENUM_ENCODING: string;
attribute ENUM_ENCODING of Transmit_type: type is
	"0001 " &		-- IDLE
	"0010 " &		-- START
	"0100 " &		-- WAIT_ONE
	"1000" ;		-- SEND_BIT

begin

-- User statements

-- diagram ACTION
-- # of clock cycles per ONE bit
ONE_BIT <= CLOCK /   1200 when BAUD_SEL = "000" else
           CLOCK /   2400 when BAUD_SEL = "001" else	
           CLOCK /   4800 when BAUD_SEL = "010" else	
           CLOCK /   9600 when BAUD_SEL = "011" else	
           CLOCK /  19200 when BAUD_SEL = "100" else	
           CLOCK /  38400 when BAUD_SEL = "101" else	
           CLOCK /  57600 when BAUD_SEL = "110" else	
           CLOCK / 115200 when BAUD_SEL = "111";
ONE_BIT_DEL <= ONE_BIT - 2; -- corrected # of clock cycles per ONE bit

----------------------------------------------------------------------
-- Machine: Transmit
----------------------------------------------------------------------
Transmit_machine: process (UART_CLK, UART_RESET)
begin
	if UART_RESET = '1' then
		Transmit <= IDLE;
		-- Set reset or default values for outputs, signals and variables
		BIT_CNT<=0;
		BIT_DEL<=0;
		UART_TxD<='1';
	elsif UART_CLK'event and UART_CLK = '1' then
		-- Set default values for outputs, signals and variables
		-- ...
		case Transmit is
			when IDLE =>
				BIT_CNT <= 0;
				BIT_DEL <= 0;
				UART_TxD <= '1';
				case DATA_VALID is
					when '1' =>
						Transmit <= START;
					when '0' =>
						Transmit <= IDLE;
					when others =>
						null;
				end case;
			when START =>
				UART_TxD <= '0';
				SHFT_REG <= UART_DATA;
				Transmit <= WAIT_ONE;
			when WAIT_ONE =>
				BIT_DEL <= BIT_DEL + 1;
				if BIT_DEL = ONE_BIT_DEL then
					Transmit <= SEND_BIT;
				elsif BIT_DEL < ONE_BIT_DEL then
					Transmit <= WAIT_ONE;
				end if;
			when SEND_BIT =>
				BIT_DEL <= 0;
				if BIT_CNT < 8 then
					UART_TxD <= SHFT_REG(BIT_CNT);
				else
					UART_TxD <= '1'; -- stop bit
				end if;
				BIT_CNT <= BIT_CNT + 1;
				if BIT_CNT = 9 then
					Transmit <= IDLE;
				elsif BIT_CNT < 9 then
					Transmit <= WAIT_ONE;
				end if;
--vhdl_cover_off
			when others =>
				null;
--vhdl_cover_on
		end case;
	end if;
end process;

end UART_TX;
