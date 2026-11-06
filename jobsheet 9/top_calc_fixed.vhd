library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Tugas 2 (poin d): perkalian fixed-point Q2.2 x Q2.2 -> Q4.4
--   sw(7 downto 4) = A (Q2.2, 0..3.75, resolusi 0.25)
--   sw(3 downto 0) = B (Q2.2)
--   Hasil 8 bit Q4.4 (0..14.0625, resolusi 0.0625), tampil di 7-segment "II.FF"
--   LED(7 downto 0) menampilkan bit mentah hasil Q4.4.
-- Pipeline 2 tahap:  tahap 1 = perkalian,  tahap 2 = konversi ke digit desimal.
entity top_calc_fixed is
    Port ( clk : in  STD_LOGIC;
           sw  : in  STD_LOGIC_VECTOR (7 downto 0);
           led : out STD_LOGIC_VECTOR (7 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);   -- aktif LOW (CA..CG)
           dp  : out STD_LOGIC;                       -- aktif LOW
           an  : out STD_LOGIC_VECTOR (3 downto 0));  -- aktif LOW
end top_calc_fixed;

architecture Behavioral of top_calc_fixed is
    signal prod_reg : unsigned(7 downto 0) := (others => '0');  -- Q4.4 (tahap 1)
    -- digit hasil (tahap 2). Nilai 15 = digit kosong (blank)
    signal dig3, dig2, dig1, dig0 : integer range 0 to 15 := 0;

    signal scan : unsigned(18 downto 0) := (others => '0');
    signal sel  : STD_LOGIC_VECTOR(1 downto 0);

    function seg_decode(d : integer) return STD_LOGIC_VECTOR is
    begin
        case d is                       -- urutan bit: g f e d c b a (aktif LOW)
            when 0 => return "1000000";
            when 1 => return "1111001";
            when 2 => return "0100100";
            when 3 => return "0110000";
            when 4 => return "0011001";
            when 5 => return "0010010";
            when 6 => return "0000010";
            when 7 => return "1111000";
            when 8 => return "0000000";
            when 9 => return "0010000";
            when others => return "1111111";   -- blank
        end case;
    end function;
begin
    -- ===== Pipeline 2 tahap =====
    process(clk)
        variable ip : integer range 0 to 15;   -- bagian bulat  (0..14)
        variable fp : integer range 0 to 15;   -- bagian pecahan (x/16)
        variable fd : integer range 0 to 99;   -- 2 digit desimal pecahan
    begin
        if rising_edge(clk) then
            -- Tahap 1: Q2.2 x Q2.2 = Q4.4 (4+4 bit, tidak perlu pemotongan)
            prod_reg <= unsigned(sw(7 downto 4)) * unsigned(sw(3 downto 0));

            -- Tahap 2: pecah menjadi digit desimal
            ip := to_integer(prod_reg(7 downto 4));
            fp := to_integer(prod_reg(3 downto 0));
            fd := (fp * 25) / 4;                -- fp/16*100, dipotong (truncate)

            if ip >= 10 then
                dig3 <= 1;      dig2 <= ip - 10;
            else
                dig3 <= 15;     dig2 <= ip;     -- puluhan kosong
            end if;
            dig1 <= fd / 10;
            dig0 <= fd mod 10;
        end if;
    end process;

    led <= STD_LOGIC_VECTOR(prod_reg);

    -- ===== Multiplexing 7-segment (~190 Hz per frame) =====
    process(clk)
    begin
        if rising_edge(clk) then
            scan <= scan + 1;
        end if;
    end process;
    sel <= STD_LOGIC_VECTOR(scan(18 downto 17));

    process(sel, dig0, dig1, dig2, dig3)
        variable d : integer range 0 to 15;
    begin
        case sel is
            when "00"   => an <= "1110"; d := dig0; dp <= '1';
            when "01"   => an <= "1101"; d := dig1; dp <= '1';
            when "10"   => an <= "1011"; d := dig2; dp <= '0';   -- titik desimal
            when others => an <= "0111"; d := dig3; dp <= '1';
        end case;
        seg <= seg_decode(d);
    end process;
end Behavioral;
