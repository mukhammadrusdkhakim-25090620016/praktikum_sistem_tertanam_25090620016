library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_tick_1hz is
end tb_tick_1hz;

architecture sim of tb_tick_1hz is
    constant CLK_PERIOD : time    := 10 ns;
    constant N          : integer := 10;     -- CLK_FREQ_HZ dikecilkan agar simulasi cepat

    signal clk  : std_logic := '0';
    signal rst  : std_logic := '1';
    signal tick : std_logic;
begin
    uut : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => N )
        port map ( clk => clk, rst => rst, tick => tick );

    clk <= not clk after CLK_PERIOD/2;

    stim : process
    begin
        rst <= '1';
        wait for 3*CLK_PERIOD;
        rst <= '0';
        wait;
    end process;

    -- Cek: jarak antar pulsa tick harus tepat N siklus clock
    check : process
        variable t_last : time;
    begin
        wait until rising_edge(tick);
        t_last := now;
        for i in 1 to 5 loop
            wait until rising_edge(tick);
            assert (now - t_last) = N*CLK_PERIOD
                report "Periode tick SALAH" severity error;
            t_last := now;
        end loop;
        report "OK: periode tick = N siklus clock" severity note;
        wait;
    end process;
end sim;
