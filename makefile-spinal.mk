######## Makefile for SpinalHDL ########

# --------------------------------
# Project name
PROJECT?=ProjectSpinal

# Build directory
BUILD_DIR?=build
# Build directory for verilog and vhdl
BUILD_DIR_HDL?=${BUILD_DIR}/hw
# Build directory for simulated file and wave
BUILD_DIR_SIM?=${BUILD_DIR}/sim
# Build directory for vivado bitstream
BUILD_DIR_VIVADO?=${BUILD_DIR}/vivado
# Relative path to current dir when in vivado build dir
RELP_BACK_VIVADO?=$(shell realpath --relative-to=${BUILD_DIR_VIVADO} .)

# Get current dir
CURR_DIR?=$(shell pwd)

# Get directory of this file
THIS_DIR?=$(patsubst %/,%,$(dir $(lastword ${MAKEFILE_LIST})))

# Top module
TOP?=TopLevel

# Target module (default = top)
TARGET?=${TOP}

# Source files of spinal (*.scala)
SRCS_SPINAL_EXTRA?=
SRCS_SPINAL?=$(wildcard *.scala) ${SRCS_SPINAL_EXTRA}

# Source files of xilinx design constraints (*.xdc)
SRCS_XDC_EXTRA?=
SRCS_XDC?=$(wildcard *.xdc) ${SRCS_XDC_EXTRA}

PLATFORM?=

FLASH?=

# Application name of verilog generator
APP_VERILOG?=${PROJECT}.${TARGET}Verilog
# Application name of vhdl generator
APP_VHDL?=${PROJECT}.${TARGET}Vhdl
# Application name of simulation
APP_SIM?=${PROJECT}.${TARGET}Sim

# GTKWave config file
GTKW_CONFIG?=$(wildcard ${TARGET}.gtkw)

# Generated verilog 
GEN_VERILOG?=${BUILD_DIR_HDL}/${TARGET}.v
# Generated vhdl
GEN_VHDL?=${BUILD_DIR_HDL}/${TARGET}.vhdl
# Simulated wave
WAVE?=${BUILD_DIR_SIM}/${TARGET}/test/wave.fst
# Bitstream
BITSTREAM?=${BUILD_DIR_VIVADO}/${TARGET}.bit
# Bin file
BINFILE?=${BUILD_DIR_VIVADO}/${TARGET}.bin

# Tcl for generate bitstream
TCL_BITSTREAM?=${THIS_DIR}/vivado-bitstream.tcl
# Tcl for program fpga
TCL_PROGRAM?=${THIS_DIR}/vivado-program.tcl
PROGRAM_TYPE_BURN?=burn
PROGRAM_TYPE_LOAD?=load

# Sbt
SBT?=sbt
ARGS?=
PRE_BUILD_CMD?=

# GTKWave
GTKWAVE?=gtkwave
GTKWAVE_FLAGS?=--dark

# Vivado
VIVADO?=vivado
VIVADO_FLAGS?=-mode batch -nolog -nojournal


# --------------------------------
# Notification at the end of the task
define NOTIFY_DONE
@echo "|========> Makefile [$@]: Done"
@echo ""
endef

# --------------------------------
# Declare phony tasks
.PHONY: default run clean clean-all verilog vhdl sim gtkwave bitstream binfile load burn

default: verilog
	${NOTIFY_DONE}

run: sim 
	${NOTIFY_DONE}

clean:
	rm -r -v -I ${BUILD_DIR}
	${NOTIFY_DONE}

clean-all:
	rm -r -v -I ${BUILD_DIR} project target .bloop
	${NOTIFY_DONE}

verilog: ${GEN_VERILOG}
	${NOTIFY_DONE}

vhdl: ${GEN_VHDL}
	${NOTIFY_DONE}

sim: ${WAVE}
	${NOTIFY_DONE}

gtkwave: ${WAVE} ${GTKW_CONFIG}
	${GTKWAVE} ${GTKWAVE_FLAGS} ${WAVE} ${GTKW_CONFIG}
	${NOTIFY_DONE}

bitstream: ${BITSTREAM}
	${NOTIFY_DONE}

binfile: ${BINFILE}
	${NOTIFY_DONE}

load: ${BITSTREAM}
	cd ${BUILD_DIR_VIVADO} && \
	${VIVADO} ${VIVADO_FLAGS} -source "$(addprefix ${RELP_BACK_VIVADO}/,${TCL_PROGRAM})" -tclargs \
		"$(addprefix ${RELP_BACK_VIVADO}/,${BITSTREAM})" \
		"${FLASH}" \
		"${PROGRAM_TYPE_LOAD}"
	${NOTIFY_DONE}

burn: ${BINFILE}
	cd ${BUILD_DIR_VIVADO} && \
	${VIVADO} ${VIVADO_FLAGS} -source "$(addprefix ${RELP_BACK_VIVADO}/,${TCL_PROGRAM})" -tclargs \
		"$(addprefix ${RELP_BACK_VIVADO}/,${BINFILE})" \
		"${FLASH}" \
		"${PROGRAM_TYPE_BURN}"
	${NOTIFY_DONE}

# --------------------------------
# Create build directory
${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}
	${NOTIFY_DONE}

# Create build directory of verilog/vhdl
${BUILD_DIR_HDL}: | ${BUILD_DIR}
	mkdir -p ${BUILD_DIR_HDL}
	${NOTIFY_DONE}

# Create build directory of simulation
${BUILD_DIR_SIM}: | ${BUILD_DIR}
	mkdir -p ${BUILD_DIR_SIM}
	${NOTIFY_DONE}

# Create build directory of bitstream
${BUILD_DIR_VIVADO}: | ${BUILD_DIR}
	mkdir -p ${BUILD_DIR_VIVADO}
	${NOTIFY_DONE}

# Generate verilog from scala
${GEN_VERILOG}: ${SRCS_SPINAL} | ${BUILD_DIR_HDL}
	${PRE_BUILD_CMD}
	${SBT} "runMain ${APP_VERILOG} ${ARGS}"
	${NOTIFY_DONE}

# Generate vhdl from scala
${GEN_VHDL}: ${SRCS_SPINAL} | ${BUILD_DIR_HDL}
	${PRE_BUILD_CMD}
	${SBT} "runMain ${APP_VHDL} ${ARGS}"
	${NOTIFY_DONE}

# Generate wave
${WAVE}: ${SRCS_SPINAL} | ${BUILD_DIR_SIM}
	${PRE_BUILD_CMD}
	${SBT} "runMain ${APP_SIM} ${ARGS}"
	${NOTIFY_DONE}

# Generate bitstream
${BITSTREAM} ${BINFILE}: ${GEN_VERILOG} ${SRCS_XDC} | ${BUILD_DIR_VIVADO}
	cd ${BUILD_DIR_VIVADO} && \
	${VIVADO} ${VIVADO_FLAGS} -source "$(addprefix ${RELP_BACK_VIVADO}/,${TCL_BITSTREAM})" -tclargs \
		"$(addprefix ${RELP_BACK_VIVADO}/,${GEN_VERILOG})" \
		"$(addprefix ${RELP_BACK_VIVADO}/,${SRCS_XDC})" \
		"${TARGET}" \
		"${PLATFORM}" \
		"$(addprefix ${RELP_BACK_VIVADO}/,${BITSTREAM})" \
	${NOTIFY_DONE}
	