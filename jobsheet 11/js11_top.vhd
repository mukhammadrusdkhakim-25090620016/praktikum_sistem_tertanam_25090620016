-- ============================================================
-- js11_top.vhd (Prosedur 4)
-- Top-level percobaan: Clocking Wizard 25 MHz + vga_sync + batang warna
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js11_top is
  Port ( clk      : in  STD_LOGIC;                      -- 100 MHz (W5)
         vgaRed   : out STD_LOGIC_VECTOR(3 downto 0);
         vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
         vgaBlue  : out STD_LOGIC_VECTOR(3 downto 0);
         Hsync    : out STD_LOGIC;
         Vsync    : out STD_LOGIC );
end js11_top;

architecture Behavioral of js11_top is
  -- IP Clocking Wizard (nama komponen dan port default dari IP Catalog)
  component clk_wiz_0
    port ( clk_out1 : out STD_LOGIC;
           reset    : in  STD_LOGIC;
           locked   : out STD_LOGIC;
           clk_in1  : in  STD_LOGIC );
  end component;

  signal pclk, locked, rst_i : STD_LOGIC;
  signal hs, vs, von         : STD_LOGIC;
  signal hcnt                : integer range 0 to 799;
  signal vcnt                : integer range 0 to 524;
  signal rgb                 : STD_LOGIC_VECTOR(11 downto 0);
begin
  u_clk : clk_wiz_0
    port map ( clk_out1 => pclk, reset => '0', locked => locked, clk_in1 => clk );

  rst_i <= not locked;          -- tahan generator selama clock belum stabil

  u_sync : entity work.vga_sync
    port map ( pclk => pclk, rst => rst_i, hsync => hs, vsync => vs,
               video_on => von, h_count => hcnt, v_count => vcnt );

  u_pat : entity work.color_bar_pattern
    generic map ( ZONE_W => 80 )
    port map ( h_count => hcnt, rgb => rgb );

  -- di luar area aktif, warna dipaksa hitam
  vgaRed   <= rgb(11 downto 8) when von = '1' else "0000";
  vgaGreen <= rgb(7 downto 4)  when von = '1' else "0000";
  vgaBlue  <= rgb(3 downto 0)  when von = '1' else "0000";
  Hsync <= hs;
  Vsync <= vs;
end Behavioral;
