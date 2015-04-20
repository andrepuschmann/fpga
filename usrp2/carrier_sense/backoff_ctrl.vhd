----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    14:47:23 04/25/2013
-- Design Name:
-- Module Name:    backoff_ctrl - Behavioral
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

entity backoff_ctrl is
    Port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        run_in      : in  std_logic;
        free_in     : in  std_logic;
        slottime_in : in  std_logic_vector(17 downto 0);
        backoffs_in : in  std_logic_vector(44 downto 0);
        round_in    : in  std_logic_vector( 2 downto 0);
        state_out   : out std_logic_vector( 1 downto 0);
        debug       : out std_logic_vector( 9 downto 0));
end backoff_ctrl;

architecture Behavioral of backoff_ctrl is

    component bo_mux is
        Port(
           clk        : in  std_logic;
           rst        : in  std_logic;
           round_in   : in  std_logic_vector( 2 downto 0);
           backoff_in : in  std_logic_vector(44 downto 0);
           val_out    : out std_logic_vector( 9 downto 0));
    end component;

    signal val     : std_logic_vector(9 downto 0) := (others => '0');
    signal slot    : integer   :=  0;
    signal backoff : integer   :=  0;
    signal state   : std_logic_vector(1 downto 0) := (others => '0');

    constant STATE_WAIT        : std_logic_vector(1 downto 0) := "00";
    constant STATE_INTERRUPTED : std_logic_vector(1 downto 0) := "01";
    constant STATE_READY       : std_logic_vector(1 downto 0) := "11";

begin

    debug     <= val;
    state_out <= state;

    mux : bo_mux
    port map(
        clk        => clk,
        rst        => rst,
        round_in   => round_in,
        backoff_in => backoffs_in,
        val_out    => val);

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state   <= STATE_WAIT;
                backoff <= 0;
                slot    <= 0;
            -- decrement slot
            elsif run_in = '1' and free_in = '1' then
                -- backoff completed, send frame
                if backoff >= to_integer(unsigned(val)) then
                    backoff <= 0;
                    state   <= STATE_READY;
                -- full slot
                elsif slot >= to_integer(unsigned(slottime_in)) then
                        slot    <= 0;
                        backoff <= backoff + 1;
                -- increment slot
                else
                    slot <= slot + 1;
                end if;
            -- channel busy - reset slot
            elsif run_in = '1' and free_in = '0' then
                slot  <= 0;
                state <= STATE_INTERRUPTED;
            -- disabled
            else
                slot  <= 0;
                state <= STATE_WAIT;
            end if;
        end if;
    end process;

end Behavioral;

