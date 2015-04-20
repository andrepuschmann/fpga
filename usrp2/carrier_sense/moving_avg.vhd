----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    15:38:48 02/27/2013
-- Design Name:
-- Module Name:    avg - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity moving_avg is
    Generic(
        DEPTH : natural := 3);
    Port(
        clk        : in  std_logic;
        rst        : in  std_logic;
        strobe_in  : in  std_logic;
        data_in    : in  std_logic_vector(31 downto 0);
        strobe_out : out std_logic;
        avg_out    : out std_logic_vector(31 downto 0));
end moving_avg;

architecture Behavioral of moving_avg is

    component myfifo is
        generic(
            DEPTH  : integer);
        port(
            clk    : in  std_logic;
            rst    : in  std_logic;
            stb_in : in  std_logic;
            d_in   : in  std_logic_vector(31 downto 0);
            d_out  : out std_logic_vector(31 downto 0));
    end component;

    signal old_val, avg : std_logic_vector(31 downto 0) := (others => '0');
    signal sum          : std_logic_vector(DEPTH + 31 downto 0) := (others => '0');
    signal strobe       : std_logic := '0';

begin

    avg_out <= avg;
    strobe_out <= strobe;

    f : myfifo
    generic map(DEPTH)
    port map(
        clk    => clk,
        rst    => rst,
        stb_in => strobe_in,
        d_in   => data_in,
        d_out  => old_val);

    process(clk,rst)
    begin
        if rst = '1' then
            sum <= (others => '0');
        elsif rising_edge(clk) then
            avg <= std_logic_vector(SHIFT_RIGHT(signed(sum), DEPTH)(31 downto 0));
            if strobe_in = '1' then
                sum    <= std_logic_vector(signed(sum) + signed(data_in) - signed(old_val));
                strobe <= '1';
            else
                strobe <= '0';
            end if;
        end if;
    end process;

end Behavioral;

