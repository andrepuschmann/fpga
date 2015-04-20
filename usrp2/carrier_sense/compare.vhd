----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    15:28:49 01/28/2013
-- Design Name:
-- Module Name:    compare - Behavioral
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

entity compare is
    Port(
        clk          : in  std_logic;
        rst          : in  std_logic;
        strobe_in    : in  std_logic;
        avg_in       : in  std_logic_vector (31 downto 0);
        threshold_in : in  std_logic_vector (31 downto 0);
        free_out     : out std_logic);
end compare;

architecture Behavioral of compare is
    signal free      : std_logic := '0';
    signal threshold : std_logic_vector(31 downto 0) := (others => '0');
begin

    free_out <= free;

    cmp : process(clk,rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                free <= '0';
            elsif strobe_in = '1' then
                if unsigned(avg_in) < unsigned(threshold_in) then
                    free <= '1';
                else
                    free <= '0';
                end if;
            end if;
        end if;
    end process;


end Behavioral;

