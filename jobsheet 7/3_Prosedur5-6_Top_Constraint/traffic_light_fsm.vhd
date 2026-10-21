library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- led(2 downto 0) = Utara-Selatan : bit0 hijau, bit1 kuning, bit2 merah
-- led(5 downto 3) = Timur-Barat   : bit3 hijau, bit4 kuning, bit5 merah
entity traffic_light_fsm is
    Generic ( T_HIJAU  : integer := 10;   -- detik
              T_KUNING : integer := 3 );  -- detik
    Port ( clk  : in  STD_LOGIC;
           rst  : in  STD_LOGIC;
           tick : in  STD_LOGIC;          -- pulsa 1 Hz
           led  : out STD_LOGIC_VECTOR(5 downto 0) );
end traffic_light_fsm;

architecture Behavioral of traffic_light_fsm is
    type state_t is (NS_HIJAU, NS_KUNING, EW_HIJAU, EW_KUNING);
    signal state_reg, state_next : state_t := NS_HIJAU;
    signal timer_reg, timer_next : unsigned(4 downto 0) := to_unsigned(T_HIJAU-1, 5);
begin
    -- Proses 1: register (sekuensial)
    seq : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_reg <= NS_HIJAU;
                timer_reg <= to_unsigned(T_HIJAU-1, 5);
            else
                state_reg <= state_next;
                timer_reg <= timer_next;
            end if;
        end if;
    end process;

    -- Proses 2: next-state, timer, dan keluaran (kombinasional)
    comb : process(state_reg, timer_reg, tick)
    begin
        state_next <= state_reg;
        timer_next <= timer_reg;

        if tick = '1' then
            if timer_reg = 0 then
                case state_reg is
                    when NS_HIJAU  => state_next <= NS_KUNING;
                                      timer_next <= to_unsigned(T_KUNING-1, 5);
                    when NS_KUNING => state_next <= EW_HIJAU;
                                      timer_next <= to_unsigned(T_HIJAU-1, 5);
                    when EW_HIJAU  => state_next <= EW_KUNING;
                                      timer_next <= to_unsigned(T_KUNING-1, 5);
                    when EW_KUNING => state_next <= NS_HIJAU;
                                      timer_next <= to_unsigned(T_HIJAU-1, 5);
                end case;
            else
                timer_next <= timer_reg - 1;
            end if;
        end if;

        -- keluaran (Moore): tepat 1 LED aktif per arah
        case state_reg is
            when NS_HIJAU  => led <= "100" & "001";  -- EW merah, NS hijau
            when NS_KUNING => led <= "100" & "010";  -- EW merah, NS kuning
            when EW_HIJAU  => led <= "001" & "100";  -- EW hijau, NS merah
            when EW_KUNING => led <= "010" & "100";  -- EW kuning, NS merah
        end case;
    end process;
end Behavioral;
