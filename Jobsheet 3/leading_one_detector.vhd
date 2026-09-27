----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.09.2026 15:51:44
-- Design Name: 
-- Module Name: leading_one_detector - Behavioral
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

entity leading_one_detector is
    Generic (WIDTH : integer := 8);
    Port ( 
        din   : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        pos   : out STD_LOGIC_VECTOR (2 downto 0);
        valid : out STD_LOGIC
    );
end leading_one_detector;

architecture Behavioral of leading_one_detector is
begin
    process(din)
    begin
        pos   <= (others => '0');
        valid <= '0';
        
        for i in WIDTH-1 downto 0 loop
            if din(i) = '1' then
                pos   <= STD_LOGIC_VECTOR(to_unsigned(i, 3));
                valid <= '1';
                exit; -- Keluar dari loop saat bit '1' paling kiri ditemukan
            end if;
        end loop;
    end process;
end Behavioral;