library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Tugas 2: durasi hijau = 5 + sw (detik), sw = 0..15  ->  5..20 detik
-- Nilai sw dibaca saat fase hijau DIMULAI (perubahan sw di tengah fase berlaku di fase hijau berikutnya)
entity traffic_light_fsm is
    Generic ( T_KUNING : integer := 3;
              T_ALLRED : integer := 1 );
    Port ( clk  : in  STD_LOGIC;
           rst  : in  STD_LOGIC;
           tick : in  STD_LOGIC;
           sw   : in  STD_LOGIC_VECTOR(3 downto 0);
           led  : out STD_LOGIC_VECTOR(5 downto 0) );
end traffic_light_fsm;

architecture Behavioral of traffic_light_fsm is
    type state_t is (NS_HIJAU, NS_KUNING, ALL_RED_1, EW_HIJAU, EW_KUNING, ALL_RED_2);
    signal state_reg, state_next : state_t := NS_HIJAU;
    signal timer_reg, timer_next : unsigned(4 downto 0) := to_unsigned(4, 5);
    signal t_hijau_load : unsigned(4 downto 0);   -- (5 + sw) - 1 = sw + 4
begin
    t_hijau_load <= resize(unsigned(sw), 5) + 4;

    seq : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_reg <= NS_HIJAU;
                timer_reg <= t_hijau_load;
            else
                state_reg <= state_next;
                timer_reg <= timer_next;
            end if;
        end if;
    end process;

    comb : process(state_reg, timer_reg, tick, t_hijau_load)
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
                                       timer_next <= t_hijau_load;
                    when EW_HIJAU   => state_next <= EW_KUNING;
                                       timer_next <= to_unsigned(T_KUNING-1, 5);
                    when EW_KUNING  => state_next <= ALL_RED_2;
                                       timer_next <= to_unsigned(T_ALLRED-1, 5);
                    when ALL_RED_2  => state_next <= NS_HIJAU;
                                       timer_next <= t_hijau_load;
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
