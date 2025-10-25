set bitstream [lindex $argv 0]

open_hw
connect_hw_server
open_hw_target

set hw_device [lindex [get_hw_devices] 0]

set_property PROGRAM.FILE $bitstream $hw_device
program_hw_device $hw_device

close_hw_target
disconnect_hw_server
close_hw

exit