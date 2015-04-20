----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    17:03:18 04/23/2013
-- Design Name:
-- Module Name:    settings_ctrl - Behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity settings_ctrl is
    generic(
        settings_addr  : integer range 255 downto 0 := 0;
        threshold_addr : integer range 255 downto 0 := 0;
        slottime_addr  : integer range 255 downto 0 := 0);
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- Memory Interface
        reg_strobe_in : in  std_logic;
        reg_addr_in   : in  std_logic_vector( 7 downto 0);
        reg_data_in   : in  std_logic_vector(31 downto 0);

        -- Metadata
        cs_data_in    : in  std_logic_vector(63 downto 0);

        -- Settings
        settings_out  : out std_logic_vector(31 downto 0);
        threshold_out : out std_logic_vector(31 downto 0);
        slottime_out  : out std_logic_vector(17 downto 0);

        -- Backoff Values
        backoffs_out  : out std_logic_vector(44 downto 0);

        -- DIFS
        difs_out      : out std_logic_vector(19 downto 0);

        -- Readback Val
        readback_out  : out std_logic_vector(31 downto 0));
end settings_ctrl;

architecture Behavioral of settings_ctrl is

    component readback_handler is
        Port(
            clk          : in  std_logic;
            rst          : in  std_logic;
            addr_in      : in  std_logic_vector( 7 downto 0);
            backoff_in   : in  std_logic_vector(44 downto 0);
            threshold_in : in  std_logic_vector(31 downto 0);
            difs_in      : in  std_logic_vector(19 downto 0);
            slottime_in  : in  std_logic_vector(17 downto 0);
            data_out     : out std_logic_vector(31 downto 0));
    end component;

    signal settings  : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal threshold : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal slottime  : STD_LOGIC_VECTOR (17 downto 0) := (others => '0');
    signal difs      : STD_LOGIC_VECTOR (19 downto 0) := (others => '0');

begin

    difs  <= std_logic_vector(SHIFT_LEFT(unsigned(slottime),1) + unsigned("0" & cs_data_in(63 downto 45)));
    settings_out  <= settings;
    threshold_out <= threshold;
    slottime_out  <= slottime;
    difs_out      <= difs;
    backoffs_out  <= cs_data_in(44 downto 0);

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                settings  <= (others => '0');
                threshold <= (others => '0');
                slottime  <= (others => '0');
            elsif reg_strobe_in = '1' then
                if to_integer(unsigned(reg_addr_in)) = settings_addr then
                    settings <= reg_data_in;
                elsif to_integer(unsigned(reg_addr_in)) = threshold_addr then
                    threshold <= reg_data_in;
                elsif to_integer(unsigned(reg_addr_in)) = slottime_addr then
                    slottime <= reg_data_in(17 downto 0);
                end if;
            end if;
        end if;
    end process;

    readback : readback_handler
    port map(
        clk          => clk,
        rst          => rst,
        addr_in      => settings(15 downto 8),
        backoff_in   => cs_data_in(44 downto 0),
        threshold_in => threshold,
        difs_in      => difs,
        slottime_in  => slottime,
        data_out     => readback_out);

end Behavioral;

