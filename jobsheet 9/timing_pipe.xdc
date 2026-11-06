## Constraint untuk versi PIPELINE (fixed_mul_pipe2 dan fixed_mul_pipe3)
## Periode 10 ns = 100 MHz, sama dengan timing.xdc (versi kombinasional).
create_clock -name sys_clk -period 10.000 [get_ports clk]

set_input_delay  -clock sys_clk 0.000 [get_ports {a[*] b[*]}]
set_output_delay -clock sys_clk 0.000 [get_ports {result[*]}]
