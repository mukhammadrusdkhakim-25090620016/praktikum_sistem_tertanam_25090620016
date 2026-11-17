-- ============================================================
-- box_indicator.vhd (Tugas 2)
-- Kotak 40x40 piksel; posisi horizontalnya = sw(3:0) x 40 piksel
--   sw = 0000 -> x = 0..39 (kiri)   sw = 1111 -> x = 600..639 (kanan)
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity box_indicator is
  Generic ( BOX_W : integer := 40;
            BOX_H : integer := 40;
            BOX_Y : integer := 220 );                  -- baris awal kotak
  Port ( h_count : in  integer range 0 to 799;
         v_count : in  integer range 0 to 524;
         sw      : in  STD_LOGIC_VECTOR(3 downto 0);
         box_on  : out STD_LOGIC );
end box_indicator;

architecture Behavioral of box_indicator is
  signal x0 : integer range 0 to 2047;
begin
  x0 <= to_integer(unsigned(sw)) * BOX_W;
  box_on <= '1' when (h_count >= x0) and (h_count < x0 + BOX_W) and
                     (v_count >= BOX_Y) and (v_count < BOX_Y + BOX_H) else '0';
end Behavioral;
