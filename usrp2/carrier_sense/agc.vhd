library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity agc is
    port (
        clk              : in  std_logic;
        rst              : in  std_logic;
        cor_in           : in  std_logic_vector(31 downto 0);
        cor_strobe_in    : in  std_logic;
        power_in         : in  std_logic_vector(31 downto 0);
        power_strobe_in  : in  std_logic;
        agc_out          : out std_logic_vector( 6 downto 0));
end agc;

architecture Behavioral of agc is

    signal delay : integer range 0 to 50000 := 0;
    signal a     : std_logic_vector(6 downto 0);

begin

    -- TODO: remove power strobe in

    agc_out(0) <= a(6);
    agc_out(1) <= a(5);
    agc_out(2) <= a(4);
    agc_out(3) <= a(3);
    agc_out(4) <= a(2);
    agc_out(5) <= a(1);
    agc_out(6) <= a(0);

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                delay   <= 0;
                a       <= (a'length - 1 downto 0 => '0');
            elsif delay > 0 then
                delay   <= delay - 1;
            --elsif (cor_strobe_in = '1' and unsigned(cor_in) > 25) then
            elsif ((cor_strobe_in = '1' and unsigned(cor_in) > 25) or (power_strobe_in = '1' and signed(power_in) > 41744000)) then
				
				
				
if signed(power_in) >  1661880964  then
     a <= std_logic_vector(to_unsigned( 4 , 7));
elsif signed(power_in) >  1048576000  then
     a <= std_logic_vector(to_unsigned( 5 , 7));
elsif signed(power_in) >  661606728  then
     a <= std_logic_vector(to_unsigned( 6 , 7));
elsif signed(power_in) >  417445624  then
     a <= std_logic_vector(to_unsigned( 7 , 7));
elsif signed(power_in) >  263390383  then
     a <= std_logic_vector(to_unsigned( 64 , 7));
elsif signed(power_in) >  166188096  then
     a <= std_logic_vector(to_unsigned( 65 , 7));
elsif signed(power_in) >  104857600  then
     a <= std_logic_vector(to_unsigned( 66 , 7));
elsif signed(power_in) >  66160673  then
     a <= std_logic_vector(to_unsigned( 67 , 7));
elsif signed(power_in) >  41744562  then
     a <= std_logic_vector(to_unsigned( 68 , 7));
elsif signed(power_in) >  26339038  then
     a <= std_logic_vector(to_unsigned( 69 , 7));
elsif signed(power_in) >  16618810  then
     a <= std_logic_vector(to_unsigned( 70 , 7));
elsif signed(power_in) >  10485760  then
     a <= std_logic_vector(to_unsigned( 96 , 7));
elsif signed(power_in) >  6616067  then
     a <= std_logic_vector(to_unsigned( 97 , 7));
elsif signed(power_in) >  4174456  then
     a <= std_logic_vector(to_unsigned( 98 , 7));
elsif signed(power_in) >  2633904  then
     a <= std_logic_vector(to_unsigned( 99 , 7));
elsif signed(power_in) >  1661881  then
     a <= std_logic_vector(to_unsigned( 100 , 7));
elsif signed(power_in) >  1048576  then
     a <= std_logic_vector(to_unsigned( 104 , 7));
elsif signed(power_in) >  661607  then
     a <= std_logic_vector(to_unsigned( 105 , 7));
elsif signed(power_in) >  417446  then
     a <= std_logic_vector(to_unsigned( 106 , 7));
elsif signed(power_in) >  263390  then
     a <= std_logic_vector(to_unsigned( 107 , 7));
elsif signed(power_in) >  166188  then
     a <= std_logic_vector(to_unsigned( 108 , 7));
elsif signed(power_in) >  104858  then
     a <= std_logic_vector(to_unsigned( 109 , 7));
elsif signed(power_in) >  66161  then
     a <= std_logic_vector(to_unsigned( 110 , 7));
elsif signed(power_in) >  41745  then
     a <= std_logic_vector(to_unsigned( 111 , 7));
elsif signed(power_in) >  26339  then
     a <= std_logic_vector(to_unsigned( 112 , 7));
elsif signed(power_in) >  16619  then
     a <= std_logic_vector(to_unsigned( 113 , 7));
elsif signed(power_in) >  10486  then
     a <= std_logic_vector(to_unsigned( 114 , 7));
elsif signed(power_in) >  6616  then
     a <= std_logic_vector(to_unsigned( 115 , 7));
elsif signed(power_in) >  4174  then
     a <= std_logic_vector(to_unsigned( 116 , 7));
elsif signed(power_in) >  2634  then
     a <= std_logic_vector(to_unsigned( 117 , 7));
elsif signed(power_in) >  1662  then
     a <= std_logic_vector(to_unsigned( 118 , 7));
elsif signed(power_in) >  1049  then
     a <= std_logic_vector(to_unsigned( 119 , 7));
elsif signed(power_in) >  662  then
     a <= std_logic_vector(to_unsigned( 120 , 7));
elsif signed(power_in) >  417  then
     a <= std_logic_vector(to_unsigned( 121 , 7));
elsif signed(power_in) >  263  then
     a <= std_logic_vector(to_unsigned( 122 , 7));
elsif signed(power_in) >  166  then
     a <= std_logic_vector(to_unsigned( 123 , 7));
elsif signed(power_in) >  105  then
     a <= std_logic_vector(to_unsigned( 124 , 7));
elsif signed(power_in) >  66  then
     a <= std_logic_vector(to_unsigned( 125 , 7));
elsif signed(power_in) >  42  then
     a <= std_logic_vector(to_unsigned( 126 , 7));
else
     a <= std_logic_vector(to_unsigned( 127 , 7));
end if;

                delay <= 50000; -- 50 symbols * 80 samples * 10 for clock

            -- if no frame default power
            else
                a     <= "1101000";
            end if;
        end if;
    end process;

end Behavioral;

