library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js05_top is
    Port (
        clk  : in  STD_LOGIC;
        btnU : in  STD_LOGIC;
        btnD : in  STD_LOGIC;
        btnC : in  STD_LOGIC;
        sw0  : in  STD_LOGIC; -- Switch 0 untuk Freeze / Pause
        seg  : out STD_LOGIC_VECTOR (6 downto 0);
        dp   : out STD_LOGIC;
        an   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end js05_top;

architecture Behavioral of js05_top is

    signal btnU_db, btnD_db, btnC_db : STD_LOGIC;
    signal pulse_up, pulse_down      : STD_LOGIC;
    
    -- Sinyal internal hasil pemfilteran switch freeze
    signal valid_up, valid_down      : STD_LOGIC;
    
    signal counter_val               : STD_LOGIC_VECTOR(15 downto 0);

begin

    -- 1. Debounce Modul
    db_u : entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10 )
        port map ( clk => clk, btn_in => btnU, btn_out => btnU_db );

    db_d : entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10 )
        port map ( clk => clk, btn_in => btnD, btn_out => btnD_db );

    db_c : entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10 )
        port map ( clk => clk, btn_in => btnC, btn_out => btnC_db );

    -- 2. Edge Detect Modul
    ed_u : entity work.edge_detect
        port map ( clk => clk, sig_in => btnU_db, pulse_out => pulse_up );

    ed_d : entity work.edge_detect
        port map ( clk => clk, sig_in => btnD_db, pulse_out => pulse_down );

    -- Logika Freeze: Abaikan pulsa jika sw0 = '1'
    valid_up   <= pulse_up when sw0 = '0' else '0';
    valid_down <= pulse_down when sw0 = '0' else '0';

    -- 3. Up/Down Counter
    cnt_inst : entity work.updown_counter
        port map (
            clk      => clk,
            btn_up   => valid_up,
            btn_down => valid_down,
            btn_rst  => btnC_db,
            count    => counter_val
        );

    -- 4. Seven Segment Driver
    seg_inst : entity work.seven_seg_driver
        generic map ( DIGITS => 4 )
        port map (
            clk     => clk,
            data_in => counter_val,
            seg     => seg,
            dp      => dp,
            an      => an
        );

end Behavioral;