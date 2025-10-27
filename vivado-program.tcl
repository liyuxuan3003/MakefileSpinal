set bitstream [lindex $argv 0]
set flash [lindex $argv 1]
set mode [lindex $argv 2]

open_hw_manager
connect_hw_server
open_hw_target


# # set devPart [get_property PART [current_hw_device]]
# # set cfgParts [get_cfgmem_parts -of [get_parts $devPart]]
# create_hw_cfgmem -hw_device [current_hw_device] $flash
# set cfgMem [current_hw_cfgmem]
# set_property PROGRAM.FILE $bitstream $cfgMem
# set_property PROGRAM.ADDRESS_RANGE  {use_file} $cfgMem
# set_property PROGRAM.BLANK_CHECK  1 $cfgMem
# set_property PROGRAM.ERASE  1 $cfgMem
# set_property PROGRAM.CFG_PROGRAM  1 $cfgMem
# set_property PROGRAM.VERIFY  1 $cfgMem
# program_hw_cfgmem $cfgMem




set hw_device [lindex [get_hw_devices] 0]

set mem_device [lindex [get_cfgmem_parts $flash] 0]
create_hw_cfgmem -hw_device $hw_device $mem_device

set hw_cfgmem [get_property PROGRAM.HW_CFGMEM $hw_device]

if {[string equal $mode "load"]} {
    set_property PROGRAM.FILE $bitstream $hw_device
    program_hw_device $hw_device
}

if {[string equal $mode "burn"]} {
    set_property PROGRAM.BLANK_CHECK 0 $hw_cfgmem
    set_property PROGRAM.ERASE 1 $hw_cfgmem
    set_property PROGRAM.CFG_PROGRAM 1 $hw_cfgmem
    set_property PROGRAM.VERIFY 1 $hw_cfgmem
    set_property PROGRAM.CHECKSUM 0 $hw_cfgmem
    set_property PROGRAM.FILES $bitstream $hw_cfgmem
    set_property PROGRAM.ADDRESS_RANGE {use_file} $hw_cfgmem
    # create_hw_bitstream -hw_device [lindex [get_hw_devices xc7a35t_0] 0] [get_property PROGRAM.HW_CFGMEM_BITFILE [ lindex [get_hw_devices xc7a35t_0] 0]]; program_hw_devices [lindex [get_hw_devices xc7a35t_0] 0]; refresh_hw_device [lindex [get_hw_devices xc7a35t_0] 0];
    # program_hw_cfgmem -hw_cfgmem [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
    set hw_cfgmem_bitfile [get_property PROGRAM.HW_CFGMEM_BITFILE $hw_device]
    create_hw_bitstream -hw_device $hw_device $hw_cfgmem_bitfile
    program_hw_device $hw_device
    refresh_hw_device $hw_device
    program_hw_cfgmem -hw_cfgmem $hw_cfgmem
}

# create_hw_cfgmem -hw_device [get_hw_devices xc7a35t_0] -mem_dev [lindex [get_cfgmem_parts {n25q64-3.3v-spi-x1_x2_x4}] 0]
# set_property PROGRAM.ADDRESS_RANGE  {use_file} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
# set_property PROGRAM.FILES [list "/home/workspace/Course/20250915-EE291F/EE291FTest/EE291FTestVivado/EE291FTest.runs/impl_1/demoLab2.bin" ] [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
# set_property PROGRAM.PRM_FILE {} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
# set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
# set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
# set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
# set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
# set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
# set_property PROGRAM.CHECKSUM  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
# startgroup 
# create_hw_bitstream -hw_device [lindex [get_hw_devices xc7a35t_0] 0] [get_property PROGRAM.HW_CFGMEM_BITFILE [ lindex [get_hw_devices xc7a35t_0] 0]]; program_hw_devices [lindex [get_hw_devices xc7a35t_0] 0]; refresh_hw_device [lindex [get_hw_devices xc7a35t_0] 0];


close_hw_target
disconnect_hw_server
close_hw_manager

exit