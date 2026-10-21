library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Tugas 1: ditambah fase ALL-RED (kedua arah merah) setelah tiap fase kuning
-- Urutan: NS_HIJAU -> NS_KUNING -> ALL_RED_1 -> EW_HIJAU -> EW_KUNING -> ALL_RED_2 -> ...
entity traffic_light_fsm is
    Generic ( T_HIJAU  : integer := 10;
              T_KUNING : integer := 3;
              T_ALLRED : integer := 1 );
    Port ( clk  : in  STD_LOGIC;
           rst  : in  STD_LOGIC;
           tick : in  STD_LOGIC;
           led  : out STD_LOGIC_VECTOR(5 downto 0) );
end traffic_light_fsm;

architecture Behavioral of traffic_light_fsm is
    type state_t is (NS_HIJAU, NS_KUNING, ALL_RED_1, EW_HIJAU, EW_KUNING, ALL_RED_2);
    signal state_reg, state_next : state_t := NS_HIJAU;
    signal timer_reg, timer_next : unsigned(4 downto 0) := to_unsigned(T_HIJAU-1, 5);
begin
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

    comb : process(state_reg, timer_reg, tick)
    begin
        state_next <= state_reg;
        timer_next <= timer_reg;

        if tick = '1' then
            if timer_reg = 0 then
                case state_reg is
                    when NS_HIJAU   => state_next <= NS_KUNING;
                                       timer_next <= to_unsigned(T_KUNING-1, 5);
                    when NS_KUNING  => state_next <= ALL_RED_1;
                                       timer_next <= to_unsigned(T_ALLRED-1, 5);
                    when ALL_RED_1  => state_next <= EW_HIJAU;
                                       timer_next <= to_unsigned(T_HIJAU-1, 5);
                    when EW_HIJAU   => state_next <= EW_KUNING;
                                       timer_next <= to_unsigned(T_KUNING-1, 5);
                    when EW_KUNING  => state_next <= ALL_RED_2;
                                       timer_next <= to_unsigned(T_ALLRED-1, 5);
                    when ALL_RED_2  => state_next <= NS_HIJAU;
                                       timer_next <= to_unsigned(T_HIJAU-1, 5);
                end case;
            else
                timer_next <= timer_reg - 1;
            end if;
        end if;

        case state_reg is
            when NS_HIJAU  => led <= "100" & "001";
            when NS_KUNING => led <= "100" & "010";
            when ALL_RED_1 => led <= "100" & "100";
            when EW_HIJAU  => led <= "001" & "100";
            when EW_KUNING => led <= "010" & "100";
            when ALL_RED_2 => led <= "100" & "100";
        end case;
    end process;
end Behavioral;
