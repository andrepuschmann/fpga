----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    17:33:12 01/28/2013
-- Design Name:
-- Module Name:    readback_handler - Behavioral
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

entity readback_handler is
    Port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        addr_in      : in  std_logic_vector( 7 downto 0);
        backoff_in   : in  std_logic_vector(44 downto 0);
        threshold_in : in  std_logic_vector(31 downto 0);
        difs_in      : in  std_logic_vector(19 downto 0);
        slottime_in  : in  std_logic_vector(17 downto 0);
        data_out     : out std_logic_vector(31 downto 0));
end readback_handler;

architecture Behavioral of readback_handler is
    signal data : std_logic_vector(31 downto 0) := (others => '0');
begin

    data_out <= data;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                data <= (others => '0');
            else
                case to_integer(unsigned(addr_in)) is
                    when 1 => data <= "000000000000000000000000000" & backoff_in( 4 downto  0);
                    when 2 => data <= "00000000000000000000000000"  & backoff_in(10 downto  5);
                    when 3 => data <= "0000000000000000000000000"   & backoff_in(17 downto 11);
                    when 4 => data <= "000000000000000000000000"    & backoff_in(25 downto 18);
                    when 5 => data <= "00000000000000000000000"     & backoff_in(34 downto 26);
                    when 6 => data <= "0000000000000000000000"      & backoff_in(44 downto 35);
                    when 7 => data <= "00000000000000"              & slottime_in;
                    when 8 => data <= threshold_in;
                    when 9 => data <= "000000000000" & difs_in;
                    when others => data <= (others => '0');
                end case;
            end if;
        end if;
    end process;

end Behavioral;

