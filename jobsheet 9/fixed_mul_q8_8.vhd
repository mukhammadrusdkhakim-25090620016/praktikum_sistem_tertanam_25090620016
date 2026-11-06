library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Kode 9.1: perkalian Q8.8 x Q8.8 -> Q8.8 (kombinasional murni)
entity fixed_mul_q8_8 is
    Port ( a      : in  STD_LOGIC_VECTOR (15 downto 0);  -- Q8.8
           b      : in  STD_LOGIC_VECTOR (15 downto 0);  -- Q8.8
           result : out STD_LOGIC_VECTOR (15 downto 0)); -- Q8.8
end fixed_mul_q8_8;

architecture Behavioral of fixed_mul_q8_8 is
    signal product : unsigned(31 downto 0);  -- Q16.16 (hasil kali penuh)
begin
    product <= unsigned(a) * unsigned(b);
    -- geser 8 bit ke kanan (buang 8 bit pecahan LSB), ambil 16 bit
    result  <= STD_LOGIC_VECTOR(product(23 downto 8));
end Behavioral;
