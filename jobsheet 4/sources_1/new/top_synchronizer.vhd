library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_synchronizer is
    Port (
        clk  : in  STD_LOGIC;
        btnC : in  STD_LOGIC; -- input tombol asinkron
        led0 : out STD_LOGIC  -- output led(0)
    );
end top_synchronizer;

architecture Behavioral of top_synchronizer is
    signal sync_out     : STD_LOGIC;
    signal sync_out_reg : STD_LOGIC := '0';
    signal led_state    : STD_LOGIC := '0';
begin
    -- Instansiasi modul synchronizer 2-tingkat
    u_sync : entity work.synchronizer_2ff
        port map (
            clk      => clk,
            async_in => btnC,
            sync_out => sync_out
        );

    -- Logika deteksi tepi naik (rising edge) & toggle LED
    process(clk)
    begin
        if rising_edge(clk) then
            -- Menyimpan nilai sync_out pada siklus clock sebelumnya
            sync_out_reg <= sync_out;

            -- Jika sync_out bernilai '1' dan nilai sebelumnya '0', terjadi tepi naik
            if sync_out = '1' and sync_out_reg = '0' then
                led_state <= not led_state; -- Toggle kondisi LED
            end if;
        end if;
    end process;

    led0 <= led_state;
end Behavioral;