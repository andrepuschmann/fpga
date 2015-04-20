----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    15:29:24 02/27/2013
-- Design Name:
-- Module Name:    myfifo - Behavioral
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
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity myfifo is
    Generic(
        depth  : integer := 3 );
    Port(
        clk    : in  std_logic;
        rst    : in  std_logic;
        stb_in : in  std_logic;
        d_in   : in  std_logic_vector(31 downto 0);
        d_out  : out std_logic_vector(31 downto 0));
end myfifo;

architecture Behavioral of myfifo is

    constant MEM_DEPTH : integer := (2**depth) - 1;

    type memory_type is array (MEM_DEPTH downto 0) of std_logic_vector(31 downto 0);
    signal memory : memory_type := (others => (others => '0'));
    signal dout   : std_logic_vector(31 downto 0) := (others => '0');

begin

    d_out <= dout;

    process(clk,rst)
    begin
        if rst = '1' then
            memory <= (others => (others => '0'));
            dout   <= (others => '0');
        elsif rising_edge(clk) then
            dout <= memory(MEM_DEPTH);
            if stb_in = '1' then
                memory(MEM_DEPTH downto 1) <= memory(MEM_DEPTH-1 downto 0);
                memory(0) <= d_in;
            end if;
        end if;
    end process;

end Behavioral;

