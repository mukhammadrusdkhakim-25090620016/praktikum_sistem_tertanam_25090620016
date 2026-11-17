-- ============================================================
-- checker_pattern.vhd (Tugas 1)
-- Papan catur: kotak 32x32 piksel dari bit h_count(5) XOR v_count(5)
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity checker_pattern is
  Port ( h_count : in  integer range 0 to 799;
         v_count : in  integer range 0 to 524;
         rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
end checker_pattern;

architecture Behavioral of checker_pattern is
  signal hb, vb : STD_LOGIC_VECTOR(10 downto 0);
begin
  hb <= STD_LOGIC_VECTOR(to_unsigned(h_count, 11));
  vb <= STD_LOGIC_VECTOR(to_unsigned(v_count, 11));
  rgb <= x"FFF" when (hb(5) xor vb(5)) = '1' else x"000";   -- putih / hitam
end Behavioral;
