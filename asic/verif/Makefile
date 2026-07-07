PYTHONPATH = $(shell printenv PYTHONPATH):../../cocotb/:$(shell pwd)/
SIM ?= ius

VERILOG_SOURCES+=   ../verilog/amem_core.v \
            ../verilog/app_1ch_behav.v \
            ../verilog/prio_enc_mod8.v \
            ../verilog/one_shot_3.v \
            ../verilog/clock_div.v \
            ../verilog/oneshot.v \
            ../verilog/LI_control.v \
            APP_tb.v

TOPLEVEL = APP_tb
TOPLEVEL_LANG ?= verilog
MODULE = APP_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim
