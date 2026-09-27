----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.09.2026 13:54:55
-- Design Name: 
-- Module Name: alu4 - Behavioral
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

entity alu4 is
    Port ( 
        a      : in  STD_LOGIC_VECTOR (3 downto 0);
        b      : in  STD_LOGIC_VECTOR (3 downto 0);
        opcode : in  STD_LOGIC; -- '0' = tambah, '1' = kurang
        result : out STD_LOGIC_VECTOR (3 downto 0);
        carry  : out STD_LOGIC
    );
end alu4;

architecture Behavioral of alu4 is
    signal a_u, b_u : unsigned (3 downto 0);
    signal sum_ext : unsigned (4 downto 0);
begin
    a_u <= unsigned(a);
    b_u <= unsigned(b);

    process(a_u, b_u, opcode)
    begin
        if opcode = '0' then
            sum_ext <= ('0' & a_u) + ('0' & b_u);
        else
            sum_ext <= ('0' & a_u) - ('0' & b_u);
        end if;
    end process;

    result <= STD_LOGIC_VECTOR(sum_ext(3 downto 0));
    carry  <= sum_ext(4);
end Behavioral;