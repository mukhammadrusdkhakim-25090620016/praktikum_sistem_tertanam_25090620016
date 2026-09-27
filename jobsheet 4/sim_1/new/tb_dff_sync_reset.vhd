library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_dff_sync_reset is
-- Testbench tidak memiliki port external
end tb_dff_sync_reset;

architecture Behavioral of tb_dff_sync_reset is
    component dff_sync_reset
        Port (
            clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
            d   : in  STD_LOGIC;
            q   : out STD_LOGIC
        );
    end component;

    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal d   : STD_LOGIC := '0';
    signal q   : STD_LOGIC;

    constant CLK_PERIOD : time := 20 ns;

begin
    uut: dff_sync_reset
        port map (
            clk => clk,
            rst => rst,
            d   => d,
            q   => q
        );

    -- Pembangkit sinyal clock 50 MHz (periode 20 ns)
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus sinyal input
    stim_proc: process
    begin
        -- Kondisi awal: aktifkan reset
        rst <= '1';
        wait for 40 ns;
        
        -- Matikan reset dan ubah data d
        rst <= '0';
        d   <= '1';
        wait for 20 ns;
        
        d   <= '0';
        wait for 20 ns;
        
        -- Eksperimen: ubah d di tengah-tengah siklus clock
        wait for 7 ns;
        d   <= '1';
        wait for 33 ns;
        
        -- Uji reset sinkron saat d bernilai '1'
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        wait;
    end process;
end Behavioral;