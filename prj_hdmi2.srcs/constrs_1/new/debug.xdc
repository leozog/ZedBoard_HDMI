set_false_path -from [get_pins {hdmi_ctrl_inst/synchronizer_inst1/sync1_reg[0]/C}] -to [get_pins {hdmi_ctrl_inst/synchronizer_inst1/sync2_reg[0]/D}]
set_multicycle_path -from [get_pins {hdmi_ctrl_inst/synchronizer_inst1/sync1_reg[0]/C}] -to [get_pins {hdmi_ctrl_inst/synchronizer_inst1/sync2_reg[0]/D}] 1
