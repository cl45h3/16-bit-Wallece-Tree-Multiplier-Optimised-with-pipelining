
create_clock -name clk -period 4.000 [get_ports clk]


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]

set_input_delay  0.0 [get_ports clk] -clock [get_clocks clk]
set_output_delay 0.0 [get_ports clk] -clock [get_clocks clk]


set_property ASYNC_REG TRUE [get_ports rst]
set_property DONT_TOUCH true [get_ports rst]

set_property PACKAGE_PIN <pinA0>  [get_ports {a[0]}]
set_property PACKAGE_PIN <pinA1>  [get_ports {a[1]}]
