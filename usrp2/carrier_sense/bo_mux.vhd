----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    19:15:03 01/28/2013
-- Design Name:
-- Module Name:    bo_mux - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity bo_mux is
    Port(
        clk        : in  std_logic;
        rst        : in  std_logic;
        round_in   : in  std_logic_vector( 2 downto 0);
        backoff_in : in  std_logic_vector(44 downto 0);
        val_out    : out std_logic_vector( 9 downto 0));
end bo_mux;

architecture Behavioral of bo_mux is
    signal timer_val : std_logic_vector (9 downto 0) := (others => '0');
begin

    val_out <= timer_val;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                timer_val <= (others => '0');
            else
                case to_integer(unsigned(round_in)) is
                    when 0 => timer_val <= "00000" & backoff_in( 4 downto  0);
                    when 1 => timer_val <= "0000"  & backoff_in(10 downto  5);
                    when 2 => timer_val <= "000"   & backoff_in(17 downto 11);
                    when 3 => timer_val <= "00"    & backoff_in(25 downto 18);
                    when 4 => timer_val <= "0"     & backoff_in(34 downto 26);
                    when 5 => timer_val <=           backoff_in(44 downto 35);
                    when others => timer_val <= (others => '1');
                end case;
            end if;
        end if;
    end process;

end Behavioral;

