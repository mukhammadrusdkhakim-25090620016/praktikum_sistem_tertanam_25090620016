-- ============================================================
-- tb_patterns.vhd
-- Memverifikasi color_bar_pattern, checker_pattern, dan box_indicator
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_patterns is
end tb_patterns;

architecture sim of tb_patterns is
  signal h : integer range 0 to 799 := 0;
  signal v : integer range 0 to 524 := 0;
  signal sw : STD_LOGIC_VECTOR(3 downto 0) := "0000";
  signal rgb_bar, rgb_chk : STD_LOGIC_VECTOR(11 downto 0);
  signal box_on : STD_LOGIC;
begin
  bar : entity work.color_bar_pattern generic map (ZONE_W => 80) port map (h_count => h, rgb => rgb_bar);
  chk : entity work.checker_pattern   port map (h_count => h, v_count => v, rgb => rgb_chk);
  box : entity work.box_indicator     port map (h_count => h, v_count => v, sw => sw, box_on => box_on);

  process
    variable errs : integer := 0;
    type col_t is array (0 to 7) of STD_LOGIC_VECTOR(11 downto 0);
    constant COLS : col_t := (x"FFF", x"FF0", x"0FF", x"0F0", x"F0F", x"F00", x"00F", x"000");
  begin
    -- batang warna: awal, tengah, dan akhir tiap zona
    for z in 0 to 7 loop
      for off in 0 to 2 loop
        case off is
          when 0 => h <= z*80;
          when 1 => h <= z*80 + 40;
          when others => h <= z*80 + 79;
        end case;
        wait for 1 ns;
        if rgb_bar /= COLS(z) then
          errs := errs + 1; report "GAGAL batang warna zona " & integer'image(z) severity error;
        end if;
      end loop;
    end loop;

    -- papan catur: kotak 32x32
    h <= 0;  v <= 0;  wait for 1 ns; if rgb_chk /= x"000" then errs := errs + 1; report "GAGAL catur (0,0)" severity error; end if;
    h <= 31; v <= 31; wait for 1 ns; if rgb_chk /= x"000" then errs := errs + 1; report "GAGAL catur (31,31)" severity error; end if;
    h <= 32; v <= 0;  wait for 1 ns; if rgb_chk /= x"FFF" then errs := errs + 1; report "GAGAL catur (32,0)" severity error; end if;
    h <= 0;  v <= 32; wait for 1 ns; if rgb_chk /= x"FFF" then errs := errs + 1; report "GAGAL catur (0,32)" severity error; end if;
    h <= 32; v <= 32; wait for 1 ns; if rgb_chk /= x"000" then errs := errs + 1; report "GAGAL catur (32,32)" severity error; end if;
    h <= 639; v <= 479; wait for 1 ns;   -- 639/32 = 19, 479/32 = 14 -> 19 xor 14 = ganjil -> putih
    if rgb_chk /= x"FFF" then errs := errs + 1; report "GAGAL catur (639,479)" severity error; end if;

    -- kotak: sw=0 -> x 0..39; sw=1 -> x 40..79; sw=15 -> x 600..639; y 220..259
    for s in 0 to 15 loop
      sw <= STD_LOGIC_VECTOR(to_unsigned(s, 4));
      v <= 240; h <= s*40;      wait for 1 ns;
      if box_on /= '1' then errs := errs + 1; report "GAGAL kotak tepi kiri sw=" & integer'image(s) severity error; end if;
      h <= s*40 + 39;           wait for 1 ns;
      if box_on /= '1' then errs := errs + 1; report "GAGAL kotak tepi kanan sw=" & integer'image(s) severity error; end if;
      if s < 15 then
        h <= s*40 + 40;         wait for 1 ns;
        if box_on /= '0' then errs := errs + 1; report "GAGAL kotak di luar kanan sw=" & integer'image(s) severity error; end if;
      end if;
      if s > 0 then
        h <= s*40 - 1;          wait for 1 ns;
        if box_on /= '0' then errs := errs + 1; report "GAGAL kotak di luar kiri sw=" & integer'image(s) severity error; end if;
      end if;
    end loop;
    sw <= "0101"; h <= 5*40; v <= 219; wait for 1 ns;
    if box_on /= '0' then errs := errs + 1; report "GAGAL kotak di atas batas" severity error; end if;
    v <= 260; wait for 1 ns;
    if box_on /= '0' then errs := errs + 1; report "GAGAL kotak di bawah batas" severity error; end if;

    if errs = 0 then report "SEMUA TEST LULUS" severity note;
    else report "ADA " & integer'image(errs) & " KESALAHAN" severity failure; end if;
    wait;
  end process;
end sim;
