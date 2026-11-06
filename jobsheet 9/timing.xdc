## Constraint untuk perbandingan Timing Summary (Prosedur 3-4 & Tugas 1)
## Dipakai untuk ketiga top-level: fixed_mul_q8_8 / fixed_mul_pipe2 / fixed_mul_pipe3
## Periode 10 ns = 100 MHz. Untuk eksperimen tambahan ganti ke 5.000 (200 MHz).
set clk_period 10.000

## Clock virtual: referensi untuk input/output delay.
## (Desain kombinasional tidak punya port clk, jadi butuh ini agar WNS terhitung.)
create_clock -name vclk -period $clk_period

## Clock nyata hanya dibuat jika port clk ada (versi pipeline)
if {[llength [get_ports -quiet clk]] > 0} {
    create_clock -name sys_clk -period $clk_period [get_ports clk]
}

set_input_delay  -clock vclk 0.000 [get_ports {a[*] b[*]}]
set_output_delay -clock vclk 0.000 [get_ports {result[*]}]
