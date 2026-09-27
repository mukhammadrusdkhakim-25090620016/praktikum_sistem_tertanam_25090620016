----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.09.2026 19:21:44
-- Design Name: 
-- Module Name: tb_alu4_signed - Behavioral
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

entity tb_alu4_signed is
end tb_alu4_signed;

architecture Behavioral of tb_alu4_signed is
    signal a        : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal b        : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal opcode   : STD_LOGIC := '0';
    signal result   : STD_LOGIC_VECTOR(3 downto 0);
    signal overflow : STD_LOGIC;
begin
    uut: entity work.alu4_signed
        port map (
            a        => a,
            b        => b,
            opcode   => opcode,
            result   => result,
            overflow => overflow
        );

    stim_proc: process
    begin
        -- Kasus 1: Normal (3 + 2 = 5) -> Overflow = '0'
        a <= "0011"; b <= "0010"; opcode <= '0';
        wait for 20 ns;

        -- Kasus 2: Overflow Positif (+5 + +4 = +9) -> Overflow = '1', Result = "1001" (-7)
        a <= "0101"; b <= "0100"; opcode <= '0';
        wait for 20 ns;

        -- Kasus 3: Overflow Negatif (-6 + -4 = -10) -> Overflow = '1', Result = "0110" (+6)
        a <= "1010"; b <= "1100"; opcode <= '0';
        wait for 20 ns;

        wait;
    end process;
end Behavioral;