library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity seven_seg_driver is
    Port (
        clk     : in  STD_LOGIC;
        data_in : in  STD_LOGIC_VECTOR (7 downto 0);
        seg     : out STD_LOGIC_VECTOR (6 downto 0);
        an      : out STD_LOGIC_VECTOR (3 downto 0)
    );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is
    signal refresh_counter : STD_LOGIC_VECTOR (19 downto 0);
    signal LED_activating_counter: std_logic_vector(1 downto 0);
    signal LED_BCD: std_logic_vector(3 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    LED_activating_counter <= refresh_counter(19 downto 18);

    process(LED_activating_counter, data_in)
    begin
        case LED_activating_counter is
        when "00" =>
            an <= "1110"; -- Digit 0 (Nibble rendah)
            LED_BCD <= data_in(3 downto 0);
        when "01" =>
            an <= "1101"; -- Digit 1 (Nibble tinggi)
            LED_BCD <= data_in(7 downto 4);
        when "10" =>
            an <= "1011"; -- Digit 2 (0)
            LED_BCD <= "0000";
        when "11" =>
            an <= "0111"; -- Digit 3 (0)
            LED_BCD <= "0000";
        when others =>
            an <= "1111";
            LED_BCD <= "0000";
        end case;
    end process;

    process(LED_BCD)
    begin
        case LED_BCD is
        when "0000" => seg <= "1000000"; -- 0
        when "0001" => seg <= "1111001"; -- 1
        when "0010" => seg <= "0100100"; -- 2
        when "0011" => seg <= "0110000"; -- 3
        when "0100" => seg <= "0011001"; -- 4
        when "0101" => seg <= "0010010"; -- 5
        when "0110" => seg <= "0000010"; -- 6
        when "0111" => seg <= "1111000"; -- 7
        when "1000" => seg <= "0000000"; -- 8
        when "1001" => seg <= "0010000"; -- 9
        when "1010" => seg <= "0001000"; -- A
        when "1011" => seg <= "0000011"; -- b
        when "1100" => seg <= "1000110"; -- C
        when "1101" => seg <= "0100001"; -- d
        when "1110" => seg <= "0000110"; -- E
        when "1111" => seg <= "0001110"; -- F
        when others => seg <= "1111111";
        end case;
    end process;
end Behavioral;