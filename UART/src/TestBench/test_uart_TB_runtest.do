SetActiveLib -work
comp -include "$dsn\src\UART_util.vhd" 
comp -include "$dsn\src\UART_TX.asf" 
comp -include "$dsn\src\UART_RX.asf" 
comp -include "$dsn\src\Test_UART.bde" 
comp -include "$dsn\src\TestBench\test_uart_TB.vhd" 
asim TESTBENCH_FOR_test_uart 
wave 
wave -noreg UART_CLK
wave -noreg UART_RESET
wave -noreg BAUD_SEL
wave -noreg UART_RxD
wave -noreg /test_uart_tb/UUT/UART_DATA
wave -noreg /test_uart_tb/UUT/DATA_VALID
wave -noreg UART_TxD

# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\test_uart_TB_tim_cfg.vhd" 
# asim TIMING_FOR_test_uart 	
run

