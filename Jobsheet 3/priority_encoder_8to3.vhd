----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.09.2026 17:32:37
-- Design Name: 
-- Module Name: priority_encoder_8to3 - Behavioral
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

entity priority_encoder_8to3 is
    Port ( 
        sw  : in  STD_LOGIC_VECTOR (7 downto 0); -- Input 8-bit dari sakelar sw[7..0]
        led : out STD_LOGIC_VECTOR (3 downto 0)  -- Output 4-bit: led[2..0]=posisi, led[3]=valid
    );
end priority_encoder_8to3;

architecture Behavioral of priority_encoder_8to3 is
begin
    process(sw)
    begin
        -- Default awal: jika semua switch '0', pos = "000" dan valid = '0'
        led <= (others => '0');

        -- Loop dari bit tertinggi (7) ke bit terendah (0)
        for i in 7 downto 0 loop
            if sw(i) = '1' then
                led(2 downto 0) <= STD_LOGIC_VECTOR(to_unsigned(i, 3)); -- Simpan posisi bit '1'
                led(3)          <= '1';                                  -- Flag valid = '1'
                exit;                                                    -- Hentikan loop (prioritas tertinggi)
            end if;
        end loop;
    end process;
end Behavioral;