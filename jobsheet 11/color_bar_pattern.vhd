-- ============================================================
-- color_bar_pattern.vhd (Prosedur 3)
-- 8 batang warna vertikal; tiap zona lebarnya ZONE_W piksel
-- Urutan: putih, kuning, cyan, hijau, magenta, merah, biru, hitam
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity color_bar_pattern is
  Generic ( ZONE_W : integer := 80 );               -- 8 x 80 = 640 piksel
  Port ( h_count : in  integer range 0 to 799;
         rgb     : out STD_LOGIC_VECTOR(11 downto 0) );  -- R(11:8) G(7:4) B(3:0)
end color_bar_pattern;

architecture Behavioral of color_bar_pattern is
begin
  rgb <= x"FFF" when h_count < 1*ZONE_W else   -- putih
         x"FF0" when h_count < 2*ZONE_W else   -- kuning
         x"0FF" when h_count < 3*ZONE_W else   -- cyan
         x"0F0" when h_count < 4*ZONE_W else   -- hijau
         x"F0F" when h_count < 5*ZONE_W else   -- magenta
         x"F00" when h_count < 6*ZONE_W else   -- merah
         x"00F" when h_count < 7*ZONE_W else   -- biru
         x"000";                               -- hitam
end Behavioral;
