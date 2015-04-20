----------------------------------------------------------------------------------
-- Company:        TU Ilmenau
-- Engineer:       Tim Schuschies
--
-- Create Date:    13:52:41 01/28/2013
-- Design Name:    rssi.vhd
-- Module Name:    rssi - Behavioral
-- Project Name:   UHDCSMA
-- Target Device:  USRP2/Spartan3A
-- Tool versions:  ISE 12.4
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity rssi is
    Port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        sample_in  : in  std_logic_vector(31 downto 0);
        strobe_in  : in  std_logic;
        rssi_out   : out std_logic_vector(31 downto 0);
        strobe_out : out std_logic);
end rssi;

architecture Behavioral of rssi is

    signal stb, strobe     : std_logic := '0';
    signal inphase2, quad2 : std_logic_vector(31 downto 0) := (others => '0');
    signal rssi            : std_logic_vector(31 downto 0) := (others => '0');


begin

    strobe_out <= stb;
    rssi_out   <= rssi;

    process(clk,rst)
    begin
        if rst = '1' then
            stb    <= '0';
            strobe <= '0';
                rssi   <= (others => '0');
        elsif rising_edge(clk) then
            if strobe_in = '1' then
                inphase2  <= std_logic_vector((signed(sample_in(15 downto  0))*signed(sample_in(15 downto  0))));
                quad2     <= std_logic_vector((signed(sample_in(31 downto 16))*signed(sample_in(31 downto 16))));
                stb       <= '0';
                strobe    <= '1';
             else
                rssi      <= std_logic_vector(unsigned(inphase2) + unsigned(quad2));
                stb       <= strobe;
                strobe    <= '0';
             end if;
        end if;
    end process;

end Behavioral;

