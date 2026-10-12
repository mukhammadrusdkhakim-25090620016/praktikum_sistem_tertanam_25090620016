library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu8 is
    Port ( 
        A      : in  STD_LOGIC_VECTOR (7 downto 0);
        B      : in  STD_LOGIC_VECTOR (7 downto 0);
        op_sel : in  STD_LOGIC_VECTOR (1 downto 0);
        Result : out STD_LOGIC_VECTOR (7 downto 0)
    );
end alu8;

architecture Behavioral of alu8 is
    signal mult_full : STD_LOGIC_VECTOR (15 downto 0);
begin
    -- Perkalian 8-bit x 8-bit menggunakan unsigned
    mult_full <= std_logic_vector(unsigned(A) * unsigned(B));

    process(A, B, op_sel, mult_full)
    begin
        case op_sel is
            when "00" => 
                Result <= std_logic_vector(unsigned(A) + unsigned(B)); -- Penjumlahan
            when "01" => 
                Result <= std_logic_vector(unsigned(A) - unsigned(B)); -- Pengurangan
            when "10" => 
                if B = "00000000" then
                    Result <= (others => '0'); -- Mencegah error pembagian dengan nol
                else
                    Result <= std_logic_vector(unsigned(A) / unsigned(B)); -- Pembagian
                end if;
            when "11" => 
                Result <= mult_full(7 downto 0); -- Perkalian (mengambil 8-bit terbawah)
            when others => 
                Result <= (others => '0');
        end case;
    end process;
end Behavioral;