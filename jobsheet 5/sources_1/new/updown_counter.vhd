library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity updown_counter is
    Port (
        clk     : in  STD_LOGIC;
        inc_p   : in  STD_LOGIC; -- Pulsa tambah dari btnU
        dec_p   : in  STD_LOGIC; -- Pulsa kurang dari btnD
        reset_p : in  STD_LOGIC; -- Sinyal reset dari btnC
        count_out : out STD_LOGIC_VECTOR(15 downto 0) -- 4 digit BCD
    );
end updown_counter;

architecture Behavioral of updown_counter is
    signal d0, d1, d2, d3 : integer range 0 to 9 := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset_p = '1' then
                d0 <= 0; d1 <= 0; d2 <= 0; d3 <= 0;
            elsif inc_p = '1' then
                -- Pencacah Naik (BCD Increment)
                if d0 = 9 then
                    d0 <= 0;
                    if d1 = 9 then
                        d1 <= 0;
                        if d2 = 9 then
                            d2 <= 0;
                            if d3 = 9 then d3 <= 0; else d3 <= d3 + 1; end if;
                        else d2 <= d2 + 1; end if;
                    else d1 <= d1 + 1; end if;
                else d0 <= d0 + 1; end if;
            elsif dec_p = '1' then
                -- Pencacah Turun (BCD Decrement)
                if d0 = 0 then
                    d0 <= 9;
                    if d1 = 0 then
                        d1 <= 9;
                        if d2 = 0 then
                            d2 <= 9;
                            if d3 = 0 then d3 <= 9; else d3 <= d3 - 1; end if;
                        else d2 <= d2 - 1; end if;
                    else d1 <= d1 - 1; end if;
                else d0 <= d0 - 1; end if;
            end if;
        end if;
    end process;

    -- Gabungkan 4 digit BCD ke output 16-bit
    count_out <= std_logic_vector(to_unsigned(d3, 4)) &
                 std_logic_vector(to_unsigned(d2, 4)) &
                 std_logic_vector(to_unsigned(d1, 4)) &
                 std_logic_vector(to_unsigned(d0, 4));

end Behavioral;
