----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    17:45:00 01/30/2013
-- Design Name:
-- Module Name:    carrier_sense_ctrl - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity carrier_sense_ctrl is
    Port(
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
end carrier_sense_ctrl;

architecture Behavioral of carrier_sense_ctrl is

    type   state_type is (CS_IDLE, CS_DIFS_GO, CS_DIFS, CS_SLOT, CS_SEND, CS_SENDING);
    
    signal state                  : state_type := CS_IDLE;
    signal send                   : std_logic := '0';
    signal dbg_run                : std_logic := '0';
    signal dbg_ready              : std_logic := '0';
    signal dbg_error              : std_logic := '0';
    signal dbg_state              : std_logic_vector( 3 downto 0) := (others => '0');

    signal tick_counter           : integer := 0;
    signal slot_counter           : integer := 0;

    constant STATE_IDLE           : std_logic_vector( 3 downto 0) := "0000";
    constant STATE_DIFS           : std_logic_vector( 3 downto 0) := "0001";
    constant STATE_SENDING        : std_logic_vector( 3 downto 0) := "0010";
    constant STATE_SLOT           : std_logic_vector( 3 downto 0) := "0011";
    constant STATE_SEND           : std_logic_vector( 3 downto 0) := "0100";
    constant STATE_DIFS_GO        : std_logic_vector( 3 downto 0) := "0101";


begin

    --          15..14 13..12     11       10..8    7         6        5..2         1          0
    debug     <= "00" & "00" & dbg_ready & "000" & free_in & ena_in & dbg_state & dbg_error & dbg_run;
    send_out  <= send or not ena_in;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                tick_counter  <= 0;
                slot_counter  <= 0;
                state         <= CS_IDLE;
                send          <= '0';

                dbg_state     <= STATE_IDLE;
            elsif ena_in = '0' then
                state         <= CS_IDLE;
            else

                case state is

                ------------------------------------------------------------
                -- IDLE STATE ----------------------------------------------
                when CS_IDLE =>
                    dbg_state <= STATE_IDLE;

                    -- If CS Mechanism enabled and new Sample to send -> -
                    -- check if Channel free -----------------------------
                    if new_sample_in = '1' and ena_in = '1' then
                        dbg_ready      <= '0';
                        state          <= CS_DIFS_GO;
                        tick_counter   <= 0;
                    end if;

                ------------------------------------------------------------
                -- DIFS_GO STATE ----------------------------------------------
                when CS_DIFS_GO =>
                    dbg_state <= STATE_DIFS_GO;

                    slot_counter <= to_integer(unsigned(backoffs_in(4 downto 0)));

                    -- channel was free for DIFS
                    if tick_counter >= to_integer(unsigned(difs_in)) then
                        tick_counter <= 0;
                        state   <= CS_SEND;

                    -- channel free
                    elsif free_in = '1' then
                        tick_counter <= tick_counter + 1;

                    -- channel busy
                    else
                        tick_counter <= 0;
                        state <= CS_DIFS;
                    end if;

                ------------------------------------------------------------
                -- DIFS STATE ----------------------------------------------
                    when CS_DIFS =>
                        dbg_state <= STATE_DIFS;

                        -- channel was free for DIFS
                        if tick_counter >= to_integer(unsigned(difs_in)) then
                            tick_counter <= 0;
                            state   <= CS_SLOT;

                        -- channel free
                        elsif free_in = '1' then
                            tick_counter <= tick_counter + 1;

                        -- channel busy
                        else
                            tick_counter <= 0;
                        end if;

                ------------------------------------------------------------
                -- SLOT STATE -------------------------------------------
                    when CS_SLOT =>
                        dbg_state <= STATE_SLOT;

                        -- channel was free for DIFS
                        if tick_counter >= to_integer(unsigned(slottime_in)) then
                            tick_counter <= 0;
                            slot_counter <= slot_counter - 1;

                        elsif slot_counter = 0 then
                            if new_sample_in = '1' then
                                state <= CS_SEND;
                            else
                                state <= CS_IDLE;
                            end if;

                        -- channel free
                        elsif free_in = '1' then
                            tick_counter <= tick_counter + 1;

                        -- channel busy
                        else
                            tick_counter <= 0;
                            state        <= CS_DIFS;
                        end if;

                ------------------------------------------------------------
                -- SEND STATE ----------------------------------------------
                    when CS_SEND =>
                        dbg_state    <= STATE_SEND;
                        send         <= '1';
                        slot_counter <= to_integer(unsigned(backoffs_in(10 downto 5)));
                        state        <= CS_SENDING;

                ------------------------------------------------------------
                -- SENDING STATE -------------------------------------------
                    when CS_SENDING =>
                        dbg_state    <= STATE_SENDING;
                        send         <= '0';

                        if eof_in = '1' then
                            state <= CS_DIFS;
                        end if;

                ------------------------------------------------------------
                -- ERROR should never reach this state ---------------------
                --    when others =>
                --        state <= CS_IDLE;
                --        dbg_error  <= '1';
                ------------------------------------------------------------
                end case;
            end if;
        end if;
    end process;

end Behavioral;

