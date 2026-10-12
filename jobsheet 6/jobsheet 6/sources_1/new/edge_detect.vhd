library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detect is
    Port (
        clk       : in  STD_LOGIC;
        sig_in    : in  STD_LOGIC; -- Dihubungkan ke output debounce
        pulse_out : out STD_LOGIC
    );
end edge_detect;

architecture Behavioral of edge_detect is
    signal sig_in_delay : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            sig_in_delay <= sig_in;
        end if;
    end process;

    -- Menghasilkan '1' hanya saat rising edge
    pulse_out <= sig_in and (not sig_in_delay);

end Behavioral;