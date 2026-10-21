library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_traffic_light_fsm is
end tb_traffic_light_fsm;

architecture sim of tb_traffic_light_fsm is
    constant CLK_PERIOD : time := 10 ns;

    signal clk  : std_logic := '0';
    signal rst  : std_logic := '1';
    signal tick : std_logic := '0';
    signal sw   : std_logic_vector(3 downto 0) := "0000";
    signal led  : std_logic_vector(5 downto 0);
begin
    uut : entity work.traffic_light_fsm
        port map ( clk => clk, rst => rst, tick => tick, sw => sw, led => led );

    clk <= not clk after CLK_PERIOD/2;
    rst <= '1', '0' after 2*CLK_PERIOD;

    -- sw diubah di tengah simulasi
    sw <= "0000", "1111" after 500 ns;

    -- tick dipercepat: 1 pulsa tiap 4 siklus clock
    tick_gen : process
    begin
        tick <= '0';
        loop
            for i in 1 to 3 loop
                wait until rising_edge(clk);
            end loop;
            tick <= '1';
            wait until rising_edge(clk);
            tick <= '0';
        end loop;
    end process;

    -- pemeriksa kondisi eksklusif
    check : process(clk)
    begin
        if falling_edge(clk) then
            assert (led(2 downto 0) = "001" or led(2 downto 0) = "010" or led(2 downto 0) = "100")
                report "NS: bukan tepat 1 LED menyala" severity error;
            assert (led(5 downto 3) = "001" or led(5 downto 3) = "010" or led(5 downto 3) = "100")
                report "EW: bukan tepat 1 LED menyala" severity error;
            assert not (led(0) = '1' and led(3) = '1')
                report "KEDUA ARAH HIJAU!" severity error;
        end if;
    end process;
end sim;
