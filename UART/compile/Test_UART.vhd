-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : UART
-- Author      : Jerzy Kasperek & Pawe³ J. Rajda
-- Company     : AGH Kraków
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\GP\UART\UART\compile\Test_UART.vhd
-- Generated   : Mon Oct 27 17:06:01 2025
-- From        : C:\My_Designs\GP\UART\UART\src\Test_UART.bde
-- By          : Bde2Vhdl ver. 2.6
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;

entity Test_UART is
  port(
       UART_RxD : in std_logic;
       UART_RESET : in std_logic;
       UART_CLK : in std_logic;
       BAUD_SEL : in STD_LOGIC_VECTOR(2 downto 0);
       UART_TxD : out STD_LOGIC
  );
end Test_UART;

architecture Test_UART of Test_UART is

---- Component declarations -----

component UART_RX
  port(
       UART_RESET : in std_logic;
       UART_CLK : in std_logic;
       UART_DATA : out std_logic_vector(7 downto 0);
       DATA_VALID : out std_logic;
       UART_RxD : in std_logic;
       BAUD_SEL : in std_logic_vector(2 downto 0)
  );
end component;
component UART_TX
  port(
       BAUD_SEL : in STD_LOGIC_VECTOR(2 downto 0);
       UART_TxD : out STD_LOGIC;
       UART_CLK : in STD_LOGIC;
       UART_DATA : in STD_LOGIC_VECTOR(7 downto 0);
       UART_RESET : in STD_LOGIC;
       DATA_VALID : in STD_LOGIC
  );
end component;

---- Signal declarations used on the diagram ----

signal CLK : std_logic;
signal DATA_VALID : std_logic;
signal RESET : std_logic;
signal UART_DATA : std_logic_vector(7 downto 0);

begin

----  Component instantiations  ----

U_RX : UART_RX
  port map(
       UART_RESET => RESET,
       UART_CLK => CLK,
       UART_DATA => UART_DATA,
       DATA_VALID => DATA_VALID,
       UART_RxD => UART_RxD,
       BAUD_SEL => BAUD_SEL
  );

U_TX : UART_TX
  port map(
       BAUD_SEL => BAUD_SEL,
       UART_TxD => UART_TxD,
       UART_CLK => CLK,
       UART_DATA => UART_DATA,
       UART_RESET => RESET,
       DATA_VALID => DATA_VALID
  );


---- Terminal assignment ----

    -- Inputs terminals
	CLK <= UART_CLK;
	RESET <= UART_RESET;


end Test_UART;
