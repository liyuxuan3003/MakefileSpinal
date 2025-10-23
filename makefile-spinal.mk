######## Makefile for SpinalHDL ########

# --------------------------------
PROJECT?=ProjectSpinal

BUILD_DIR?=build
BUILD_DIR_HDL?=${BUILD_DIR}/hw
BUILD_DIR_SIM?=${BUILD_DIR}/sim

TOP?=MyTopLevel

APP_VERILOG?=${PROJECT}.${TOP}Verilog
APP_VHDL?=${PROJECT}.${TOP}Vhdl
APP_SIM?=${PROJECT}.${TOP}Sim

WAVE?=${BUILD_DIR}/${TOP}/test/wave.fst

SBT?=sbt

GTKWAVE?=gtkwave

GTKWAVE_FLAGS?=--dark

# --------------------------------
# Notification at the end of the task
define NOTIFY_DONE
@echo "|========> Makefile [$@]: Done"
@echo ""
endef

# --------------------------------
.PHONY: default run clean clean-all verilog vhdl sim gtkwave

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

verilog:
	${SBT} "runMain ${APP_VERILOG}"
	${NOTIFY_DONE}

vhdl:
	${SBT} "runMain ${APP_VHDL}"
	${NOTIFY_DONE}

sim:
	${SBT} "runMain ${APP_SIM}"
	${NOTIFY_DONE}

gtkwave: sim
	${GTKWAVE} ${GTKWAVE_FLAGS} ${WAVE}
	${NOTIFY_DONE}