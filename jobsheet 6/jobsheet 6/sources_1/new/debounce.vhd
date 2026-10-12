library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    Port (
        clk     : in  STD_LOGIC;
        btn_in  : in  STD_LOGIC;
        btn_out : out STD_LOGIC
    );
end debounce;

architecture Behavioral of debounce is
    signal flipflops : std_logic_vector(1 downto 0) := "00";
    signal count : integer range 0 to 1000000 := 0; -- 10ms pada clock 100MHz
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Sinkronisasi mencegah metastabilitas
            flipflops(0) <= btn_in;
            flipflops(1) <= flipflops(0);

            -- Reset counter jika ada noise/perubahan
            if (flipflops(0) /= flipflops(1)) then
                count <= 0;
            elsif (count < 1000000) then
                count <= count + 1;
            else
                -- Sinyal stabil setelah 10ms
                btn_out <= flipflops(1);
            end if;
        end if;
    end process;
end Behavioral;