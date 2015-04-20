----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    11:01:19 01/31/2013
-- Design Name:
-- Module Name:    rec_mux - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rec_mux is
    Port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        addr_in    : in  std_logic_vector( 2 downto 0);
        avg8_in    : in  std_logic_vector(31 downto 0);
        avg16_in   : in  std_logic_vector(31 downto 0);
        avg32_in   : in  std_logic_vector(31 downto 0);
        avg64_in   : in  std_logic_vector(31 downto 0);
        avg128_in  : in  std_logic_vector(31 downto 0);
        avg256_in  : in  std_logic_vector(31 downto 0);
        avg512_in  : in  std_logic_vector(31 downto 0);
        strobe_in  : in  std_logic;
        strobe_out : out std_logic;
        avg_out    : out std_logic_vector(31 downto 0));
end rec_mux;

architecture Behavioral of rec_mux is
    signal avg    : std_logic_vector(31 downto 0) := (others => '0');
    signal strobe : std_logic := '0';
begin

    avg_out    <= avg;
    strobe_out <= strobe;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                avg <= (others => '0');
            elsif strobe_in = '1' then
                case addr_in is
                    when "000" => avg <= avg8_in;
                    when "001" => avg <= avg16_in;
                    when "010" => avg <= avg32_in;
                    when "011" => avg <= avg64_in;
                    when "100" => avg <= avg128_in;
                    when "101" => avg <= avg256_in;
                    when "110" => avg <= avg512_in;
                    when others => avg <= (others => '0');
                end case;
                strobe <= '1';
            else
                strobe <= '0';
            end if;
        end if;
    end process;

end Behavioral;

