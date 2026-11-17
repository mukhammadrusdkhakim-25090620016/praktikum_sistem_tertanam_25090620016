-- Testbench: master AXI4-Lite manual
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_axi_lite_gpio is
end tb_axi_lite_gpio;

architecture sim of tb_axi_lite_gpio is
    constant CLK_P : time := 10 ns; -- 100 MHz
    signal clk, resetn : std_logic := '0';
    signal awaddr, araddr : std_logic_vector(3 downto 0) := (others => '0');
    signal awvalid, awready, wvalid, wready, bvalid, bready : std_logic := '0';
    signal arvalid, arready, rvalid, rready : std_logic := '0';
    signal wdata, rdata : std_logic_vector(31 downto 0) := (others => '0');
    signal bresp, rresp : std_logic_vector(1 downto 0);
    signal gpio_out, gpio_in : std_logic_vector(15 downto 0) := (others => '0');
    signal done : boolean := false;
    signal errors : integer := 0;

begin
    clk <= not clk after CLK_P/2 when not done else clk;

    dut: entity work.axi_lite_gpio_v1_0
        port map (
            S_AXI_ACLK => clk, S_AXI_ARESETN => resetn,
            S_AXI_AWADDR => awaddr, S_AXI_AWVALID => awvalid, S_AXI_AWREADY => awready,
            S_AXI_WDATA => wdata, S_AXI_WVALID => wvalid, S_AXI_WREADY => wready,
            S_AXI_BRESP => bresp, S_AXI_BVALID => bvalid, S_AXI_BREADY => bready,
            S_AXI_ARADDR => araddr, S_AXI_ARVALID => arvalid, S_AXI_ARREADY => arready,
            S_AXI_RDATA => rdata, S_AXI_RRESP => rresp, S_AXI_RVALID => rvalid,
            S_AXI_RREADY => rready, gpio_out => gpio_out, gpio_in => gpio_in
        );

    stim_process: process
        variable errs : integer := 0;

        procedure axi_write(addr : in integer; data : in std_logic_vector(31 downto 0)) is
        begin
            wait until rising_edge(clk);
            awaddr <= std_logic_vector(to_unsigned(addr, 4)); awvalid <= '1';
            wdata <= data; wvalid <= '1'; bready <= '1';
            loop
                wait until rising_edge(clk);
                exit when awready = '1' and wready = '1';
            end loop;
            awvalid <= '0'; wvalid <= '0';
            while bvalid /= '1' loop
                wait until rising_edge(clk);
            end loop;
            assert bresp = "00" report "BRESP bukan OKAY" severity error;
            bready <= '0';
        end procedure;

        procedure axi_read(addr : in integer; data : out std_logic_vector(31 downto 0)) is
        begin
            wait until rising_edge(clk);
            araddr <= std_logic_vector(to_unsigned(addr, 4)); arvalid <= '1'; rready <= '1';
            loop
                wait until rising_edge(clk);
                exit when arready = '1';
            end loop;
            arvalid <= '0';
            while rvalid /= '1' loop
                wait until rising_edge(clk);
            end loop;
            data := rdata;
            assert rresp = "00" report "RRESP bukan OKAY" severity error;
            rready <= '0';
        end procedure;

        procedure check(name : in string; got, exp : in std_logic_vector) is
        begin
            if got /= exp then
                errs := errs + 1;
                report "GAGAL " & name severity error;
            else
                report "OK " & name severity note;
            end if;
        end procedure;

        variable r : std_logic_vector(31 downto 0);
    begin
        resetn <= '0';
        wait for 5*CLK_P;
        resetn <= '1';
        wait for 3*CLK_P;

        -- 1. Tulis reg0 -> LED
        axi_write(0, x"0000A5A5");
        wait for CLK_P;
        check("gpio_out A5A5 setelah tulis reg0", gpio_out, x"A5A5");

        -- 2. Baca balik reg0
        axi_read(0, r);
        check("baca reg0 = 0000A5A5", r, x"0000A5A5");

        -- 3. Tugas 1: baca status switch di reg1
        gpio_in <= x"1234";
        wait for 2*CLK_P;
        axi_read(4, r);
        check("baca reg1 = status switch 1234", r, x"00001234");

        gpio_in <= x"F00F";
        wait for 2*CLK_P;
        axi_read(4, r);
        check("baca reg1 = status switch F00F", r, x"0000F00F");

        -- 4. reg1 read-only: tulis harus diabaikan
        axi_write(4, x"FFFFFFFF");
        axi_read(4, r);
        check("reg1 tetap switch setelah ditulis", r, x"0000F00F");
        check("gpio_out tidak berubah oleh tulis reg1", gpio_out, x"A5A5");

        -- 5. reg2 dan reg3 R/W 32-bit
        axi_write(8, x"DEADBEEF");
        axi_write(12, x"CAFEBABE");
        axi_read(8, r); check("reg2 = DEADBEEF", r, x"DEADBEEF");
        axi_read(12, r); check("reg3 = CAFEBABE", r, x"CAFEBABE");

        -- 6. Pola LED berjalan (walking pattern)
        for i in 0 to 15 loop
            axi_write(0, std_logic_vector(shift_left(to_unsigned(1, 32), i)));
            wait for CLK_P;
            check("walking bit " & integer'image(i), gpio_out, std_logic_vector(shift_left(to_unsigned(1, 16), i)));
        end loop;

        if errs = 0 then
            report "SEMUA TEST LULUS" severity note;
        else
            report "ADA " & integer'image(errs) & " KESALAHAN" severity failure;
        end if;
        done <= true;
        wait;
    end process;
end sim;
