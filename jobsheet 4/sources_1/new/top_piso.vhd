library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_piso is
    Port (
        clk  : in  STD_LOGIC;                     -- Clock 100 MHz (Pin W5)
        btnU : in  STD_LOGIC;                     -- rst (Reset)
        btnC : in  STD_LOGIC;                     -- load (Load data)
        sw   : in  STD_LOGIC_VECTOR (7 downto 0); -- Input data paralel
        led0 : out STD_LOGIC                      -- sout (Output serial)
    );
end top_piso;

architecture Behavioral of top_piso is
    signal clk_1hz : STD_LOGIC := '0';
    signal counter : integer range 0 to 49_999_999 := 0;
begin
    -- Pembagi frekuensi clock dari 100 MHz menjadi 1 Hz
    process(clk)
    begin
        if rising_edge(clk) then
            if counter = 49_999_999 then
                counter <= 0;
                clk_1hz <= not clk_1hz;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Instansiasi modul PISO menggunakan clock 1 Hz
    u_piso: entity work.piso_shift_reg
        port map (
            clk  => clk_1hz,
            rst  => btnU,
            load => btnC,
            d    => sw,
            sout => led0
        );
end Behavioral;