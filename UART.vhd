----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2022 11:01:53 PM
-- Design Name: 
-- Module Name: UART - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART is
   Generic(  PARITY     : integer := 0;
             BAUDRATE   : integer := 9600;
             DATAWIDTH  : integer := 8;
             SAMPLERATE : integer := 19200;
             STOPBIT    : integer := 1);
    Port ( CLK_50M  : in STD_LOGIC;
           UART_RX  : in STD_LOGIC;
           UART_TX  : out STD_LOGIC);
--           SMG_DATA : out STD_LOGIC_VECTOR (7 downto 0);
--           SCAN_SIG : out STD_LOGIC_VECTOR (2 downto 0));
end UART;

architecture Behavioral of UART is
component TX is
     Generic (PARITY     : integer := 0;
             cnt        : integer := 0;
             DATAWIDTH  : integer := 8;
             sam        : integer := 0;
             STOPBIT    : integer := 1);
    Port ( CLK      : in STD_LOGIC;
           NEWDATA  : in STD_LOGIC;
           DATA     : in STD_LOGIC_VECTOR (7 downto 0);
           TX       : out STD_LOGIC;
           DONE     : out STD_LOGIC);
end component;

component RX is
    generic ( PARITY : integer := 0;
              cnt    : integer := 0;
              DATAWIDTH : integer := 8;
              sam       : integer := 0;
              STOP      : integer := 1);
  Port ( CLK : in STD_LOGIC;
         RX  : in STD_LOGIC;
         DATA_RX : OUT STD_LOGIC_VECTOR(DATAWIDTH - 1 downto 0);
         DONE_R : out STD_LOGIC);
 end component;
 
constant cnt: integer := 50e6/BAUDRATE - 1 ;
constant sam : integer := 50e6/SAMPLERATE - 1;

signal DATA     :  STD_LOGIC_VECTOR(DATAWIDTH - 1 downto 0) := ( others => '0');
signal NEWDATA  :   STD_LOGIC;
signal DONE     : STD_LOGIC;

begin
UARTRX_inst0: RX
    generic map
    (
        PARITY      => PARITY,   
        cnt         => cnt,
        DATAWIDTH   => DATAWIDTH,
        sam         => sam,
        STOP     => STOPBIT
    )
    port map
    (
        CLK         => CLK_50M,
        RX          => UART_RX,
        DATA_RX     => DATA,
        DONE_R      => NEWDATA
    );

UARTTX_inst1: TX
    generic map
    (
        PARITY      => PARITY,   
        cnt         => cnt,
        DATAWIDTH   => DATAWIDTH,
        sam         => sam,
        STOPBIT     => STOPBIT
    )
    port map
    (
        CLK         => CLK_50M,
        NEWDATA     => NEWDATA,
        DATA        => DATA,
        TX          => UART_TX,
        DONE        => DONE
    );
end Behavioral;


























