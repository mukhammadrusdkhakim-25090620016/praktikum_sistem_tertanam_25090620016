library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity calculator_top is
    Port (
        clk      : in  STD_LOGIC;                    
        sw       : in  STD_LOGIC_VECTOR (15 downto 0); 
        btnU     : in  STD_LOGIC;                    
        btnD     : in  STD_LOGIC;                    
        btnC     : in  STD_LOGIC;                    
        btnL     : in  STD_LOGIC;                    
        
        seg      : out STD_LOGIC_VECTOR (6 downto 0); 
        an       : out STD_LOGIC_VECTOR (3 downto 0)  
    );
end calculator_top;

architecture Structural of calculator_top is

    -- Isyarat dalaman untuk menyambungkan Debounce -> Edge Detect -> FSM
    signal btnU_deb, btnD_deb, btnC_deb, btnL_deb : STD_LOGIC;
    signal btnU_pulse, btnD_pulse, btnC_pulse, rst_clean : STD_LOGIC;

    signal reg_a_val, reg_b_val : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_out_val          : STD_LOGIC_VECTOR(7 downto 0);
    signal result_to_disp       : STD_LOGIC_VECTOR(7 downto 0);

    -- Komponen dari fail-fail yang telah anda buat
    component debounce is
        Port ( clk : in STD_LOGIC; btn_in : in STD_LOGIC; btn_out : out STD_LOGIC );
    end component;

    component edge_detect is
        Port ( clk : in STD_LOGIC; sig_in : in STD_LOGIC; pulse_out : out STD_LOGIC );
    end component;

    component alu8 is
        Port ( A : in STD_LOGIC_VECTOR (7 downto 0); B : in STD_LOGIC_VECTOR (7 downto 0);
               op_sel : in STD_LOGIC_VECTOR (1 downto 0); Result : out STD_LOGIC_VECTOR (7 downto 0) );
    end component;

    component calculator_fsm is
        Port ( clk : in STD_LOGIC; rst : in STD_LOGIC; sw : in STD_LOGIC_VECTOR (7 downto 0);
               btnU : in STD_LOGIC; btnD : in STD_LOGIC; btnC : in STD_LOGIC;
               alu_result : in STD_LOGIC_VECTOR (7 downto 0); reg_a_out : out STD_LOGIC_VECTOR (7 downto 0);
               reg_b_out : out STD_LOGIC_VECTOR (7 downto 0); show_res : out STD_LOGIC_VECTOR (7 downto 0) );
    end component;

    component seven_seg_driver is
        Port ( clk : in STD_LOGIC; data_in : in STD_LOGIC_VECTOR (7 downto 0);
               seg : out STD_LOGIC_VECTOR (6 downto 0); an : out STD_LOGIC_VECTOR (3 downto 0) );
    end component;

begin

    -- Sambungan secara bersiri: Tombol -> Debounce -> Edge Detect
    deb_U : debounce port map (clk => clk, btn_in => btnU, btn_out => btnU_deb);
    edg_U : edge_detect port map (clk => clk, sig_in => btnU_deb, pulse_out => btnU_pulse);

    deb_D : debounce port map (clk => clk, btn_in => btnD, btn_out => btnD_deb);
    edg_D : edge_detect port map (clk => clk, sig_in => btnD_deb, pulse_out => btnD_pulse);

    deb_C : debounce port map (clk => clk, btn_in => btnC, btn_out => btnC_deb);
    edg_C : edge_detect port map (clk => clk, sig_in => btnC_deb, pulse_out => btnC_pulse);

    deb_L : debounce port map (clk => clk, btn_in => btnL, btn_out => btnL_deb);
    edg_L : edge_detect port map (clk => clk, sig_in => btnL_deb, pulse_out => rst_clean);

    -- Sambungan Unit Kawalan FSM
    fsm_inst : calculator_fsm
        port map (
            clk => clk, rst => rst_clean, sw => sw(7 downto 0),
            btnU => btnU_pulse, btnD => btnD_pulse, btnC => btnC_pulse,
            alu_result => alu_out_val, reg_a_out => reg_a_val, reg_b_out => reg_b_val, show_res => result_to_disp
        );

    -- Sambungan ALU 8-bit[cite: 3]
    alu_inst : alu8
        port map (
            A => reg_a_val, B => reg_b_val, op_sel => sw(15 downto 14), Result => alu_out_val
        );

    -- Sambungan Pemacu Paparan[cite: 3]
    disp_inst : seven_seg_driver
        port map (
            clk => clk, data_in => result_to_disp, seg => seg, an => an
        );

end Structural;