library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_reg8 is
    Port (
        clk  : in  STD_LOGIC;
        btnU : in  STD_LOGIC; -- rst (Reset)
        btnC : in  STD_LOGIC; -- en (Enable)
        sw   : in  STD_LOGIC_VECTOR (7 downto 0); -- d (Data Input)
        led  : out STD_LOGIC_VECTOR (7 downto 0)  -- q (Data Output)
    );
end top_reg8;

architecture Behavioral of top_reg8 is
begin
    u_reg8: entity work.reg8_en
        port map (
            clk => clk,
            rst => btnU,
            en  => btnC,
            d   => sw,
            q   => led
        );
end Behavioral;