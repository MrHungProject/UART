----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2022 03:51:06 PM
-- Design Name: 
-- Module Name: RX - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RX is
    generic ( PARITY : integer := 0;
              cnt    : integer := 0;
              DATAWIDTH : integer := 8;
              sam       : integer := 0;
              STOP      : integer := 2);
  Port ( CLK : in STD_LOGIC;
         RX  : in STD_LOGIC;
         DATA_RX : OUT STD_LOGIC_VECTOR(DATAWIDTH - 1 downto 0);
         DONE_R : out STD_LOGIC);
end RX;

architecture Behavioral of RX is
type RX_STATE is (s_IDLE , s_START , s_REC, s_PARITY, s_STOP);
signal state : RX_STATE := s_IDLE;
signal DATA_s : STD_LOGIC_VECTOR(DATAWIDTH - 1 downto 0) := (others => '0');
signal DONE_s : STD_LOGIC := '0';
signal check : STD_LOGIC_VECTOR(1 downto 0) := (others =>  '0');
signal error : STD_LOGIC := '0';

signal count : integer range 0 to cnt   := 0;
signal Index : integer range 0 to DATAWIDTH - 1 := 0;


begin
RX_pr: process(CLK)
begin
    if rising_edge(CLK) then
        case state is
        When s_IDLE =>
            count  <= 0;
            index <= 0;
            done_s <= '0';
            check    <= (others => '0');
            if RX = '0' then
                state  <=   s_start;
            else
                state   <= s_idle;
            end if;
        when s_start => 
            if count < sam then
                count <= count + 1;
            elsif count = sam and RX = '0' then
                count <= 0;
                state <= s_REC;
            else
                count <= 0;
                state <= s_IDLE;
            end if;
        when s_REC => 
            if count < cnt then
                count <= count + 1 ;
                state <= s_REC;
                Index <= Index;
            elsif count = cnt and Index < DATAWIDTH - 1 then
                count   <= 0;
                state   <= s_REC ;
                DATA_s(INDEX) <= RX;
                check <= check + RX;
                Index <= Index + 1;
            else
                count <= 0;
                DATA_s(Index) <= RX ;
                check <= check + RX;
                if PARITY = 0 then
                    state <= s_stop;
                else
                    state <= s_parity;
                end if;
            end if;
        when s_PARITY =>
            if count < cnt then
                count   <= count + 1;
            elsif count = cnt then
                count  <= 0;
                if check(0) = RX then
                    error <= '0';
                 else
                    error <= '1';
                end if;
                state <= s_stop;
            end if;
        when s_stop => 
            if STOP = 1 then
                if count < cnt then
                    count <= count + 1;
                    state <= s_STOP;
                elsif count = cnt then
                    DONE_s <= '1';
                    state <= s_IDLE;
                end if;
           
            elsif STOP = 2 then
                if count < 2*cnt + 1 then
                    count <= count + 1;
                    state <= s_stop ;
                elsif count = 2*cnt + 1 then
                    DONE_s <= '1';
                    state <= s_IDLE;
                end if;
            end if;
        when others => 
            state <= state;
        end case;
    end if;
end process RX_pr;
DONE_R <= DONE_S;

synch : process(CLK)
    begin
        if rising_edge(CLK) then
            DATA_RX <= DATA_s;
        end if;
end process;
end Behavioral;
