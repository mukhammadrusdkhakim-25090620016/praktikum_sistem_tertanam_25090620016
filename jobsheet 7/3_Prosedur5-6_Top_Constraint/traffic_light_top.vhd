library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_light_top is
    Generic ( CLK_FREQ_HZ : integer := 100_000_000 );
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;                      -- btnC
           led : out STD_LOGIC_VECTOR(5 downto 0) );
end traffic_light_top;

architecture Structural of traffic_light_top is
    signal tick : std_logic;
begin
    u_tick : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => CLK_FREQ_HZ )
        port map ( clk => clk, rst => rst, tick => tick );

    u_fsm : entity work.traffic_light_fsm
        port map ( clk => clk, rst => rst, tick => tick, led => led );
end Structural;
