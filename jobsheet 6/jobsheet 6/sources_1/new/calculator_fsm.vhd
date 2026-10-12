library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity calculator_fsm is
    Port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        sw         : in  STD_LOGIC_VECTOR (7 downto 0); -- Input operand dari switch
        btnU       : in  STD_LOGIC; -- Sinyal pulse untuk Load A
        btnD       : in  STD_LOGIC; -- Sinyal pulse untuk Load B
        btnC       : in  STD_LOGIC; -- Sinyal pulse untuk Hitung (Enter)
        alu_result : in  STD_LOGIC_VECTOR (7 downto 0); -- Hasil dari ALU
        
        reg_a_out  : out STD_LOGIC_VECTOR (7 downto 0); -- Ke input A ALU
        reg_b_out  : out STD_LOGIC_VECTOR (7 downto 0); -- Ke input B ALU
        show_res   : out STD_LOGIC_VECTOR (7 downto 0)  -- Ke 7-Segment Driver
    );
end calculator_fsm;

architecture Behavioral of calculator_fsm is
    -- Definisi state sesuai kerangka[cite: 2]
    type calc_state is (S_WAIT_A, S_WAIT_B, S_COMPUTE, S_SHOW);
    signal state, next_state : calc_state := S_WAIT_A;
    
    -- Register internal untuk menyimpan data
    signal reg_a, next_reg_a : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal reg_b, next_reg_b : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal res_reg, next_res_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin
    -- PROCESS 1 (SINKRON): Hanya memperbarui register state dan data memori[cite: 1]
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= S_WAIT_A;
                reg_a <= (others => '0');
                reg_b <= (others => '0');
                res_reg <= (others => '0');
            else
                state <= next_state;
                reg_a <= next_reg_a;
                reg_b <= next_reg_b;
                res_reg <= next_res_reg;
            end if;
        end if;
    end process;

    -- PROCESS 2 (KOMBINASIONAL): Menghitung next_state dan logika transisi[cite: 1]
    process(state, reg_a, reg_b, res_reg, sw, btnU, btnD, btnC, alu_result)
    begin
        -- Nilai default agar tidak terbentuk latch memori
        next_state <= state;
        next_reg_a <= reg_a;
        next_reg_b <= reg_b;
        next_res_reg <= res_reg;
        
        -- Menyambungkan register internal ke port output
        reg_a_out <= reg_a;
        reg_b_out <= reg_b;
        show_res  <= res_reg;

        -- Mesin State Moore
        case state is
            when S_WAIT_A =>
                -- Menunggu btnU untuk memuat operand A[cite: 2]
                if btnU = '1' then
                    next_reg_a <= sw;
                    next_state <= S_WAIT_B;
                end if;
                
            when S_WAIT_B =>
                -- Menunggu btnD untuk memuat operand B[cite: 2]
                if btnD = '1' then
                    next_reg_b <= sw;
                end if;
                -- Menunggu btnC untuk memicu proses komputasi[cite: 2]
                if btnC = '1' then
                    next_state <= S_COMPUTE;
                end if;
                
            when S_COMPUTE =>
                -- Datapath ALU dipicu, hasil disimpan[cite: 2]
                next_res_reg <= alu_result;
                next_state <= S_SHOW;
                
            when S_SHOW =>
                show_res <= res_reg; -- Tampilkan hasil[cite: 2]
                -- FSM akan tetap di state ini sampai di-reset.
                -- Opsional: Anda bisa tambahkan if btnU='1' then next_state <= S_WAIT_A; agar bisa loop.
                
        end case;
    end process;

end Behavioral;