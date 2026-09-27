----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.09.2026 19:20:46
-- Design Name: 
-- Module Name: alu4_signed - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity alu4_signed is
    Port ( 
        a        : in  STD_LOGIC_VECTOR (3 downto 0);
        b        : in  STD_LOGIC_VECTOR (3 downto 0);
        opcode   : in  STD_LOGIC;                      -- '0'=tambah, '1'=kurang
        result   : out STD_LOGIC_VECTOR (3 downto 0);
        overflow : out STD_LOGIC
    );
end alu4_signed;

architecture Behavioral of alu4_signed is
    signal a_s, b_s   : signed (3 downto 0);
    signal res_5bit   : signed (4 downto 0);
begin
    a_s <= signed(a);
    b_s <= signed(b);

    process(a_s, b_s, opcode)
    begin
        if opcode = '0' then
            -- Sign extension ke 5-bit sebelum penjumlahan
            res_5bit <= (a_s(3) & a_s) + (b_s(3) & b_s);
        else
            -- Sign extension ke 5-bit sebelum pengurangan
            res_5bit <= (a_s(3) & a_s) - (b_s(3) & b_s);
        end if;
    end process;

    result <= STD_LOGIC_VECTOR(res_5bit(3 downto 0));

    -- Overflow terjadi jika MSB hasil 5-bit tidak sama dengan MSB hasil 4-bit
    overflow <= res_5bit(4) xor res_5bit(3);
end Behavioral;