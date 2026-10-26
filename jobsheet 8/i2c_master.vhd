library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_master is
  generic ( CLK_FREQ : integer := 100_000_000;   -- clock sistem (Basys 3)
            I2C_FREQ : integer := 100_000 );     -- SCL standar mode
  port ( clk        : in  std_logic;
         rst        : in  std_logic;
         start      : in  std_logic;                      -- pulsa 1 clock: mulai transaksi
         rw         : in  std_logic;                      -- '0' = tulis, '1' = baca
         slave_addr : in  std_logic_vector(6 downto 0);
         data_in    : in  std_logic_vector(7 downto 0);   -- data untuk ditulis
         data_out   : out std_logic_vector(7 downto 0);   -- data hasil baca
         busy       : out std_logic;
         done       : out std_logic;                      -- pulsa 1 clock saat selesai
         ack_error  : out std_logic;                      -- '1' jika slave tidak ACK
         scl        : out std_logic;                      -- open-drain
         sda        : inout std_logic );                  -- open-drain
end i2c_master;

architecture Behavioral of i2c_master is
  constant DIV : integer := CLK_FREQ / (4 * I2C_FREQ);

  type i2c_state is (S_IDLE, S_START, S_ADDR, S_ADDR_ACK,
                     S_DATA, S_DATA_ACK, S_STOP);
  signal state   : i2c_state := S_IDLE;

  signal cnt     : integer range 0 to DIV-1 := 0;
  signal tick    : std_logic;                       -- 1 pulsa tiap 1/4 periode SCL
  signal phase   : integer range 0 to 3 := 0;
  signal bit_cnt : integer range 0 to 7 := 7;

  signal sh      : std_logic_vector(7 downto 0) := (others => '0'); -- shift kirim
  signal rx      : std_logic_vector(7 downto 0) := (others => '0'); -- shift terima
  signal rw_r    : std_logic := '0';
  signal addr_r  : std_logic_vector(6 downto 0) := (others => '0');
  signal data_r  : std_logic_vector(7 downto 0) := (others => '0');

  signal scl_o, sda_o : std_logic := '1';           -- '0' = tarik rendah, '1' = lepas
  signal err     : std_logic := '0';
begin
  tick <= '1' when cnt = DIV-1 else '0';

  -- Open-drain: hanya pernah menggerakkan '0' atau 'Z'
  scl <= '0' when scl_o = '0' else 'Z';
  sda <= '0' when sda_o = '0' else 'Z';
  ack_error <= err;

  process(clk)
  begin
    if rising_edge(clk) then
      done <= '0';                                  -- default: pulsa 1 clock

      if rst = '1' then
        state <= S_IDLE; phase <= 0; cnt <= 0;
        scl_o <= '1'; sda_o <= '1';
        busy <= '0'; err <= '0';
        data_out <= (others => '0');
      else
        -- Pembagi clock bebas-jalan
        if cnt = DIV-1 then cnt <= 0; else cnt <= cnt + 1; end if;

        if state = S_IDLE then
          scl_o <= '1'; sda_o <= '1';
          if start = '1' then
            addr_r <= slave_addr;
            rw_r   <= rw;
            data_r <= data_in;
            err    <= '0';
            busy   <= '1';
            phase  <= 0;
            state  <= S_START;
          end if;

        elsif tick = '1' then
          case state is

            ------------------------------------------------ START
            when S_START =>
              case phase is
                when 0 => sda_o <= '1'; scl_o <= '1'; phase <= 1;
                when 1 => sda_o <= '0'; phase <= 2;          -- SDA turun, SCL tinggi
                when 2 => phase <= 3;                        -- tahan
                when others =>
                  scl_o   <= '0';
                  sh      <= addr_r & rw_r;                  -- 7-bit alamat + R/W
                  bit_cnt <= 7;
                  phase   <= 0;
                  state   <= S_ADDR;
              end case;

            ------------------------------------------------ KIRIM ALAMAT
            when S_ADDR =>
              case phase is
                when 0 => scl_o <= '0'; sda_o <= sh(7); phase <= 1;
                when 1 => scl_o <= '1'; phase <= 2;
                when 2 => phase <= 3;
                when others =>
                  scl_o <= '0'; phase <= 0;
                  if bit_cnt = 0 then
                    state <= S_ADDR_ACK;
                  else
                    sh <= sh(6 downto 0) & '0';
                    bit_cnt <= bit_cnt - 1;
                  end if;
              end case;

            ------------------------------------------------ ACK ALAMAT (dari slave)
            when S_ADDR_ACK =>
              case phase is
                when 0 => scl_o <= '0'; sda_o <= '1'; phase <= 1;   -- lepas SDA
                when 1 => scl_o <= '1'; phase <= 2;
                when 2 =>
                  if sda /= '0' then err <= '1'; end if;            -- tidak ada ACK
                  phase <= 3;
                when others =>
                  scl_o <= '0'; phase <= 0;
                  if err = '1' then
                    state <= S_STOP;
                  else
                    sh <= data_r; bit_cnt <= 7;
                    state <= S_DATA;
                  end if;
              end case;

            ------------------------------------------------ DATA (tulis / baca)
            when S_DATA =>
              case phase is
                when 0 =>
                  scl_o <= '0';
                  if rw_r = '0' then sda_o <= sh(7);       -- tulis: master mengirim
                  else               sda_o <= '1';         -- baca : lepas SDA
                  end if;
                  phase <= 1;
                when 1 => scl_o <= '1'; phase <= 2;
                when 2 =>
                  if rw_r = '1' then                       -- baca: sampling bit
                    if sda = '0' then rx <= rx(6 downto 0) & '0';
                    else              rx <= rx(6 downto 0) & '1';
                    end if;
                  end if;
                  phase <= 3;
                when others =>
                  scl_o <= '0'; phase <= 0;
                  if bit_cnt = 0 then
                    state <= S_DATA_ACK;
                  else
                    sh <= sh(6 downto 0) & '0';
                    bit_cnt <= bit_cnt - 1;
                  end if;
              end case;

            ------------------------------------------------ ACK/NACK DATA
            when S_DATA_ACK =>
              case phase is
                -- Tulis: SDA dilepas, slave yang ACK.
                -- Baca : SDA dilepas = master mengirim NACK (byte terakhir).
                when 0 => scl_o <= '0'; sda_o <= '1'; phase <= 1;
                when 1 => scl_o <= '1'; phase <= 2;
                when 2 =>
                  if rw_r = '0' and sda /= '0' then err <= '1'; end if;
                  phase <= 3;
                when others =>
                  scl_o <= '0'; phase <= 0;
                  if rw_r = '1' then data_out <= rx; end if;
                  state <= S_STOP;
              end case;

            ------------------------------------------------ STOP
            when S_STOP =>
              case phase is
                when 0 => scl_o <= '0'; sda_o <= '0'; phase <= 1;
                when 1 => scl_o <= '1'; phase <= 2;
                when 2 => sda_o <= '1'; phase <= 3;          -- SDA naik, SCL tinggi
                when others =>
                  state <= S_IDLE; phase <= 0;
                  busy  <= '0';
                  done  <= '1';
              end case;

            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process;
end Behavioral;