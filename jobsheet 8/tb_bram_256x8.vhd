library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_bram_256x8 is
end tb_bram_256x8;

architecture sim of tb_bram_256x8 is
  signal clk  : std_logic := '0';
  signal we   : std_logic := '0';
  signal addr : std_logic_vector(7 downto 0) := (others => '0');
  signal din  : std_logic_vector(7 downto 0) := (others => '0');
  signal dout : std_logic_vector(7 downto 0);
begin
  uut : entity work.bram_256x8
    port map (clk => clk, we => we, addr => addr, din => din, dout => dout);

  clk <= not clk after 5 ns;   -- 100 MHz

  stim : process
    procedure write_mem(a : integer; d : integer) is
    begin
      addr <= std_logic_vector(to_unsigned(a, 8));
      din  <= std_logic_vector(to_unsigned(d, 8));
      we   <= '1';
      wait until rising_edge(clk);   -- data ditulis pada tepi ini
      wait for 1 ns;
      we   <= '0';
    end procedure;

    procedure read_check(a : integer; expected : integer) is
    begin
      addr <= std_logic_vector(to_unsigned(a, 8));
      wait until rising_edge(clk);   -- alamat di-latch, dout_reg terisi
      wait for 1 ns;                 -- latensi baca = 1 siklus clock
      assert to_integer(unsigned(dout)) = expected
        report "GAGAL di alamat " & integer'image(a) &
               ": dibaca " & integer'image(to_integer(unsigned(dout))) &
               ", seharusnya " & integer'image(expected)
        severity error;
    end procedure;
  begin
    wait for 50 ns;

    -- Tulis beberapa data ke alamat berbeda
    write_mem(0,   16#AA#);
    write_mem(1,   16#55#);
    write_mem(10,  16#3C#);
    write_mem(128, 16#F0#);
    write_mem(255, 16#0F#);

    -- Baca kembali dan verifikasi dengan assert
    read_check(0,   16#AA#);
    read_check(1,   16#55#);
    read_check(10,  16#3C#);
    read_check(128, 16#F0#);
    read_check(255, 16#0F#);
    read_check(77,  0);          -- alamat yang tidak ditulis harus 0 (nilai awal)

    report "Simulasi BRAM selesai. Jika tidak ada pesan 'GAGAL', semua data benar."
      severity note;
    wait;
  end process;
end sim;