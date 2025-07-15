if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# Compile VHDL files
vcom src/UART_TX.vhd
vcom src/UART_RX.vhd
vcom src/UART_TOP.vhd
vcom TEST_bench/UART_tb.vhd

# Simulate the testbench
vsim work.UART_TOP_tb

view wave
add wave -position insertpoint sim:/uart_top_tb/*

run 3.4ms
wave zoom full
