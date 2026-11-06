library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench gabungan: 3 versi diberi stimulus yang SAMA pada satu waveform.
--   r0 = kombinasional (latency 0)
--   r2 = pipeline 2 tahap (latency 2 clock)
--   r3 = pipeline 3 tahap (latency 3 clock)
-- Satu pasangan (a,b) baru dimasukkan SETIAP siklus clock (menunjukkan throughput).
entity tb_mul_compare is
end tb_mul_compare;

architecture sim of tb_mul_compare is
    constant N : integer := 10;
    type vec_t is array (0 to N-1) of STD_LOGIC_VECTOR(15 downto 0);

    -- Nilai Q8.8. Komentar = nilai desimal.
    constant A_V : vec_t := (x"0200", x"0180", x"0080", x"0A40", x"0100",
                             x"0A80", x"0001", x"FF00", x"0C00", x"1000");
    constant B_V : vec_t := (x"0300", x"0180", x"0080", x"0400", x"0100",
                             x"0200", x"0001", x"0100", x"0140", x"1000");
    -- Hasil yang dihitung manual:
    -- 2.0*3.0=6.0 | 1.5*1.5=2.25 | 0.5*0.5=0.25 | 10.25*4.0=41.0 | 1.0*1.0=1.0
    -- 10.5*2.0=21.0 | 1/256*1/256 -> terpotong 0 | 255.0*1.0=255.0 | 12.0*1.25=15.0
    -- 16.0*16.0=256.0 -> OVERFLOW Q8.8, hasil wrap-around 0 (tanpa saturasi)
    constant E_V : vec_t := (x"0600", x"0240", x"0040", x"2900", x"0100",
                             x"1500", x"0000", x"FF00", x"0F00", x"0000");

    signal clk : STD_LOGIC := '0';
    signal a, b : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal r0, r2, r3 : STD_LOGIC_VECTOR(15 downto 0);
begin
    clk <= not clk after 5 ns;   -- 100 MHz

    dut0 : entity work.fixed_mul_q8_8
        port map (a => a, b => b, result => r0);
    dut2 : entity work.fixed_mul_pipe2
        port map (clk => clk, a => a, b => b, result => r2);
    dut3 : entity work.fixed_mul_pipe3
        port map (clk => clk, a => a, b => b, result => r3);

    stim : process
        variable errors : integer := 0;
    begin
        for i in 0 to N + 1 loop
            if i < N then
                a <= A_V(i);
                b <= B_V(i);
            end if;
            wait until rising_edge(clk);
            wait for 1 ns;     -- cek sesaat setelah tepi clock ke-i

            if i < N then
                if r0 /= E_V(i) then
                    errors := errors + 1;
                    report "KOMB salah pada vektor " & integer'image(i) severity error;
                end if;
            end if;
            if i >= 1 and (i - 1) < N then
                if r2 /= E_V(i - 1) then
                    errors := errors + 1;
                    report "PIPE2 salah pada vektor " & integer'image(i - 1) severity error;
                end if;
            end if;
            if i >= 2 and (i - 2) < N then
                if r3 /= E_V(i - 2) then
                    errors := errors + 1;
                    report "PIPE3 salah pada vektor " & integer'image(i - 2) severity error;
                end if;
            end if;
        end loop;

        if errors = 0 then
            report "SEMUA TEST LULUS" severity note;
        else
            report "ADA " & integer'image(errors) & " KESALAHAN" severity failure;
        end if;
        wait;
    end process;
end sim;
