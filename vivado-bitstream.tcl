#### Generate Vivado Bitstream ####

# Arguments: $srcs_verilog $srcs_xdc $module_top $platform $bitstream

# Sources of verilog
set srcs_verilog [lindex $argv 0]

# Sources of xdc
set srcs_xdc [lindex $argv 1]

# Top level module name
set module_top [lindex $argv 2]

# Target platform
set platform [lindex $argv 3]

# Bitstream file (.bit)
# We will also create .bin file (for burn) which share the same name with .bit file (for load)
set bitstream [lindex $argv 4]

# Read verilog
read_verilog $srcs_verilog
# Read xdc
read_xdc $srcs_xdc

# Synthesis design
synth_design -top $module_top -part $platform

# Optimize design
opt_design

# Place design
place_design

# Route design
route_design

# Write checkpoint
write_checkpoint $module_top.dcp

# Generate .bit and .bin file
write_bitstream -bin_file -force $bitstream

exit