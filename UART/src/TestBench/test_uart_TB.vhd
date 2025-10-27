---------------------------------------------------------------------------------------------------
--
-- Title       : UART_transmitter
-- Design      : TestBench tutorial
-- Author      : Jerzy Kasperek & Pawe³ J. Rajda
-- Company     : AGH Kraków
-- Version     : 1.0
---------------------------------------------------------------------------------------------------
--
-- Description : Behavioral model of UART transmitter
--             
-- Model reads semicode from text file and performs UART transmissions
-- Supports:
--  outputs:    TxD - UART Transmit Data
--
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Revision History:
--
-- 1.0 - initial
------------------------------------------------------------------------------------

library STD;
use STD.textio.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_textio.all;	

-- utility functions
use WORK.UART_util.all;

entity test_uart_tb is
end test_uart_tb;

architecture TB_ARCHITECTURE of test_uart_tb is
	-- Component declaration of the tested unit
	component test_uart
		port(
			UART_RxD : in STD_LOGIC;
			BAUD_SEL : in STD_LOGIC_VECTOR(2 downto 0);
			UART_TxD : out STD_LOGIC;
			UART_CLK : in STD_LOGIC;
			UART_RESET : in STD_LOGIC);
	end component;
	
	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal UART_CLK : STD_LOGIC;
	signal UART_RESET : STD_LOGIC;
	signal UART_RxD : STD_LOGIC;
	signal BAUD_SEL : STD_LOGIC_VECTOR(2 downto 0) := "000"; -- initialize to avoid arithmetic warnings
	-- Observed signals - signals mapped to the output ports of tested entity
	signal UART_TxD : STD_LOGIC;
	
	
	-- logical simulation start/stop flag
	signal ENDSIM:	boolean := false;
	-- UART divider uses 8MHz
	constant UART_CLK_PERIOD: TIME := 1 sec / 1_843_200; 	 
	-- reset pulse lenght
	constant RESET_PULSE_TIME: TIME := 100 ns; 	 	
	-- UART metacode source file	
	file CODE_INFILE : TEXT open READ_MODE is "$DSN\src\TestBench\UART_code.txt";	 
	-- UART simulation log file	
	file LOG_OUTFILE : TEXT open WRITE_MODE is "$DSN\src\TestBench\UART_log.txt";	
	
begin
	-- Unit Under Test port map
	UUT : test_uart
	port map (
		UART_CLK => UART_CLK,
		UART_RESET => UART_RESET,
		UART_RxD => UART_RxD,
		BAUD_SEL => BAUD_SEL,
		UART_TxD => UART_TxD
		);	
	------------------------------------------------------------------------------------	
	-- main simulation process
	------------------------------------------------------------------------------------	
	UART_TEST_RUN: process	 
		
		variable IN_LINE:LINE;								-- input line
		variable OUT_LINE:LINE;								-- output line
		
		variable code: character;							-- code of operation
		variable data_byte: std_logic_vector(7 downto 0);	-- data to be sent
		variable interval: integer;							-- time to wait for
		variable timestamp: time;	  						-- current time for report
			
		variable BAUD_RATE: integer := 19200;
		variable CLK_PERIOD: TIME := 1 sec / 19200;
		variable baud_rate_in: integer;
		
		variable received_byte: std_logic_vector(7 downto 0);
		
	begin
		
		------------------------------------------------------------------------------------	
		UART_RxD <= '1';			-- initialize serial output  
		BAUD_SEL <= BAUD_SEL_19200;	-- initialize baud selector 
		BAUD_RATE := 19200;
		CLK_PERIOD := 1 sec / BAUD_RATE;
		------------------------------------------------------------------------------------	
		-- metacode read loop
		------------------------------------------------------------------------------------	
		
		while true loop	  
			if( not endfile(CODE_INFILE)) then 
				-- execute consecutive metacode lines				
				readline(CODE_INFILE,IN_LINE);					-- read line of a file	
				read(IN_LINE,code);								-- fetch operation metacode
				
				case code is
					when ';' =>									-- this is a comment so skip this line
						NULL; 
					
					when 'W' =>									-- WRITE command 
						-- get parameter
						timestamp:= NOW;						-- store current time
						hread(IN_LINE,data_byte);				-- get data to send
						
						CLK_PERIOD := 1 sec / BAUD_RATE;
						
						
						-- write log to output file	  
						write(OUT_LINE,timestamp,right,15,us);	-- write current simulation time to line
						write(OUT_LINE,":   W ");				-- append operation identifier to line
						hwrite(OUT_LINE,data_byte,right);		-- append data sent to line
						
						write(OUT_LINE, " (at " & integer'image(BAUD_RATE) & " baud)");
						writeline(LOG_OUTFILE,OUT_LINE);
						
						
						UART_send_byte(UART_RxD, data_byte, CLK_PERIOD); 
						UART_receive_byte(UART_TxD, received_byte, CLK_PERIOD);

						if (data_byte /= received_byte) then
							-- Zapisz czas wyst¹pienia b³êdu
							timestamp := NOW; 
							write(OUT_LINE, timestamp, right, 15, us);
							write(OUT_LINE, ":   !!! OSTRZE¯ENIE: B£¥D PÊTLI ZWROTNEJ !!!");
							writeline(LOG_OUTFILE, OUT_LINE);
							
							-- Druga linia b³êdu ze szczegó³ami
							write(OUT_LINE, "             Wys³ano (oczekiwano): ");
							hwrite(OUT_LINE, data_byte);
							write(OUT_LINE, ", Odebrano: ");
							hwrite(OUT_LINE, received_byte);
							writeline(LOG_OUTFILE, OUT_LINE);
						end if;
						
					
					when 'N' =>									-- NOP command
						-- get parameter
						read(IN_LINE,interval);					-- get wait time
						timestamp:= NOW;						-- store current time
						wait for interval * 1us;				-- execute wait
						-- write log to output file	  
						write(OUT_LINE,timestamp,right,15,us);	-- write current simulation time 
						write(OUT_LINE,":   ");
						write(OUT_LINE,"Wait for ",right,1);	-- append operation description
						write(OUT_LINE,interval,right,1);		-- append time
						write(OUT_LINE," us");					-- append unit
						writeline(LOG_OUTFILE,OUT_LINE);
					
						
					when 'B' =>
						-- get parameter
						read(IN_LINE, baud_rate_in);            -- odczytaj now¹ prêdkoœæ
						timestamp := NOW;                       -- zapisz czas
						
						-- Zagnie¿d¿ona instrukcja case do walidacji i ustawienia
						case baud_rate_in is
							when 1200 =>
								BAUD_RATE := 1200;
								BAUD_SEL <= BAUD_SEL_1200;
							when 2400 =>
								BAUD_RATE := 2400;
								BAUD_SEL <= BAUD_SEL_2400;
							when 4800 =>
								BAUD_RATE := 4800;
								BAUD_SEL <= BAUD_SEL_4800;
							when 9600 =>
								BAUD_RATE := 9600;
								BAUD_SEL <= BAUD_SEL_9600;
							when 19200 =>
								BAUD_RATE := 19200;
								BAUD_SEL <= BAUD_SEL_19200;
							when 38400 =>
								BAUD_RATE := 38400;
								BAUD_SEL <= BAUD_SEL_38400;
							when 57600 =>
								BAUD_RATE := 57600;
								BAUD_SEL <= BAUD_SEL_57600;
							when 115200 =>
								BAUD_RATE := 115200;
								BAUD_SEL <= BAUD_SEL_115200;
							when others =>
								-- Nieprawid³owa wartoœæ
								report "BLAD: Nieprawidlowa wartosc BAUD_RATE: " & integer'image(baud_rate_in) severity ERROR;
								-- Zapis do logu
								write(OUT_LINE, timestamp, right, 15, us);
								write(OUT_LINE, ":   BLAD: Nieprawidlowy BAUD_RATE: ");
								write(OUT_LINE, baud_rate_in);
								writeline(LOG_OUTFILE, OUT_LINE);
								-- Zatrzymanie symulacji
								ENDSIM <= true;
								wait;
						end case;
						
						-- Zapis do logu (tylko dla poprawnych wartoœci)
						write(OUT_LINE, timestamp, right, 15, us);
						write(OUT_LINE, ":   B ");
						write(OUT_LINE, "Ustawiono BAUD_RATE na ");
						write(OUT_LINE, BAUD_RATE);
						writeline(LOG_OUTFILE, OUT_LINE);
						
						
					when 'E' =>									-- END of simulation command
						timestamp:= NOW;						-- store current time
						-- write log to output file	  
						write(OUT_LINE,timestamp,right,15,us);	-- write current simulation time to line
						write(OUT_LINE,":   Simulation end ");	-- append operation identifier to line
						writeline(LOG_OUTFILE,OUT_LINE);		-- write line to file
						ENDSIM <= true;
						wait;									-- forever
						
					
					when others =>	
						report "Code not recognized" severity Warning; 
					
				end case; 
				
			else
				wait;	-- forever
			end if;
		end loop;
	end process	;	   	
	
	------------------------------------------------------------------------------------	
	-- CLK process
	------------------------------------------------------------------------------------	
	UART_CLK_GEN: process
	begin
		if ENDSIM = false 
			then
			UART_CLK <= '0';
			wait for UART_CLK_PERIOD/2;
			UART_CLK <= '1';
			wait for UART_CLK_PERIOD/2;
		else
			wait;
		end if;	
	end process;
	
	------------------------------------------------------------------------------------	
	-- RESET process
	------------------------------------------------------------------------------------	
	UART_RESET_GEN: process
	begin		
		UART_RESET <= '1';
		wait for RESET_PULSE_TIME;
		UART_RESET <= '0';
		
		wait;
	end process;
	------------------------------------------------------------------------------------	
end TB_ARCHITECTURE;

------------------------------------------------------------------------------------	
configuration TESTBENCH_FOR_test_uart of test_uart_tb is
	for TB_ARCHITECTURE
		for UUT : test_uart
			use entity work.test_uart(test_uart);
		end for;
	end for;
end TESTBENCH_FOR_test_uart;
------------------------------------------------------------------------------------	




