-- ============================================================
-- js11_top_tugas.vhd (Tugas 1 dan 2)
-- Papan catur + kotak merah yang posisinya mengikuti sw(3:0)
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js11_top_tugas is
  Port ( clk      : in  STD_LOGIC;
         sw       : in  STD_LOGIC_VECTOR(3 downto 0);
         vgaRed   : out STD_LOGIC_VECTOR(3 downto 0);
         vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
         vgaBlue  : out STD_LOGIC_VECTOR(3 downto 0);
         Hsync    : out STD_LOGIC;
         Vsync    : out STD_LOGIC );
end js11_top_tugas;

architecture Behavioral of js11_top_tugas is
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
  signal rgb_chk, rgb        : STD_LOGIC_VECTOR(11 downto 0);
  signal box_on              : STD_LOGIC;
begin
  u_clk : clk_wiz_0
    port map ( clk_out1 => pclk, reset => '0', locked => locked, clk_in1 => clk );
  rst_i <= not locked;

  u_sync : entity work.vga_sync
    port map ( pclk => pclk, rst => rst_i, hsync => hs, vsync => vs,
               video_on => von, h_count => hcnt, v_count => vcnt );

  u_chk : entity work.checker_pattern
    port map ( h_count => hcnt, v_count => vcnt, rgb => rgb_chk );

  u_box : entity work.box_indicator
    port map ( h_count => hcnt, v_count => vcnt, sw => sw, box_on => box_on );

  rgb <= x"F00" when box_on = '1' else rgb_chk;          -- kotak merah di atas papan catur

  vgaRed   <= rgb(11 downto 8) when von = '1' else "0000";
  vgaGreen <= rgb(7 downto 4)  when von = '1' else "0000";
  vgaBlue  <= rgb(3 downto 0)  when von = '1' else "0000";
  Hsync <= hs;
  Vsync <= vs;
end Behavioral;
