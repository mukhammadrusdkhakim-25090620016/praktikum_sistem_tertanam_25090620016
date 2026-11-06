library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench Prosedur 1: versi kombinasional Q8.8
entity tb_fixed_mul_q8_8 is
end tb_fixed_mul_q8_8;

architecture sim of tb_fixed_mul_q8_8 is
    constant N : integer := 10;
    type vec_t is array (0 to N-1) of STD_LOGIC_VECTOR(15 downto 0);

    constant A_V : vec_t := (x"0200", x"0180", x"0080", x"0A40", x"0100",
                             x"0A80", x"0001", x"FF00", x"0C00", x"1000");
    constant B_V : vec_t := (x"0300", x"0180", x"0080", x"0400", x"0100",
                             x"0200", x"0001", x"0100", x"0140", x"1000");
    -- Hasil manual: 2.0*3.0=6.0 | 1.5*1.5=2.25 | 0.5*0.5=0.25 | 10.25*4.0=41.0
    -- 1.0*1.0=1.0 | 10.5*2.0=21.0 | (1/256)^2 terpotong 0 | 255.0*1.0=255.0
    -- 12.0*1.25=15.0 | 16.0*16.0=256.0 -> overflow, wrap-around 0
    constant E_V : vec_t := (x"0600", x"0240", x"0040", x"2900", x"0100",
                             x"1500", x"0000", x"FF00", x"0F00", x"0000");

    signal a, b, result : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    dut : entity work.fixed_mul_q8_8
        port map (a => a, b => b, result => result);

    stim : process
        variable errors : integer := 0;
    begin
        for i in 0 to N-1 loop
            a <= A_V(i);
            b <= B_V(i);
            wait for 10 ns;
            if result /= E_V(i) then
                errors := errors + 1;
                report "SALAH pada vektor " & integer'image(i) severity error;
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
