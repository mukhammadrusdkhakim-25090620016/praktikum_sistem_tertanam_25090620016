-- ============================================================
-- tb_vga_sync.vhd (Prosedur 2)
-- Memverifikasi lebar dan periode hsync/vsync sesuai Tabel 11.1
-- Simulasi 2 frame lebih (~37 ms) -> jalankan: run 40 ms
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_vga_sync is
end tb_vga_sync;

architecture sim of tb_vga_sync is
  constant T_PIX : time := 40 ns;                  -- 25 MHz
  signal pclk : STD_LOGIC := '0';
  signal rst  : STD_LOGIC := '1';
  signal hsync, vsync, video_on : STD_LOGIC;
  signal h_count : integer range 0 to 799;
  signal v_count : integer range 0 to 524;
  signal done : boolean := false;
begin
  pclk <= not pclk after T_PIX/2 when not done else pclk;

  dut : entity work.vga_sync
    port map (pclk => pclk, rst => rst, hsync => hsync, vsync => vsync,
              video_on => video_on, h_count => h_count, v_count => v_count);

  stim : process
  begin
    wait for 4*T_PIX;
    rst <= '0';
    wait for 2*525*800*T_PIX + 100*T_PIX;          -- 2 frame lebih
    done <= true;
    wait;
  end process;

  -- Monitor: semua pengukuran dalam satuan siklus pixel clock
  mon : process(pclk, done)
    variable prev_h, prev_v : STD_LOGIC := '1';
    variable h_low, v_low, h_per, v_per, von_cnt : integer := 0;
    variable h_n, v_n, errors : integer := 0;
    variable h_started, v_started, reported : boolean := false;
  begin
    if rising_edge(pclk) then
      -- hitung siklus (nilai sinyal sebelum tepi clock ini)
      if h_started then h_per := h_per + 1; end if;
      if v_started then v_per := v_per + 1; end if;
      if hsync = '0' then h_low := h_low + 1; end if;
      if vsync = '0' then v_low := v_low + 1; end if;
      if video_on = '1' then von_cnt := von_cnt + 1; end if;

      -- tepi turun hsync
      if prev_h = '1' and hsync = '0' then
        if h_started then
          if h_per /= 800 then
            errors := errors + 1;
            report "GAGAL periode hsync = " & integer'image(h_per) & " (harus 800)" severity error;
          end if;
        end if;
        h_started := true; h_per := 0; h_low := 1; h_n := h_n + 1;   -- sampel saat ini sudah low
      end if;
      -- tepi naik hsync
      if prev_h = '0' and hsync = '1' then
        if h_low /= 96 then
          errors := errors + 1;
          report "GAGAL lebar hsync = " & integer'image(h_low) & " (harus 96)" severity error;
        end if;
      end if;
      -- tepi turun vsync
      if prev_v = '1' and vsync = '0' then
        if v_started then
          if v_per /= 525*800 then
            errors := errors + 1;
            report "GAGAL periode vsync = " & integer'image(v_per) & " (harus 420000)" severity error;
          end if;
          if von_cnt /= 640*480 then
            errors := errors + 1;
            report "GAGAL piksel aktif per frame = " & integer'image(von_cnt) & " (harus 307200)" severity error;
          end if;
        end if;
        v_started := true; v_per := 0; v_low := 1; von_cnt := 0; v_n := v_n + 1;
      end if;
      -- tepi naik vsync
      if prev_v = '0' and vsync = '1' then
        if v_low /= 2*800 then
          errors := errors + 1;
          report "GAGAL lebar vsync = " & integer'image(v_low) & " siklus (harus 1600 = 2 baris)" severity error;
        end if;
      end if;
      prev_h := hsync; prev_v := vsync;
    end if;

    -- laporan akhir: dikerjakan saat 'done' naik (clock sudah berhenti)
    if done and not reported then
      reported := true;
      report "hsync: " & integer'image(h_n) & " pulsa; vsync: " & integer'image(v_n) & " pulsa diperiksa" severity note;
      if errors = 0 then
        report "SEMUA TEST LULUS" severity note;
      else
        report "ADA " & integer'image(errors) & " KESALAHAN" severity failure;
      end if;
    end if;
  end process;
end sim;
