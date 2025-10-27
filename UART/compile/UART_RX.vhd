-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : UART
-- Author      : Jerzy Kasperek & Pawe³ J. Rajda
-- Company     : AGH Kraków
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/GP/UART/UART/compile/UART_RX.vhd
-- Generated   : Mon Oct 27 17:06:00 2025
-- From        : C:/My_Designs/GP/UART/UART/src/UART_RX.asf
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

entity UART_RX is 
	port (
		UART_RxD: in STD_LOGIC;
		BAUD_SEL: in STD_LOGIC_VECTOR (2 downto 0);
		UART_DATA: out STD_LOGIC_VECTOR (7 downto 0);
		DATA_VALID: out STD_LOGIC;
		UART_RESET: in STD_LOGIC;
		UART_CLK: in STD_LOGIC
);
end UART_RX;

architecture UART_RX of UART_RX is

constant CLOCK: INTEGER := 1_843_200;
-- diagram signals declarations
signal BIT_CNT: INTEGER;
signal BIT_DEL: INTEGER;
signal OAH_BIT: INTEGER;
signal OAH_BIT_DEL: INTEGER;
signal ONE_BIT: INTEGER;
signal ONE_BIT_DEL: INTEGER;
signal SHFT_REG: STD_LOGIC_VECTOR (7 downto 0);
signal START_CNT: INTEGER;

-- USER DEFINED ENCODED state machine: Receive
type Receive_type is (
	IDLE, START, WAIT_OAH, GET_BIT, WAIT_ONE, STOP
);
signal Receive: Receive_type;

attribute ENUM_ENCODING: string;
attribute ENUM_ENCODING of Receive_type: type is
	"000001 " &		-- IDLE
	"000010 " &		-- START
	"000100 " &		-- WAIT_OAH
	"001000 " &		-- GET_BIT
	"010000 " &		-- WAIT_ONE
	"100000" ;		-- STOP

begin

-- User statements

-- diagram ACTION
-- # of clock cycles per ONE bit
ONE_BIT <= CLOCK / 1200   when BAUD_SEL = "000" else
           CLOCK / 2400   when BAUD_SEL = "001" else
           CLOCK / 4800   when BAUD_SEL = "010" else
           CLOCK / 9600   when BAUD_SEL = "011" else
           CLOCK / 19200  when BAUD_SEL = "100" else
           CLOCK / 38400  when BAUD_SEL = "101" else
           CLOCK / 57600  when BAUD_SEL = "110" else
           CLOCK / 115200 when BAUD_SEL = "111";
ONE_BIT_DEL <= ONE_BIT - 2; -- corrected # of clock cycles per ONE bit
-- # of clock cycles per One And Half bit
OAH_BIT <= CLOCK / 1200   + CLOCK/(1200*2)   when BAUD_SEL = "000" else
           CLOCK / 2400   + CLOCK/(2400*2)   when BAUD_SEL = "001" else	
           CLOCK / 4800   + CLOCK/(4800*2)   when BAUD_SEL = "010" else	
           CLOCK / 9600   + CLOCK/(9600*2)   when BAUD_SEL = "011" else	
           CLOCK / 19200  + CLOCK/(19200*2)  when BAUD_SEL = "100" else	
           CLOCK / 38400  + CLOCK/(38400*2)  when BAUD_SEL = "101" else	
           CLOCK / 57600  + CLOCK/(57600*2)  when BAUD_SEL = "110" else	
           CLOCK / 115200 + CLOCK/(115200*2) when BAUD_SEL = "111";
OAH_BIT_DEL <= OAH_BIT - 5;  -- corrected # of clock cycles per One And Half bit

----------------------------------------------------------------------
-- Machine: Receive
----------------------------------------------------------------------
Receive_machine: process (UART_CLK, UART_RESET)
begin
	if UART_RESET = '1' then
		Receive <= IDLE;
		-- Set reset or default values for outputs, signals and variables
		UART_DATA<=(others => '0');
		BIT_CNT<=0;
		BIT_DEL<=0;
		START_CNT<=0;
		DATA_VALID<='0';
	elsif UART_CLK'event and UART_CLK = '1' then
		-- Set default values for outputs, signals and variables
		-- ...
		case Receive is
			when IDLE =>
				BIT_CNT <= 0;
				BIT_DEL <= 0;
				START_CNT <= 0;
				DATA_VALID <= '0';
				case UART_RxD is
					when '1' =>
						Receive <= IDLE;
					when '0' =>
						Receive <= START;
					when others =>
						null;
				end case;
			when START =>
				START_CNT<=START_CNT+1;
				if UART_RxD= '0' and START_CNT < 3 then
					Receive <= START;
				elsif UART_RxD = '0' and START_CNT = 3 then
					Receive <= WAIT_OAH;
				elsif UART_RxD = '1' then
					Receive <= IDLE;
				end if;
			when WAIT_OAH =>
				BIT_DEL <= BIT_DEL + 1;
				if BIT_DEL < OAH_BIT_DEL then
					Receive <= WAIT_OAH;
				elsif BIT_DEL = OAH_BIT_DEL then
					Receive <= GET_BIT;
				end if;
			when GET_BIT =>
				BIT_DEL <= 0;
				if BIT_CNT < 8 then
					SHFT_REG(BIT_CNT) <= UART_RxD;
				end if;
				BIT_CNT <= BIT_CNT + 1;
				Receive <= WAIT_ONE;
			when WAIT_ONE =>
				BIT_DEL <= BIT_DEL + 1;
				if BIT_CNT < 9 and BIT_DEL = ONE_BIT_DEL then
					Receive <= GET_BIT;
				elsif BIT_CNT = 9 then
					Receive <= STOP;
				elsif BIT_CNT < 9 and BIT_DEL < ONE_BIT_DEL then
					Receive <= WAIT_ONE;
				end if;
			when STOP =>
				UART_DATA <= SHFT_REG;
				DATA_VALID <= '1';
				Receive <= IDLE;
--vhdl_cover_off
			when others =>
				null;
--vhdl_cover_on
		end case;
	end if;
end process;

end UART_RX;
