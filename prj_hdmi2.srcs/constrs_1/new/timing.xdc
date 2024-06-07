create_clock -period 10.000 -name clk100MHz [get_ports clk]
set_property CLOCK_BUFFER_TYPE BUFG [get_ports clk]