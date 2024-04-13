----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2022 05:40:31 PM
-- Design Name: 
-- Module Name: TX - Behavioral
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TX is
  Generic (PARITY     : integer := 0;
             cnt        : integer := 0;
             DATAWIDTH  : integer := 8;
             sam        : integer := 0;
             STOPBIT    : integer := 2);
    Port ( CLK      : in STD_LOGIC;
           NEWDATA  : in STD_LOGIC;
           DATA     : in STD_LOGIC_VECTOR (7 downto 0);
           TX       : out STD_LOGIC;
           DONE     : out STD_LOGIC);
end TX;

architecture Behavioral of TX is

---fsm--
type TX_STATE is ( s_IDLE , s_START ,s_TRAN , s_PARITY, s_STOP);
signal state        :   TX_STATE := s_IDLE;
signal TX_signal    :   STD_LOGIC := '1';
signal DATA_s       :   STD_LOGIC_VECTOR( 7 downto 0) := (others => '0');
signal DONE_s       :   STD_lOGIC := '0';
signal check        :   STD_LOGIC_VECTOR( 1 downto 0) := ( others => '0');

signal count        :   integer range 0 to cnt := 0;
signal Index        :   integer range 0 to DATAWIDTH - 1 := 0; 


begin

TX_pr: process(CLK)
begin
    if rising_edge(CLK) then
        case state is
        when s_idle =>
            done_s      <= '0';
            tx_signal   <= '1';
            count       <= 0;
            Index       <= 0;
            if NEWDATA  = '1' then
                state   <=  s_start;
                data_s  <=  data;
            else
                state   <= s_idle;
            end if;
        when s_start    =>
            done_s      <=  '0';
            tx_signal   <=  '0';
            if count    <   cnt then
                count   <= 0;
                state   <=  s_start;
            else 
                count <= 0;
                state <= s_tran;
            end if;
        when s_tran => 
            tx_signal <= data_s(index);
            check     <= check + data_s(index);
            if count < cnt then
                count <= count + 1;
                state <= s_tran;
                index <= index;
            elsif count = cnt and index < 7 then
                count <= 0;
                state <= s_tran;
                index <= index + 1;
            else
                count <= 0;
                if PARITY = 0 then
                    state <= s_stop;
                else
                    state <= s_parity;
                end if;
            end if;
        when s_parity => 
            tx_signal <= check(0);
            if count < cnt then
                count <= count + 1;
                state <= s_parity;
            else
                state <= s_stop;
                count <= 0;
            end if;
        when s_stop => 
            tx_signal <= '1' ;
            if stopbit = 1 then
                if count < cnt then
                    count <= count + 1;
                elsif count = cnt then
                    done_s <= '1';
                    state <= s_idle;
                end if;
            elsif STOPBIT = 2 then
                if count < 2*cnt + 1 then
                    count <= count + 1;
                    state <= s_stop;
                elsif   count = 2*cnt + 1 then
                    DONE_s  <= '1';
                    state <= s_idle;
                end if;
            end if;
        when others => 
            state <= state;
         end case;
    end if;
end process;
TX <= TX_signal;
DONE    <= Done_s;

end Behavioral;
