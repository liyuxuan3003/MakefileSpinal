#### Program Vivado FPGA ####

# Arguments: $bitstream $flash $mode

# Bitstream file
# .bit for mode == load
# .bin for mode == burn
set bitstream [lindex $argv 0]

# Flash id
set flash [lindex $argv 1]

# Program mode: load / burn
# load -> program on jtag
# burn -> program on flash
set mode [lindex $argv 2]

# Connect hardware
open_hw_manager
connect_hw_server
open_hw_target

# Get hardware
set hw_device [lindex [get_hw_devices] 0]

# Get flash
set mem_device [lindex [get_cfgmem_parts $flash] 0]
create_hw_cfgmem -hw_device $hw_device $mem_device
set hw_cfgmem [get_property PROGRAM.HW_CFGMEM $hw_device]

# If mode == load
if {[string equal $mode "load"]} {
    # Set bitstream path
    set_property PROGRAM.FILE $bitstream $hw_device
    # Program device (jtag)
    program_hw_device $hw_device
}

# If mode == burn
if {[string equal $mode "burn"]} {
    # Set some property
    set_property PROGRAM.BLANK_CHECK 0 $hw_cfgmem
    set_property PROGRAM.ERASE 1 $hw_cfgmem
    set_property PROGRAM.CFG_PROGRAM 1 $hw_cfgmem
    set_property PROGRAM.VERIFY 1 $hw_cfgmem
    set_property PROGRAM.CHECKSUM 0 $hw_cfgmem
    set_property PROGRAM.ADDRESS_RANGE {use_file} $hw_cfgmem
    # Set bitstream path
    set_property PROGRAM.FILES $bitstream $hw_cfgmem
    # Create bitstream object
    set hw_cfgmem_bitfile [get_property PROGRAM.HW_CFGMEM_BITFILE $hw_device]
    create_hw_bitstream -hw_device $hw_device $hw_cfgmem_bitfile
    # We don't really understand these two commands, seems to do jtag program and then refresh?
    # But it is necessary before flash program, or it will cause error.
    program_hw_device $hw_device
    refresh_hw_device $hw_device
    # Program device (flash)
    program_hw_cfgmem -hw_cfgmem $hw_cfgmem
}

# Disconnect hardware
close_hw_target
disconnect_hw_server
close_hw_manager

exit