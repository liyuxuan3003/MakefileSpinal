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
RELP_BACK?=../..

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
# Bitstream (for load)
BITSTREAM?=${BUILD_DIR_VIVADO}/${TARGET}.bit
# Binfile (for burn)
BINFILE?=${BUILD_DIR_VIVADO}/${TARGET}.bin
# Netlist
NETLIST?=${BUILD_DIR_VIVADO}/${TARGET}.netlist.v
# Checkpoint
CHECKPOINT?=${BUILD_DIR_VIVADO}/${TARGET}.dcp

BITSTREAM_LOG?=${BUILD_DIR_VIVADO}/vivado_bitstream.log
BITSTREAM_JOU?=${BUILD_DIR_VIVADO}/vivado_bitstream.jou

PROGRAM_LOG?=${BUILD_DIR_VIVADO}/vivado_program.log
PROGRAM_JOU?=${BUILD_DIR_VIVADO}/vivado_program.jou

RPT_TIMING_SUMMARY?=${BUILD_DIR_VIVADO}/timing_summary.rpt
RPT_TIMING?=${BUILD_DIR_VIVADO}/timing.rpt
RPT_CLOCK?=${BUILD_DIR_VIVADO}/clock.rpt
RPT_UTILI?=${BUILD_DIR_VIVADO}/utili.rpt
RPT_POWER?=${BUILD_DIR_VIVADO}/power.rpt
RPT_DRC?=${BUILD_DIR_VIVADO}/drc.rpt

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
VIVADO_FLAGS?=-mode batch

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

bitstream: ${BITSTREAM} ${BINFILE}
	${NOTIFY_DONE}

load: ${BITSTREAM} ${TCL_PROGRAM}
	-rm ${PROGRAM_JOU}
	-rm ${PROGRAM_LOG}
	cd ${BUILD_DIR_VIVADO} && \
	${VIVADO} ${VIVADO_FLAGS} \
	-source  "${RELP_BACK}/${TCL_PROGRAM}" \
	-journal "${RELP_BACK}/${PROGRAM_JOU}" \
	-log     "${RELP_BACK}/${PROGRAM_LOG}" \
	-tclargs \
		"${RELP_BACK}/${BITSTREAM}" \
		"${FLASH}" \
		"${PROGRAM_TYPE_LOAD}"
	${NOTIFY_DONE}

burn: ${BINFILE} ${TCL_PROGRAM}
	-rm ${PROGRAM_JOU}
	-rm ${PROGRAM_LOG}
	cd ${BUILD_DIR_VIVADO} && \
	${VIVADO} ${VIVADO_FLAGS} \
	-source  "${RELP_BACK}/${TCL_PROGRAM}" \
	-journal "${RELP_BACK}/${PROGRAM_JOU}" \
	-log     "${RELP_BACK}/${PROGRAM_LOG}" \
	-tclargs \
		"${RELP_BACK}/${BITSTREAM}" \
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
${BITSTREAM} ${BINFILE}: ${GEN_VERILOG} ${SRCS_XDC} ${TCL_BITSTREAM} | ${BUILD_DIR_VIVADO}
	-rm ${BITSTREAM_JOU}
	-rm ${BITSTREAM_LOG}
	cd ${BUILD_DIR_VIVADO} && \
	${VIVADO} ${VIVADO_FLAGS} \
	-source  "${RELP_BACK}/${TCL_BITSTREAM}" \
	-journal "${RELP_BACK}/${BITSTREAM_JOU}" \
	-log     "${RELP_BACK}/${BITSTREAM_LOG}" \
	-tclargs \
		"$(addprefix ${RELP_BACK}/,${GEN_VERILOG})" \
		"$(addprefix ${RELP_BACK}/,${SRCS_XDC})" \
		"${TARGET}" \
		"${PLATFORM}" \
		"${RELP_BACK}/${BITSTREAM}" \
		"${RELP_BACK}/${NETLIST}" \
		"${RELP_BACK}/${CHECKPOINT}" \
		"${RELP_BACK}/${RPT_TIMING_SUMMARY}" \
		"${RELP_BACK}/${RPT_TIMING}" \
		"${RELP_BACK}/${RPT_CLOCK}" \
		"${RELP_BACK}/${RPT_UTILI}" \
		"${RELP_BACK}/${RPT_POWER}" \
		"${RELP_BACK}/${RPT_DRC}"
	${NOTIFY_DONE}
	