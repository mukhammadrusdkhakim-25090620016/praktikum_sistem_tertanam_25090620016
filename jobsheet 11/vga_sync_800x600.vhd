-- ============================================================
-- vga_sync_800x600.vhd  (Tugas 3, opsional)
-- 800x600 @ 60 Hz, pixel clock 40 MHz, polaritas sync POSITIF
--   Horizontal: 800 + 40 (front porch) + 128 (sync) + 88 (back porch) = 1056
--   Vertikal  : 600 +  1 (front porch) +   4 (sync) + 23 (back porch) =  628
--   Refresh   : 40.000.000 / (1056 x 628) = 60,3 Hz
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_sync_800x600 is
  Port ( pclk     : in  STD_LOGIC;                  -- 40 MHz
         rst      : in  STD_LOGIC;
         hsync    : out STD_LOGIC;
         vsync    : out STD_LOGIC;
         video_on : out STD_LOGIC;
         h_count  : out integer range 0 to 1055;
         v_count  : out integer range 0 to 627 );
end vga_sync_800x600;

architecture Behavioral of vga_sync_800x600 is
  constant H_DISPLAY : integer := 800;
  constant H_FPORCH  : integer := 40;
  constant H_SYNC    : integer := 128;
  constant H_TOTAL   : integer := 1056;
  constant V_DISPLAY : integer := 600;
  constant V_FPORCH  : integer := 1;
  constant V_SYNC    : integer := 4;
  constant V_TOTAL   : integer := 628;
  signal hc : integer range 0 to H_TOTAL-1 := 0;
  signal vc : integer range 0 to V_TOTAL-1 := 0;
begin
  process(pclk)
  begin
    if rising_edge(pclk) then
      if rst = '1' then
        hc <= 0; vc <= 0;
      elsif hc = H_TOTAL-1 then
        hc <= 0;
        if vc = V_TOTAL-1 then vc <= 0; else vc <= vc + 1; end if;
      else
        hc <= hc + 1;
      end if;
    end if;
  end process;

  -- polaritas positif: sync aktif = '1'
  hsync <= '1' when (hc >= H_DISPLAY+H_FPORCH) and (hc < H_DISPLAY+H_FPORCH+H_SYNC) else '0';
  vsync <= '1' when (vc >= V_DISPLAY+V_FPORCH) and (vc < V_DISPLAY+V_FPORCH+V_SYNC) else '0';
  video_on <= '1' when (hc < H_DISPLAY) and (vc < V_DISPLAY) else '0';
  h_count <= hc;
  v_count <= vc;
end Behavioral;
