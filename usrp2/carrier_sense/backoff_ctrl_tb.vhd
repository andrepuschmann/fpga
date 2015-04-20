--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   15:03:16 04/25/2013
-- Design Name:
-- Module Name:   C:/Users/ts/Documents/fpga/usrp2/carrier_sense/backoff_ctrl_tb.vhd
-- Project Name:  u2plus
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: backoff_ctrl
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- USE ieee.numeric_std.ALL;

ENTITY backoff_ctrl_tb IS
END backoff_ctrl_tb;

ARCHITECTURE behavior OF backoff_ctrl_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT backoff_ctrl
    PORT(
         clk         : IN  std_logic;
         rst         : IN  std_logic;
         run_in      : IN  std_logic;
         free_in     : IN  std_logic;
         slottime_in : IN  std_logic_vector(19 downto 0);
         backoffs_in : IN  std_logic_vector(44 downto 0);
         round_in    : IN  std_logic_vector( 2 downto 0);
         ready_out   : OUT std_logic;
         debug       : OUT std_logic_vector( 9 downto 0);
         slo         : OUT std_logic_vector(31 downto 0);
         boo         : OUT std_logic_vector(31 downto 0)
        );
    END COMPONENT;


    --Inputs
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal run_in      : std_logic := '0';
    signal free_in     : std_logic := '0';
    signal slottime_in : std_logic_vector(19 downto 0) := (others => '0');
    signal backoffs_in : std_logic_vector(44 downto 0) := (others => '0');
    signal round_in    : std_logic_vector( 2 downto 0) := (others => '0');

    --Outputs
    signal ready_out   : std_logic;
    signal debug       : std_logic_vector( 9 downto 0);
    signal slo, boo    : std_logic_vector(31 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: backoff_ctrl PORT MAP (
        clk         => clk,
        rst         => rst,
        run_in      => run_in,
        free_in     => free_in,
        slottime_in => slottime_in,
        backoffs_in => backoffs_in,
        round_in    => round_in,
        ready_out   => ready_out,
        debug       => debug,
        slo         => slo,
        boo         => boo
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;


    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns.
        wait for 100 ns;

        wait for clk_period*10;
        wait for clk_period/2;

        -- insert stimulus here
        slottime_in <= "00000000000000001010";
        backoffs_in <= "000000011000000010100000100000001100001000001";
        round_in    <= "011";
        free_in     <= '1';
        wait for clk_period;
        run_in      <= '1';

        wait for clk_period*8;
        free_in     <= '0';
        wait for clk_period*7;
        free_in     <= '1';

        wait for clk_period*60;
        run_in      <= '0';

        wait;
    end process;

END;
