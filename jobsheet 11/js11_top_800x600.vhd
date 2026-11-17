-- ============================================================
-- js11_top_800x600.vhd (Tugas 3, opsional)
-- Versi 800x600: IP Clocking Wizard (clk_wiz_0) harus dikonfigurasi 40 MHz
-- Batang warna 8 x 100 piksel
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js11_top_800x600 is
  Port ( clk      : in  STD_LOGIC;
         vgaRed   : out STD_LOGIC_VECTOR(3 downto 0);
         vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
         vgaBlue  : out STD_LOGIC_VECTOR(3 downto 0);
         Hsync    : out STD_LOGIC;
         Vsync    : out STD_LOGIC );
end js11_top_800x600;

architecture Behavioral of js11_top_800x600 is
  component clk_wiz_0
    port ( clk_out1 : out STD_LOGIC;
           reset    : in  STD_LOGIC;
           locked   : out STD_LOGIC;
           clk_in1  : in  STD_LOGIC );
  end component;
  signal pclk, locked, rst_i : STD_LOGIC;
  signal von                 : STD_LOGIC;
  signal hcnt                : integer range 0 to 1055;
  signal vcnt                : integer range 0 to 627;
  signal rgb                 : STD_LOGIC_VECTOR(11 downto 0);
begin
  u_clk : clk_wiz_0
    port map ( clk_out1 => pclk, reset => '0', locked => locked, clk_in1 => clk );
  rst_i <= not locked;

  u_sync : entity work.vga_sync_800x600
    port map ( pclk => pclk, rst => rst_i, hsync => Hsync, vsync => Vsync,
               video_on => von, h_count => hcnt, v_count => vcnt );

  rgb <= x"FFF" when hcnt < 100 else
         x"FF0" when hcnt < 200 else
         x"0FF" when hcnt < 300 else
         x"0F0" when hcnt < 400 else
         x"F0F" when hcnt < 500 else
         x"F00" when hcnt < 600 else
         x"00F" when hcnt < 700 else
         x"000";

  vgaRed   <= rgb(11 downto 8) when von = '1' else "0000";
  vgaGreen <= rgb(7 downto 4)  when von = '1' else "0000";
  vgaBlue  <= rgb(3 downto 0)  when von = '1' else "0000";
end Behavioral;
