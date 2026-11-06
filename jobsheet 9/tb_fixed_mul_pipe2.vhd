library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench Prosedur 2: pipeline 2 tahap (stimulus SAMA dengan tb_fixed_mul_q8_8)
-- Satu pasangan (a,b) baru dimasukkan SETIAP siklus clock.
-- Hasil vektor ke-i muncul setelah tepi clock ke-(i+1), yaitu latency 2 siklus.
entity tb_fixed_mul_pipe2 is
end tb_fixed_mul_pipe2;

architecture sim of tb_fixed_mul_pipe2 is
    constant N : integer := 10;
    type vec_t is array (0 to N-1) of STD_LOGIC_VECTOR(15 downto 0);

    constant A_V : vec_t := (x"0200", x"0180", x"0080", x"0A40", x"0100",
                             x"0A80", x"0001", x"FF00", x"0C00", x"1000");
    constant B_V : vec_t := (x"0300", x"0180", x"0080", x"0400", x"0100",
                             x"0200", x"0001", x"0100", x"0140", x"1000");
    constant E_V : vec_t := (x"0600", x"0240", x"0040", x"2900", x"0100",
                             x"1500", x"0000", x"FF00", x"0F00", x"0000");

    signal clk : STD_LOGIC := '0';
    signal a, b, result : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    clk <= not clk after 5 ns;   -- 100 MHz

    dut : entity work.fixed_mul_pipe2
        port map (clk => clk, a => a, b => b, result => result);

    stim : process
        variable errors : integer := 0;
    begin
        for i in 0 to N loop
            if i < N then
                a <= A_V(i);
                b <= B_V(i);
            end if;
            wait until rising_edge(clk);
            wait for 1 ns;                 -- cek sesaat setelah tepi clock ke-i
            if i >= 1 then
                if result /= E_V(i-1) then
                    errors := errors + 1;
                    report "SALAH pada vektor " & integer'image(i-1) severity error;
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
