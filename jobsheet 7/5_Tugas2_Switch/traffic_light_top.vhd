library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_light_top is
    Generic ( CLK_FREQ_HZ : integer := 100_000_000 );
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;                        -- btnC
           sw  : in  STD_LOGIC_VECTOR(3 downto 0);     -- sw(3 downto 0)
           led : out STD_LOGIC_VECTOR(5 downto 0) );
end traffic_light_top;

architecture Structural of traffic_light_top is
    signal tick     : std_logic;
    signal sw_meta  : std_logic_vector(3 downto 0) := (others => '0');
    signal sw_sync  : std_logic_vector(3 downto 0) := (others => '0');
begin
    -- sinkronisasi 2-FF untuk input switch (asinkron terhadap clk)
    process(clk)
    begin
        if rising_edge(clk) then
            sw_meta <= sw;
            sw_sync <= sw_meta;
        end if;
    end process;

    u_tick : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => CLK_FREQ_HZ )
        port map ( clk => clk, rst => rst, tick => tick );

    u_fsm : entity work.traffic_light_fsm
        port map ( clk => clk, rst => rst, tick => tick, sw => sw_sync, led => led );
end Structural;
