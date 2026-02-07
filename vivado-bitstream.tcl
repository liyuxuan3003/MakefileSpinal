#### Generate Vivado Bitstream ####

# Sources of verilog
set srcs_verilog [lindex $argv 0]

# Sources of xdc
set srcs_xdc [lindex $argv 1]

# Top level module name
set module_top [lindex $argv 2]

# Target platform
set platform [lindex $argv 3]

# Bitstream (.bit)
# We will also create .bin file (for burn) which share the same name with .bit file (for load)
set bitstream [lindex $argv 4]

# Netlist
set netlist [lindex $argv 5]

# Checkpoint
set checkpoint [lindex $argv 6]

# Report timing summary
set rpt_timing_summary [lindex $argv 7]

# Report timing
set rpt_timing [lindex $argv 8]

# Report clock
set rpt_clock [lindex $argv 9]

# Report utili
set rpt_utili [lindex $argv 10]

# Report power
set rpt_power [lindex $argv 11]

# Report drc
set rpt_drc [lindex $argv 12]

# Read verilog
read_verilog $srcs_verilog
# Read xdc
read_xdc $srcs_xdc

# Synthesis design
synth_design -top $module_top -part $platform

# Write netlist
write_verilog -force $netlist

# Optimize design
opt_design

# Place design
place_design

# Route design
route_design

# Generate .bit and .bin file
write_bitstream -bin_file -force $bitstream

# Write checkpoint
write_checkpoint -force $checkpoint

# Report timing summary
report_timing_summary -file $rpt_timing_summary

# Report timing
report_timing -sort_by group -max_paths 100 -path_type summary -file $rpt_timing

# Report clock
report_clock_utilization -file $rpt_clock

# Report utili
report_utilization -file $rpt_utili

# Report power
report_power -file $rpt_power

# Report drc
report_drc -file $rpt_drc

exit
