library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity piso_shift_reg is
    Port (
        clk  : in  STD_LOGIC;
        rst  : in  STD_LOGIC;
        load : in  STD_LOGIC;
        d    : in  STD_LOGIC_VECTOR (7 downto 0);
        sout : out STD_LOGIC
    );
end piso_shift_reg;

architecture Behavioral of piso_shift_reg is
    signal shift_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                shift_reg <= (others => '0');
            elsif load = '1' then
                shift_reg <= d; -- Pemuatan paralel (Parallel-In)
            else
                -- Geser data ke kiri: MSB keluar, LSB diisi '0'
                shift_reg <= shift_reg(6 downto 0) & '0';
            end if;
        end if;
    end process;

    -- Bit paling kiri (MSB) dikeluarkan secara serial
    sout <= shift_reg(7);
end Behavioral;