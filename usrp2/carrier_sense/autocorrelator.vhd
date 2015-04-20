library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity autocorrelator is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        sample_in  : in  std_logic_vector(31 downto 0);
        strobe_in  : in  std_logic;
        cor_out    : out std_logic_vector(31 downto 0);
        strobe_out : out std_logic);
end autocorrelator;

architecture Behavioral of autocorrelator is
    component myfifo is
        generic(
            depth : integer);
        port(
            clk    : in  std_logic;
            rst    : in  std_logic;
            stb_in : in  std_logic;
            d_in   : in  std_logic_vector(31 downto 0);
            d_out  : out std_logic_vector(31 downto 0));
    end component;

    signal old_val       : std_logic_vector(31 downto 0) := (others => '0');
    signal ac, bd        : std_logic_vector(31 downto 0) := (others => '0');
    signal cor           : std_logic_vector(31 downto 0) := (others => '0');
    signal stb, strobe   : std_logic := '0';
begin

    strobe_out <= stb;
    cor_out    <= cor;

    f : myfifo
    generic map(4)
    port map(
        clk    => clk,
        rst    => rst,
        stb_in => strobe_in,
        d_in   => sample_in,
        d_out  => old_val);

    -- this does not account for frequency offset but just considers real part of autocorrelation
    process(clk,rst)
    begin
        if rst = '1' then
            stb    <= '0';
            strobe <= '0';
            cor    <= (others => '0');
        elsif rising_edge(clk) then
            if strobe_in = '1' then
                ac       <= std_logic_vector((signed(sample_in(31 downto 16))*signed(old_val(31 downto 16))));
                bd       <= std_logic_vector((signed(sample_in(15 downto  0))*signed(old_val(15 downto  0))));
                stb      <= '0';
                strobe   <= '1';
             else
                cor      <= std_logic_vector(signed(ac) + signed(bd));
                stb      <= strobe;
                strobe   <= '0';
             end if;
        end if;
    end process;

end Behavioral;

