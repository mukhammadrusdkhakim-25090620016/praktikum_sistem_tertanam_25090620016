library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debounce is
end tb_debounce;

architecture Behavioral of tb_debounce is

    component debounce
        Generic (
            CLK_FREQ_HZ : integer := 100_000_000;
            STABLE_MS   : integer := 10
        );
        Port (
            clk     : in  STD_LOGIC;
            btn_in  : in  STD_LOGIC;
            btn_out : out STD_LOGIC
        );
    end component;

    signal clk     : STD_LOGIC := '0';
    signal btn_in  : STD_LOGIC := '0';
    signal btn_out : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: debounce
        generic map (
            CLK_FREQ_HZ => 10_000, 
            STABLE_MS   => 1      
        )
        port map (
            clk     => clk,
            btn_in  => btn_in,
            btn_out => btn_out
        );

    -- Clock 100 MHz (Periode 10 ns)
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus sesuai Prosedur Praktikum (Sinyal Masukan Berisik)
    stim_proc: process
    begin
        wait for 50 ns;
        
        -- Transisi cepat 0/1 (Bouncing awal)
        btn_in <= '1'; wait for 20 ns;
        btn_in <= '0'; wait for 20 ns;
        btn_in <= '1'; wait for 20 ns;
        btn_in <= '0'; wait for 20 ns;
        
        -- Ditekan dan ditahan stabil (Selama 500 ns)
        -- Karena > 100 ns, btn_out akan merespon naik ke '1'
        btn_in <= '1';
        wait for 500 ns;

        -- Transisi cepat (Bouncing saat dilepas)
        btn_in <= '0'; wait for 20 ns;
        btn_in <= '1'; wait for 20 ns;
        btn_in <= '0';
        
        wait;
    end process;

end Behavioral;