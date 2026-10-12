library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_calculator_fsm is
-- Testbench tidak memiliki port
end tb_calculator_fsm;

architecture behavior of tb_calculator_fsm is

    -- Deklarasi Komponen FSM yang akan diuji
    component calculator_fsm
        Port ( 
            clk : in STD_LOGIC; 
            rst : in STD_LOGIC; 
            sw : in STD_LOGIC_VECTOR(7 downto 0);
            btnU : in STD_LOGIC; 
            btnD : in STD_LOGIC; 
            btnC : in STD_LOGIC;
            alu_result : in STD_LOGIC_VECTOR(7 downto 0);
            reg_a_out : out STD_LOGIC_VECTOR(7 downto 0); 
            reg_b_out : out STD_LOGIC_VECTOR(7 downto 0);
            show_res : out STD_LOGIC_VECTOR(7 downto 0) 
        );
    end component;

    -- Deklarasi Komponen ALU untuk menghitung nilai simulasi
    component alu8
        Port ( 
            A : in STD_LOGIC_VECTOR(7 downto 0); 
            B : in STD_LOGIC_VECTOR(7 downto 0);
            op_sel : in STD_LOGIC_VECTOR(1 downto 0); 
            Result : out STD_LOGIC_VECTOR(7 downto 0) 
        );
    end component;

    -- Sinyal-sinyal internal testbench
    signal clk, rst, btnU, btnD, btnC : STD_LOGIC := '0';
    signal sw : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal op_sel : STD_LOGIC_VECTOR(1 downto 0) := "00";
    
    signal alu_result, reg_a_out, reg_b_out, show_res : STD_LOGIC_VECTOR(7 downto 0);

    -- Periode clock 10 ns (100 MHz)
    constant clk_period : time := 10 ns;

begin

    -- Instansiasi FSM dan ALU
    uut_fsm: calculator_fsm port map ( 
        clk => clk, rst => rst, sw => sw, 
        btnU => btnU, btnD => btnD, btnC => btnC, 
        alu_result => alu_result, 
        reg_a_out => reg_a_out, reg_b_out => reg_b_out, 
        show_res => show_res 
    );
    
    uut_alu: alu8 port map ( 
        A => reg_a_out, B => reg_b_out, op_sel => op_sel, Result => alu_result 
    );

    -- Proses pembuatan Clock
    clk_process: process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Proses Stimulus (Memberikan input buatan)
    stim_proc: process
    begin
        -- Inisialisasi / Reset
        rst <= '1'; wait for 20 ns;
        rst <= '0'; wait for 20 ns;

        -- SKENARIO 1: OPERASI PENJUMLAHAN (10 + 5)
        -- 1. Set sw ke nilai A (10 desimal / 0A hex) dan picu btnU
        sw <= "00001010"; 
        btnU <= '1'; wait for clk_period; btnU <= '0';
        wait for 20 ns;

        -- 2. Set sw ke nilai B (5 desimal / 05 hex) dan picu btnD
        sw <= "00000101"; 
        btnD <= '1'; wait for clk_period; btnD <= '0';
        wait for 20 ns;

        -- 3. Pilih operasi tambah dan picu btnC
        op_sel <= "00"; -- "00" adalah kode tambah (Tugas 1)
        btnC <= '1'; wait for clk_period; btnC <= '0';
        wait for 50 ns;

        -- SKENARIO 2: OPERASI PENGURANGAN (15 - 7)[cite: 3]
        -- Reset FSM terlebih dahulu
        rst <= '1'; wait for 20 ns; rst <= '0'; wait for 20 ns;

        -- Masukkan operand A (15 desimal / 0F hex)
        sw <= "00001111"; 
        btnU <= '1'; wait for clk_period; btnU <= '0'; wait for 20 ns;
        
        -- Masukkan operand B (7 desimal / 07 hex)
        sw <= "00000111"; 
        btnD <= '1'; wait for clk_period; btnD <= '0'; wait for 20 ns;

        -- Pilih operasi kurang dan picu btnC[cite: 3]
        op_sel <= "01"; -- "01" adalah kode kurang (Tugas 1)
        btnC <= '1'; wait for clk_period; btnC <= '0';
        wait for 50 ns;

        -- Hentikan simulasi
        wait;
    end process;

end behavior;