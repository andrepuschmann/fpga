--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   18:41:38 04/23/2013
-- Design Name:
-- Module Name:   C:/Users/ts/Documents/fpga/usrp2/carrier_sense/settings_ctrl_tb.vhd
-- Project Name:  u2plus
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: settings_ctrl
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
--USE ieee.numeric_std.ALL;

ENTITY settings_ctrl_tb IS
END settings_ctrl_tb;

ARCHITECTURE behavior OF settings_ctrl_tb IS

   -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT settings_ctrl
        GENERIC(
            settings_addr  : integer;
            threshold_addr : integer;
            slottime_addr  : integer);
        PORT(
            clk            : IN  std_logic;
            rst            : IN  std_logic;
            reg_strobe_in  : IN  std_logic;
            reg_addr_in    : IN  std_logic_vector( 7 downto 0);
            reg_data_in    : IN  std_logic_vector(31 downto 0);
            cs_data_in     : in  std_logic_vector(63 downto 0);
            settings_out   : OUT std_logic_vector(31 downto 0);
            threshold_out  : OUT std_logic_vector(31 downto 0);
            slottime_out   : OUT std_logic_vector(17 downto 0);
            backoffs_out   : out std_logic_vector(44 downto 0);
            difs_out       : out std_logic_vector(19 downto 0);
            readback_out   : out std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

    --Inputs
    signal clk           : std_logic := '0';
    signal rst           : std_logic := '0';
    signal reg_strobe_in : std_logic := '0';
    signal reg_addr_in   : std_logic_vector( 7 downto 0) := (others => '0');
    signal reg_data_in   : std_logic_vector(31 downto 0) := (others => '0');
    signal cs_data_in    : std_logic_vector(63 downto 0) := (others => '0');

    --Outputs
    signal settings_out  : std_logic_vector(31 downto 0);
    signal threshold_out : std_logic_vector(31 downto 0);
    signal slottime_out  : std_logic_vector(17 downto 0);
    signal backoffs_out  : std_logic_vector(44 downto 0);
    signal difs_out      : std_logic_vector(19 downto 0);
    signal readback_out  : std_logic_vector(31 downto 0);

    -- Clock period definitions
    constant clk_period  : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: settings_ctrl
        GENERIC MAP(10,11,12)
        PORT MAP (
            clk           => clk,
            rst           => rst,
            reg_strobe_in => reg_strobe_in,
            reg_addr_in   => reg_addr_in,
            reg_data_in   => reg_data_in,
            cs_data_in    => cs_data_in,
            settings_out  => settings_out,
            threshold_out => threshold_out,
            slottime_out  => slottime_out,
            backoffs_out  => backoffs_out,
            difs_out      => difs_out,
            readback_out  => readback_out
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

        reg_addr_in <= "00001010";
        reg_data_in <= "00000000000010100000010000000010";

        reg_strobe_in <= '1';
        wait for clk_period;
        reg_strobe_in <= '0';

        wait for clk_period;

        reg_addr_in <= "00001100";
        reg_data_in <= "00000000000000000000000000001010";

        reg_strobe_in <= '1';
        wait for clk_period;
        reg_strobe_in <= '0';

        wait for clk_period;

        cs_data_in <= "0000000000000001000000100000000010000000010000000100000010000010";

        wait;
    end process;

END;
