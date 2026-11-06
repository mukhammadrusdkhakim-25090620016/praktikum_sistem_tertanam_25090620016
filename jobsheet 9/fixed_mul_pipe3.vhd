library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Tugas 1: pipeline 3 tahap. Latency = 3 siklus clock.
--   Tahap 1 : perkalian parsial  a*b[7:0] dan a*b[15:8]  (dua pengali 16x8)
--   Tahap 2 : penjumlahan        p_lo + (p_hi << 8)
--   Tahap 3 : scaling            ambil bit [23:8] -> Q8.8
-- Dasar: a*b = a*b_lo + (a*b_hi)*2^8
entity fixed_mul_pipe3 is
    Port ( clk    : in  STD_LOGIC;
           a      : in  STD_LOGIC_VECTOR (15 downto 0);
           b      : in  STD_LOGIC_VECTOR (15 downto 0);
           result : out STD_LOGIC_VECTOR (15 downto 0));
end fixed_mul_pipe3;

architecture Behavioral of fixed_mul_pipe3 is
    signal p_lo       : unsigned(23 downto 0);           -- register tahap 1
    signal p_hi       : unsigned(23 downto 0);           -- register tahap 1
    signal sum_reg    : unsigned(31 downto 0);           -- register tahap 2
    signal result_reg : STD_LOGIC_VECTOR(15 downto 0);   -- register tahap 3
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Tahap 1
            p_lo <= unsigned(a) * unsigned(b(7 downto 0));
            p_hi <= unsigned(a) * unsigned(b(15 downto 8));
            -- Tahap 2
            sum_reg <= resize(p_lo, 32) + shift_left(resize(p_hi, 32), 8);
            -- Tahap 3
            result_reg <= STD_LOGIC_VECTOR(sum_reg(23 downto 8));
        end if;
    end process;
    result <= result_reg;
end Behavioral;
