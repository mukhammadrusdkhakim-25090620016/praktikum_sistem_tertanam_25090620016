library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_i2c_master is
end tb_i2c_master;

architecture sim of tb_i2c_master is
  constant SLAVE_ADDR : std_logic_vector(6 downto 0) := "1001011";
  constant SLAVE_TX   : std_logic_vector(7 downto 0) := x"19";   -- data yang "dikirim" slave

  signal clk, rst, start, rw : std_logic := '0';
  signal slave_addr_s : std_logic_vector(6 downto 0) := SLAVE_ADDR;
  signal data_in, data_out   : std_logic_vector(7 downto 0) := (others => '0');
  signal busy, done, ack_error : std_logic;
  signal scl, sda : std_logic;

  signal slave_rx_data : std_logic_vector(7 downto 0) := x"FF";
begin
  -- Resistor pull-up eksternal
  scl <= 'H';
  sda <= 'H';

  clk <= not clk after 5 ns;

  uut : entity work.i2c_master
    port map ( clk => clk, rst => rst, start => start, rw => rw,
               slave_addr => slave_addr_s, data_in => data_in,
               data_out => data_out, busy => busy, done => done,
               ack_error => ack_error, scl => scl, sda => sda );

  ----------------------------------------------------------------
  -- Model slave I2C sederhana
  ----------------------------------------------------------------
  slave : process
    variable shreg : std_logic_vector(7 downto 0);

    procedure send_ack is
    begin
      wait until falling_edge(scl);        -- akhir bit ke-8
      sda <= '0';                          -- ACK
      wait until rising_edge(scl);         -- pulsa clock ke-9
      wait until falling_edge(scl);
      sda <= 'Z';
    end procedure;
  begin
    sda <= 'Z';
    -- Tunggu kondisi START: SDA turun saat SCL tinggi
    wait until falling_edge(sda) and To_X01(scl) = '1';

    -- Terima 8 bit (alamat + R/W)
    for i in 7 downto 0 loop
      wait until rising_edge(scl);
      shreg(i) := To_X01(sda);
    end loop;

    if shreg(7 downto 1) = SLAVE_ADDR then
      send_ack;
      if shreg(0) = '0' then
        -- Master menulis: terima 1 byte
        for i in 7 downto 0 loop
          wait until rising_edge(scl);
          shreg(i) := To_X01(sda);
        end loop;
        slave_rx_data <= shreg;
        send_ack;
      else
        -- Master membaca: kirim 1 byte
        for i in 7 downto 0 loop
          if SLAVE_TX(i) = '0' then sda <= '0'; else sda <= 'Z'; end if;
          wait until falling_edge(scl);
        end loop;
        sda <= 'Z';                         -- lepas untuk NACK dari master
        wait until rising_edge(scl);
        wait until falling_edge(scl);
      end if;
    else
      -- Alamat tidak cocok: jangan ACK (NACK)
      wait until rising_edge(scl);
      wait until falling_edge(scl);
    end if;
  end process;

  ----------------------------------------------------------------
  -- Stimulus
  ----------------------------------------------------------------
  stim : process
    procedure transaksi(a : std_logic_vector(6 downto 0);
                        r : std_logic;
                        d : std_logic_vector(7 downto 0)) is
    begin
      slave_addr_s <= a; rw <= r; data_in <= d;
      wait until rising_edge(clk);
      start <= '1';
      wait until rising_edge(clk);
      start <= '0';
      wait until done = '1';
      wait until rising_edge(clk);
    end procedure;
  begin
    rst <= '1'; wait for 100 ns;
    rst <= '0'; wait for 100 ns;

    -- 1) Tulis pointer register = 0x00
    transaksi(SLAVE_ADDR, '0', x"00");
    assert ack_error = '0'        report "Transaksi 1: ada ACK error"    severity error;
    assert slave_rx_data = x"00"  report "Transaksi 1: data slave salah" severity error;

    wait for 20 us;

    -- 2) Baca 1 byte
    transaksi(SLAVE_ADDR, '1', x"00");
    assert ack_error = '0'        report "Transaksi 2: ada ACK error"    severity error;
    assert data_out = SLAVE_TX    report "Transaksi 2: data baca salah"  severity error;

    wait for 20 us;

    -- 3) Alamat salah -> harus NACK
    transaksi("0100000", '0', x"00");
    assert ack_error = '1'        report "Transaksi 3: seharusnya NACK"  severity error;

    report "Simulasi I2C selesai." severity note;
    wait;
  end process;
end sim;