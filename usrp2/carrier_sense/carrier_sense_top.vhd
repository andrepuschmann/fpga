----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    16:48:54 04/23/2013
-- Design Name:
-- Module Name:    carrier_sense_top - Behavioral
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

entity carrier_sense_top is
    Generic(
        settings_addr  : integer;
        threshold_addr : integer;
        slottime_addr  : integer);
    Port(
        clk            : in  std_logic;
        rst            : in  std_logic;

        -- Memory Interface
        reg_strobe_in  : in  std_logic;
        reg_addr_in    : in  std_logic_vector ( 7 downto 0);
        reg_data_in    : in  std_logic_vector (31 downto 0);

        -- Sample Input
        new_sample_in  : in  std_logic;
        sample_in      : in  std_logic_vector(31 downto 0);
        strobe_in      : in  std_logic;

        -- Metadata
        cs_ena_in      : in  std_logic;
        eof_in         : in  std_logic;
        cs_data_in     : in  std_logic_vector (63 downto 0);

        -- Send Signal for TX Controller
        send_out       : out std_logic;

        -- Status Signals
        readback_out   : out std_logic_vector(31 downto 0);
        settings_out   : out std_logic_vector(31 downto 0);
        status_out     : out std_logic_vector(31 downto 0);
        avg_rssi_out   : out std_logic_vector(31 downto 0);
        rssi_out       : out std_logic_vector(31 downto 0);

        -- AGC config
        agc_out        : out std_logic_vector( 6 downto 0);

        -- Debug Output
        debug          : out std_logic_vector(95 downto 0));
end carrier_sense_top;

architecture Behavioral of carrier_sense_top is

    component settings_ctrl is
    generic(
        settings_addr  : integer;
        threshold_addr : integer;
        slottime_addr  : integer);
    port(
        clk            : in  std_logic;
        rst            : in  std_logic;
        reg_strobe_in  : in  std_logic;
        reg_addr_in    : in  std_logic_vector( 7 downto 0);
        reg_data_in    : in  std_logic_vector(31 downto 0);
        cs_data_in     : in  std_logic_vector(63 downto 0);
        settings_out   : out std_logic_vector(31 downto 0);
        threshold_out  : out std_logic_vector(31 downto 0);
        slottime_out   : out std_logic_vector(17 downto 0);
        backoffs_out   : out std_logic_vector(44 downto 0);
        difs_out       : out std_logic_vector(19 downto 0);
        readback_out   : out std_logic_vector(31 downto 0));
    end component;

    component receiver is
    port(
        clk             : in  std_logic;
        rst             : in  std_logic;
        sample_in       : in  std_logic_vector(31 downto 0);
        strobe_in       : in  std_logic;
        threshold_in    : in  std_logic_vector(31 downto 0);
        free_out        : out std_logic;
        avg_rssi_out    : out std_logic_vector(31 downto 0);
        rssi_out        : out std_logic_vector(31 downto 0);
        agc_out         : out std_logic_vector( 6 downto 0));
    end component;

    component carrier_sense_ctrl is
    port(
        clk           : in  std_logic;
        rst           : in  std_logic;
        ena_in        : in  std_logic;
        eof_in        : in  std_logic;
        free_in       : in  std_logic;
        new_sample_in : in  std_logic;
        difs_in       : in  std_logic_vector(19 downto 0);
        slottime_in   : in  std_logic_vector(17 downto 0);
        backoffs_in   : in  std_logic_vector(44 downto 0);
        send_out      : out std_logic;
        debug         : out std_logic_vector(15 downto 0));
    end component;

    signal avg_rssi     : std_logic_vector(31 downto 0) := (others => '0');
    signal rssi         : std_logic_vector(31 downto 0) := (others => '0');
    signal threshold    : std_logic_vector(31 downto 0) := (others => '0');
    signal settings     : std_logic_vector(31 downto 0) := (others => '0');
    signal status       : std_logic_vector(31 downto 0) := (others => '0');
    signal slottime     : std_logic_vector(17 downto 0) := (others => '0');
    signal backoffs     : std_logic_vector(44 downto 0) := (others => '0');
    signal difs         : std_logic_vector(19 downto 0);
    signal free         : std_logic := '0';

begin

    debug        <= "00000000000000" & settings & threshold & slottime;
    settings_out <= settings;
    status_out   <= status;
    avg_rssi_out <= avg_rssi;
    rssi_out     <= rssi;

    set_ctrl : settings_ctrl
    generic map(
        settings_addr,
        threshold_addr,
        slottime_addr)
    port map(
        clk           => clk,
        rst           => rst,
        reg_strobe_in => reg_strobe_in,
        reg_addr_in   => reg_addr_in,
        reg_data_in   => reg_data_in,
        cs_data_in    => cs_data_in,
        settings_out  => settings,
        threshold_out => threshold,
        slottime_out  => slottime,
        backoffs_out  => backoffs,
        difs_out      => difs,
        readback_out  => readback_out);

    rec : receiver
    port map(
        clk             => clk,
        rst             => rst,
        sample_in       => sample_in,
        strobe_in       => strobe_in,
        threshold_in    => threshold,
        free_out        => free,
        avg_rssi_out    => avg_rssi,
        rssi_out        => rssi,
        agc_out         => agc_out);

    ctrl : carrier_sense_ctrl
    port map(
        clk             => clk,
        rst             => rst,
        ena_in          => cs_ena_in,
        eof_in          => eof_in,
        free_in         => free,
        new_sample_in   => new_sample_in,
        difs_in         => difs,
        slottime_in     => slottime,
        backoffs_in     => backoffs,
        send_out        => send_out,
        debug           => status(15 downto 0));

end Behavioral;
