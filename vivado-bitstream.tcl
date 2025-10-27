set srcs_verilog [lindex $argv 0]
set srcs_xdc [lindex $argv 1]
set module_top [lindex $argv 2]
set platform [lindex $argv 3]
set bitstream [lindex $argv 4]

read_verilog $srcs_verilog
read_xdc $srcs_xdc

synth_design -top $module_top -part $platform
opt_design
place_design
route_design

write_bitstream -bin_file -force $bitstream

exit