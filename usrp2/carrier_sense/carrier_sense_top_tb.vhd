--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   15:53:27 04/25/2013
-- Design Name:
-- Module Name:   C:/Users/ts/Documents/fpga/usrp2/carrier_sense/carrier_sense_top_tb.vhd
-- Project Name:  u2plus
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: carrier_sense_top
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
USE ieee.numeric_std.ALL;

ENTITY carrier_sense_top_tb IS
END carrier_sense_top_tb;

ARCHITECTURE behavior OF carrier_sense_top_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT carrier_sense_top
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
        new_sample_in  : IN  std_logic;
        sample_in      : IN  std_logic_vector(31 downto 0);
        strobe_in      : IN  std_logic;
        cs_ena_in      : IN  std_logic;
        cs_data_in     : IN  std_logic_vector(63 downto 0);
        send_out       : OUT std_logic;
        readback_out   : OUT std_logic_vector(31 downto 0);
        settings_out   : OUT std_logic_vector(31 downto 0);
        status_out     : OUT std_logic_vector(31 downto 0);
        debug          : OUT std_logic_vector(95 downto 0)
    );
    END COMPONENT;


    --Inputs
    signal clk           : std_logic := '0';
    signal rst           : std_logic := '0';
    signal reg_strobe_in : std_logic := '0';
    signal reg_addr_in   : std_logic_vector( 7 downto 0) := (others => '0');
    signal reg_data_in   : std_logic_vector(31 downto 0) := (others => '0');
    signal new_sample_in : std_logic := '0';
    signal sample_in     : std_logic_vector(31 downto 0) := (others => '0');
    signal strobe_in     : std_logic := '0';
    signal cs_ena_in     : std_logic := '0';
    signal cs_data_in    : std_logic_vector(63 downto 0) := (others => '0');

    --Outputs
    signal send_out      : std_logic;
    signal readback_out  : std_logic_vector(31 downto 0);
    signal settings_out  : std_logic_vector(31 downto 0);
    signal status_out    : std_logic_vector(31 downto 0);
    signal debug         : std_logic_vector(95 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;

BEGIN
   -- Instantiate the Unit Under Test (UUT)
   uut: carrier_sense_top
    GENERIC MAP(
        10,
        11,
        12)
    PORT MAP(
        clk           => clk,
        rst           => rst,
        reg_strobe_in => reg_strobe_in,
        reg_addr_in   => reg_addr_in,
        reg_data_in   => reg_data_in,
        new_sample_in => new_sample_in,
        sample_in     => sample_in,
        strobe_in     => strobe_in,
        cs_ena_in     => cs_ena_in,
        cs_data_in    => cs_data_in,
        send_out      => send_out,
        readback_out  => readback_out,
        settings_out  => settings_out,
        status_out    => status_out,
        debug         => debug
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
        reg_data_in <= "00000000000000000000000100000001";
        reg_addr_in <= "00001010";

        reg_strobe_in <= '1';

        wait for clk_period;

        reg_addr_in <= "00001011";
        reg_data_in <= std_logic_vector(to_unsigned(100000000,32));

        wait for clk_period;

        reg_addr_in <= "00001100";
        reg_data_in <= std_logic_vector(to_unsigned(10,32));

        wait for clk_period;
        reg_strobe_in <= '0';

        wait for clk_period;

        cs_data_in <= "0000000000000001010000000011000000010100000100000001100001000001";

        wait for clk_period;

        new_sample_in <= '1';
        cs_ena_in <= '1';

        wait;
    end process;

    process
    begin
        wait for clk_period/2;
        sample_in <= "00011011010110000001101101011000";
        strobe_in <= '1';
        wait for clk_period;
        strobe_in <= '0';

        wait for clk_period;

        sample_in <= "00010011100010000010000110011000";
        strobe_in <= '1';
        wait for clk_period;
        strobe_in <= '0';

        wait for clk_period;

        sample_in <= "00100001100110000001001110001000";
        strobe_in <= '1';
        wait for clk_period;
        strobe_in <= '0';

        wait for clk_period;

        sample_in <= "00001001110001000010010110000000";
        strobe_in <= '1';
        wait for clk_period;
        strobe_in <= '0';

        wait for clk_period;

        sample_in <= "00100101100000000000100111000100";
        strobe_in <= '1';
        wait for clk_period;
        strobe_in <= '0';

        wait for clk_period/2;
    end process;

END;
