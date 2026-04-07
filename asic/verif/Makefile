PYTHONPATH = $(shell printenv PYTHONPATH):../../cocotb/:$(shell pwd)/
SIM ?= ius

VERILOG_SOURCES+=   ../verilog/amem_core.v \
            ../verilog/app_1ch_behav.v \
            ../verilog/prio_enc_mod8.v \
            ../verilog/clock_div.v \
            ../verilog/oneshot.v \
            ../verilog/analog_if/controller.sv \
            ../verilog/analog_if/analog_if.v \
            ../verilog/analog_if/clk_cnter.v \
            ../verilog/analog_if/cmp_sync.v \
            ../verilog/analog_if/cmp_latch.v \
            ../verilog/analog_if/controller.sv \
            APP_tb.v

TOPLEVEL = APP_tb
TOPLEVEL_LANG ?= verilog
MODULE = APP_cocotb

include $(shell cocotb-config --makefiles)/Makefile.sim
