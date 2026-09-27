----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.09.2026 15:53:07
-- Design Name: 
-- Module Name: tb_leading_one_detector - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_leading_one_detector is
-- Testbench tidak memiliki port
end tb_leading_one_detector;

architecture Behavioral of tb_leading_one_detector is
    component leading_one_detector
        Generic (WIDTH : integer := 8);
        Port ( 
            din   : in  STD_LOGIC_VECTOR (7 downto 0);
            pos   : out STD_LOGIC_VECTOR (2 downto 0);
            valid : out STD_LOGIC
        );
    end component;

    signal din   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal pos   : STD_LOGIC_VECTOR(2 downto 0);
    signal valid : STD_LOGIC;

begin
    uut: leading_one_detector 
        generic map (WIDTH => 8)
        port map (din => din, pos => pos, valid => valid);

    stim_proc: process
    begin
        -- Kasus 1: Tidak ada bit '1'
        din <= "00000000"; wait for 10 ns;
        assert (valid = '0') report "Gagal Kasus 1: valid harusnya '0'" severity error;

        -- Kasus 2: Bit '1' pada posisi index 7
        din <= "10000000"; wait for 10 ns;
        assert (pos = "111" and valid = '1') report "Gagal Kasus 2" severity error;

        -- Kasus 3: Bit '1' terbanyak di posisi index 4 (00010000 -> pos 4 = 100)
        din <= "00010000"; wait for 10 ns;
        assert (pos = "100" and valid = '1') report "Gagal Kasus 3" severity error;

        -- Kasus 4: Multi bit '1', harus deteksi bit paling kiri (index 6)
        din <= "01001100"; wait for 10 ns;
        assert (pos = "110" and valid = '1') report "Gagal Kasus 4" severity error;

        -- Kasus 5: Bit '1' hanya pada posisi index 0
        din <= "00000001"; wait for 10 ns;
        assert (pos = "000" and valid = '1') report "Gagal Kasus 5" severity error;

        wait;
    end process;
end Behavioral;
