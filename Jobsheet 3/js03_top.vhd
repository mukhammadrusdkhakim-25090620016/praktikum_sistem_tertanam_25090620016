----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.09.2026 14:21:10
-- Design Name: 
-- Module Name: js03_top - Behavioral
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

entity js03_top is
    Port ( 
        sw  : in  STD_LOGIC_VECTOR (15 downto 0); -- sw[3..0]=a, sw[7..4]=b, sw[15..14]=opcode
        led : out STD_LOGIC_VECTOR (7 downto 0)   -- led[7..0]=result (8-bit)
    );
end js03_top;

architecture Behavioral of js03_top is
    component alu4 is
        Port ( 
            a      : in  STD_LOGIC_VECTOR (3 downto 0);
            b      : in  STD_LOGIC_VECTOR (3 downto 0);
            opcode : in  STD_LOGIC_VECTOR (1 downto 0);
            result : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;
begin
    uut: alu4 port map (
        a      => sw(3 downto 0),
        b      => sw(7 downto 4),
        opcode => sw(15 downto 14),
        result => led(7 downto 0)
    );
end Behavioral;