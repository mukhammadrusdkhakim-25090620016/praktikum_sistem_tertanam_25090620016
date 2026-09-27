----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.09.2026 13:56:16
-- Design Name: 
-- Module Name: tb_alu4 - Behavioral
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

entity tb_alu4 is
end tb_alu4;

architecture Behavioral of tb_alu4 is
    component alu4
        Port (
            a      : in  STD_LOGIC_VECTOR (3 downto 0);
            b      : in  STD_LOGIC_VECTOR (3 downto 0);
            opcode : in  STD_LOGIC;
            result : out STD_LOGIC_VECTOR (3 downto 0);
            carry  : out STD_LOGIC
        );
    end component;

    signal a, b   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal opcode : STD_LOGIC := '0';
    signal result : STD_LOGIC_VECTOR(3 downto 0);
    signal carry  : STD_LOGIC;

begin
    uut: alu4 port map (a => a, b => b, opcode => opcode, result => result, carry => carry);

    stim_proc: process
    begin
        -- Uji Penjumlahan (Opcode = '0'): 7 + 1 = 8
        a <= "0111"; b <= "0001"; opcode <= '0'; wait for 10 ns;
        assert (result = "1000" and carry = '0') report "Gagal Penjumlahan 1" severity error;

        -- Uji Penjumlahan Carry: 15 + 1 = 16 (Result=0, Carry=1)
        a <= "1111"; b <= "0001"; opcode <= '0'; wait for 10 ns;
        assert (result = "0000" and carry = '1') report "Gagal Penjumlahan Carry" severity error;

        -- Uji Pengurangan (Opcode = '1'): 8 - 3 = 5
        a <= "1000"; b <= "0011"; opcode <= '1'; wait for 10 ns;
        assert (result = "0101") report "Gagal Pengurangan 1" severity error;

        wait;
    end process;
end Behavioral;
