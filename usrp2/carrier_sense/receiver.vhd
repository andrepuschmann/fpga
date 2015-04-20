----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    15:55:01 01/28/2013
-- Design Name:
-- Module Name:    receiver - Behavioral
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
use IEEE.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity receiver is
    Port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        sample_in       : in  std_logic_vector(31 downto 0);
        strobe_in       : in  std_logic;
        threshold_in    : in  std_logic_vector(31 downto 0);
        free_out        : out std_logic;
        avg_rssi_out    : out std_logic_vector(31 downto 0);
        rssi_out        : out std_logic_vector(31 downto 0);
        agc_out         : out std_logic_vector( 6 downto 0));
end receiver;

architecture Behavioral of receiver is

    component rssi is
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;
        sample_in  : in  std_logic_vector(31 downto 0);
        strobe_in  : in  std_logic;
        rssi_out   : out std_logic_vector(31 downto 0);
        strobe_out : out std_logic);
    end component;

    component autocorrelator is
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;
        sample_in  : in  std_logic_vector(31 downto 0);
        strobe_in  : in  std_logic;
        cor_out    : out std_logic_vector(31 downto 0);
        strobe_out : out std_logic);
    end component;

    component agc is
    port(
        clk             : in  std_logic;
        rst             : in  std_logic;
        cor_in          : in  std_logic_vector(31 downto 0);
        cor_strobe_in   : in  std_logic;
        power_in        : in  std_logic_vector(31 downto 0);
        power_strobe_in : in  std_logic;
        agc_out         : out std_logic_vector(6 downto 0));
    end component;

    component divider is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        sample1_in  : in  std_logic_vector(31 downto 0);
        sample2_in  : in  std_logic_vector(31 downto 0);
        strobe1_in  : in  std_logic;
        strobe2_in  : in  std_logic;
        cor_out     : out std_logic_vector(31 downto 0);
        strobe_out  : out std_logic);
    end component;

    component moving_avg is
    generic(DEPTH : integer);
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        strobe_in   : in  std_logic;
        data_in     : in  std_logic_vector(31 downto 0);
        strobe_out  : out std_logic;
        avg_out     : out std_logic_vector(31 downto 0));
    end component;

    component compare is
    port(
        clk          : in  std_logic;
        rst          : in  std_logic;
        strobe_in    : in  std_logic;
        avg_in       : in  std_logic_vector(31 downto 0);
        threshold_in : in  std_logic_vector(31 downto 0);
        free_out     : out std_logic);
    end component;

    signal avg_rssi_strobe_in       : std_logic := '0';
    signal compare_strobe_in        : std_logic := '0';
    signal agc_strobe_in            : std_logic := '0';
    signal divider_strobe_in_cor    : std_logic := '0';
    signal divider_strobe_in_power  : std_logic := '0';
    signal avg_cor_strobe_in        : std_logic := '0';


    signal rssi_val           : std_logic_vector(31 downto 0) := (others => '1');
    signal avg_rssi           : std_logic_vector(31 downto 0) := (others => '1');
    signal agc_cor_in         : std_logic_vector(31 downto 0) := (others => '1');
    signal divider_cor_in     : std_logic_vector(31 downto 0) := (others => '1');
    signal divider_power_in   : std_logic_vector(31 downto 0) := (others => '1');
    signal avg_cor_in         : std_logic_vector(31 downto 0) := (others => '1');


begin

    avg_rssi_out     <= avg_rssi;
    rssi_out         <= rssi_val;

    rssi0 : rssi
    port map(
        clk          => clk,
        rst          => rst,
        sample_in    => sample_in,
        strobe_in    => strobe_in,
        rssi_out     => rssi_val,
        strobe_out   => avg_rssi_strobe_in);

    -- csma
    avg_rssi0 : moving_avg
    generic map(3)
    port map(
        clk          => clk,
        rst          => rst,
        strobe_in    => avg_rssi_strobe_in,
        data_in      => rssi_val,
        strobe_out   => compare_strobe_in,
        avg_out      => avg_rssi);


    cmp0 : compare
    port map(
        clk          => clk,
        rst          => rst,
        strobe_in    => compare_strobe_in,
        avg_in       => avg_rssi,
        threshold_in => threshold_in,
        free_out     => free_out);

    -- agc
    avg_power0 : moving_avg
    generic map(5)
    port map(
        clk          => clk,
        rst          => rst,
        strobe_in    => avg_rssi_strobe_in,
        data_in      => rssi_val,
        strobe_out   => divider_strobe_in_power,
        avg_out      => divider_power_in);

    cor0 : autocorrelator
    port map(
        clk          => clk,
        rst          => rst,
        sample_in    => sample_in,
        strobe_in    => strobe_in,
        cor_out      => avg_cor_in,
        strobe_out   => avg_cor_strobe_in);

    avg_cor0 : moving_avg
    generic map(5)
    port map(
        clk          => clk,
        rst          => rst,
        strobe_in    => avg_cor_strobe_in,
        data_in      => avg_cor_in,
        strobe_out   => divider_strobe_in_cor,
        avg_out      => divider_cor_in);

    divider0: divider
    port map(
        clk          => clk,
        rst          => rst,
        sample1_in   => divider_cor_in,
        sample2_in   => divider_power_in,
        strobe1_in   => divider_strobe_in_cor,
        strobe2_in   => divider_strobe_in_power,
        cor_out      => agc_cor_in,
        strobe_out   => agc_strobe_in);

    agc0 : agc
    port map(
        clk             => clk,
        rst             => rst,
        cor_in          => agc_cor_in,
        cor_strobe_in   => agc_strobe_in,
        power_in        => divider_power_in,
        power_strobe_in => divider_strobe_in_power, 
        agc_out         => agc_out);

end Behavioral;

