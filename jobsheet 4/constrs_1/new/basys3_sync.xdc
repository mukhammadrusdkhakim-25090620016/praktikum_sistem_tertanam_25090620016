## Clock Signal (100 MHz pada pin W5)
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Button Central (btnC)
set_property PACKAGE_PIN U18 [get_ports btnC]						
	set_property IOSTANDARD LVCMOS33 [get_ports btnC]

## LED 0 (led0)
set_property PACKAGE_PIN U16 [get_ports led0]						
	set_property IOSTANDARD LVCMOS33 [get_ports led0]