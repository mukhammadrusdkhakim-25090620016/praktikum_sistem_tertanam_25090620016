library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_mux8to1 is
end tb_mux8to1;

architecture sim of tb_mux8to1 is
    signal sel_tb : STD_LOGIC_VECTOR (2 downto 0);
    signal in0_tb, in1_tb, in2_tb, in3_tb, 
           in4_tb, in5_tb, in6_tb, in7_tb, y_tb : STD_LOGIC_VECTOR (3 downto 0);
begin
    DUT: entity work.mux8to1
        port map (
            sel => sel_tb,
            in0 => in0_tb, in1 => in1_tb, in2 => in2_tb, in3 => in3_tb,
            in4 => in4_tb, in5 => in5_tb, in6 => in6_tb, in7 => in7_tb,
            y   => y_tb
        );

    stim_proc: process
    begin
        -- Inisialisasi nilai input data 0 hingga 7
        in0_tb <= "0000"; -- 0
        in1_tb <= "0001"; -- 1
        in2_tb <= "0010"; -- 2
        in3_tb <= "0011"; -- 3
        in4_tb <= "0100"; -- 4
        in5_tb <= "0101"; -- 5
        in6_tb <= "0110"; -- 6
        in7_tb <= "0111"; -- 7

        -- Pengujian 8 skenario selektor
        sel_tb <= "000"; wait for 20 ns;
        sel_tb <= "001"; wait for 20 ns;
        sel_tb <= "010"; wait for 20 ns;
        sel_tb <= "011"; wait for 20 ns;
        sel_tb <= "100"; wait for 20 ns;
        sel_tb <= "101"; wait for 20 ns;
        sel_tb <= "110"; wait for 20 ns;
        sel_tb <= "111"; wait for 20 ns;

        wait;
    end process;
end sim;