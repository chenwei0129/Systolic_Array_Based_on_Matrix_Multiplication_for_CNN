set company "CIC"
set designer "Student"
set search_path {CAD_path/CBDK013_TSMC_Artisan/CIC/SynopsysDC/db 
    /home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/SynopsysDC/lib \
    /home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/SynopsysDC/db \
    $search_path }
set link_library "typical.db slow.db fast.db dw_foundation.sldb"
set target_library "typical.db slow.db fast.db"
set symbol_library "generic.sdb"
set synthetic_library "dw_foundation.sldb"

read_file -format verilog {./top.v}
current_design top

# write -format verilog -hierarchy -output ALU_GTECH.v

set cycle  20         ;#clock period defined by designer

create_clock -period $cycle [get_ports  clk_i]
set_dont_touch_network      [get_clocks clk_i]
set_fix_hold                [get_clocks clk_i]
set_clock_uncertainty  0.1  [get_clocks clk_i]
set_clock_latency      0.5  [get_clocks clk_i]

set_input_delay  [ expr $cycle*0.5 ] -clock clk_i [all_inputs]
set_output_delay [ expr $cycle*0.5 ] -clock clk_i [all_outputs] 
set_load         0.05     [all_outputs]

set_operating_conditions -max_library slow -max slow
set_wire_load_model -name tsmc13_wl10 -library slow                    

set_max_fanout 20 [all_inputs]

check_design
uniquify
set_fix_multiple_port_nets -all -buffer_constants  [get_designs *]
set_fix_hold [all_clocks]

#set_optimize_registers

#compile_ultra -retime
compile_ultra

#set_operating_conditions "typical" -library "typical"
#set_wire_load_model -name "ForQA" -library "typical"
#set_wire_load_mode "segmented"

#set_input_delay -clock clk_i 1 -clock clk_i [all_inputs]
#set_output_delay -clock clk_i 5 [all_outputs]

#set_boundary_optimization "*"
#set_fix_multiple_port_nets -all -buffer_constant
#set_max_area 0
#set_max_fanout 8 top
#set_max_transition 1 top

write -format ddc     -hierarchy -output "top_syn.ddc"
write_sdf top_syn.sdf
write_file -format verilog -hierarchy -output top_syn.v
report_area > area.log
report_timing > timing.log
report_qor   >  cordic_syn.qor

#write -hierarchy -format ddc
write_sdc top_syn.sdc
#write_sdf -version 2.1 top.sdf
#write -format verilog -hierarchy -output top_syn.v

exit