-- IP custom AXI4-Lite slave: 4 register 32-bit
-- 0x00 reg0 (R/W) : reg0(15:0) -> gpio_out (LED)
-- 0x04 reg1 (R)   : status switch, reg1(15:0) <- gpio_in (Tugas 1)
-- 0x08 reg2 (R/W) : register umum
-- 0x0C reg3 (R/W) : register umum

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axi_lite_gpio_v1_0 is
    Generic (
        C_S_AXI_ADDR_WIDTH : integer := 4;
        C_S_AXI_DATA_WIDTH : integer := 32
    );
    Port (
        S_AXI_ACLK    : in  std_logic;
        S_AXI_ARESETN : in  std_logic;
        S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWVALID : in  std_logic;
        S_AXI_AWREADY : out std_logic;
        S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID  : in  std_logic;
        S_AXI_WREADY  : out std_logic;
        S_AXI_BRESP   : out std_logic_vector(1 downto 0);
        S_AXI_BVALID  : out std_logic;
        S_AXI_BREADY  : in  std_logic;
        S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARVALID : in  std_logic;
        S_AXI_ARREADY : out std_logic;
        S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP   : out std_logic_vector(1 downto 0);
        S_AXI_RVALID  : out std_logic;
        S_AXI_RREADY  : in  std_logic;
        gpio_out      : out std_logic_vector(15 downto 0); -- ke LED
        gpio_in       : in  std_logic_vector(15 downto 0)  -- dari switch (Tugas 1)
    );
end axi_lite_gpio_v1_0;

architecture Behavioral of axi_lite_gpio_v1_0 is
    type reg_t is array (0 to 3) of std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal regs : reg_t := (others => (others => '0'));

    signal awready_i : std_logic := '0';
    signal wready_i  : std_logic := '0';
    signal bvalid_i  : std_logic := '0';
    signal arready_i : std_logic := '0';
    signal rvalid_i  : std_logic := '0';
    signal rdata_i   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others => '0');

begin
    S_AXI_AWREADY <= awready_i;
    S_AXI_WREADY  <= wready_i;
    S_AXI_BVALID  <= bvalid_i;
    S_AXI_BRESP   <= "00"; -- OKAY
    S_AXI_ARREADY <= arready_i;
    S_AXI_RVALID  <= rvalid_i;
    S_AXI_RDATA   <= rdata_i;
    S_AXI_RRESP   <= "00"; -- OKAY

    gpio_out <= regs(0)(15 downto 0);

    -- FSM TULIS
    write_proc: process(S_AXI_ACLK)
        variable idx : integer range 0 to 3;
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                awready_i <= '0';
                wready_i  <= '0';
                bvalid_i  <= '0';
                regs      <= (others => (others => '0'));
            else
                awready_i <= '0';
                wready_i  <= '0';
                if (awready_i = '0' and wready_i = '0' and bvalid_i = '0' and 
                    S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
                    awready_i <= '1';
                    wready_i  <= '1';
                    idx := to_integer(unsigned(S_AXI_AWADDR(3 downto 2)));
                    if idx /= 1 then -- reg1 read-only (status switch)
                        regs(idx) <= S_AXI_WDATA;
                    end if;
                    bvalid_i <= '1';
                elsif bvalid_i = '1' and S_AXI_BREADY = '1' then
                    bvalid_i <= '0';
                end if;
            end if;
        end if;
    end process;

    -- FSM BACA
    read_proc: process(S_AXI_ACLK)
        variable idx : integer range 0 to 3;
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                arready_i <= '0';
                rvalid_i  <= '0';
                rdata_i   <= (others => '0');
            else
                arready_i <= '0';
                if (arready_i = '0' and rvalid_i = '0' and S_AXI_ARVALID = '1') then
                    arready_i <= '1';
                    idx := to_integer(unsigned(S_AXI_ARADDR(3 downto 2)));
                    if idx = 1 then
                        rdata_i <= (31 downto 16 => '0') & gpio_in; -- status switch
                    else
                        rdata_i <= regs(idx);
                    end if;
                    rvalid_i <= '1';
                elsif rvalid_i = '1' and S_AXI_RREADY = '1' then
                    rvalid_i <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
