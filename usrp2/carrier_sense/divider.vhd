library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity divider is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        sample1_in  : in  std_logic_vector(31 downto 0);
        sample2_in  : in  std_logic_vector(31 downto 0);
        strobe1_in  : in  std_logic;
        strobe2_in  : in  std_logic;
        cor_out     : out std_logic_vector(31 downto 0);
        strobe_out  : out std_logic);
end divider;

architecture Behavioral of divider is

    signal power       : std_logic_vector(31 downto 0) := (others => '0');
    signal cor         : std_logic_vector(31 downto 0) := (others => '0');
    signal temp_cor    : std_logic_vector(31 downto 0) := (others => '0');
    signal temp_power  : std_logic_vector(31 downto 0) := (others => '0');
    signal autocor     : std_logic_vector(31 downto 0) := (others => '0');
	 signal max_iter    : std_logic_vector( 5 downto 0) := (others => '0');
    signal recalc1     : std_logic := '0';
    signal recalc2     : std_logic := '0';
    signal strobe      : std_logic := '0';
    signal dividing    : std_logic := '0';

begin
    cor_out    <= autocor;
    strobe_out <= strobe;

    -- divide
    process(clk,rst)
    begin
        if rst = '1' then
            strobe      <= '0';
            dividing    <= '0';
            autocor     <= (others => '0');
            temp_cor    <= (others => '0');
            temp_power  <= (others => '0');
				max_iter    <= (others => '0');
        elsif rising_edge(clk) then
            if dividing = '1' then
                autocor      <= std_logic_vector(unsigned(autocor) + 1);
                temp_cor     <= std_logic_vector(signed(temp_cor) - signed(shift_right(signed(temp_power), 5) - 1));
					 max_iter     <= std_logic_vector(unsigned(max_iter) + 1);

                if (signed(temp_cor) < 0 or unsigned(max_iter) > 30) then
                    strobe   <= '1';
                    dividing <= '0';
                end if;

            elsif (recalc1 = '1' or recalc2 = '1') then
                temp_cor     <= cor;
                temp_power   <= power;
                dividing     <= '1';
                max_iter <= (others => '0');
                autocor      <= (31 downto 0 => '0');
            else
                strobe       <= '0';
             end if;
        end if;
    end process;

    -- store cor
    process(clk,rst)
    begin
        if rst = '1' then
            cor  <= (31 downto 0 => '0');
        elsif rising_edge(clk) then
            if strobe1_in = '1' then
                cor <= sample1_in;
                recalc1 <= '1';
            else
                recalc1 <= '0';
            end if;
        end if;
    end process;

    -- store power
    process(clk,rst)
    begin
        if rst = '1' then
            power  <= (31 downto 0 => '0');
        elsif rising_edge(clk) then
            if strobe2_in = '1' then
                power <= sample2_in;
                recalc2 <= '1';
            else
                recalc2 <= '0';
            end if;
        end if;
    end process;

end Behavioral;

