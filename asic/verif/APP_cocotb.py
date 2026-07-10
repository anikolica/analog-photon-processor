import sys
import random
import os
import csv

import cocotb 
from cocotb import triggers, result, utils, clock 
from cocotb.clock import Clock 
from cocotb.triggers import Timer, RisingEdge, FallingEdge, Edge, ClockCycles 
from cocotb.result import TestSuccess, TestFailure, ReturnValue 
from cocotb.utils import get_sim_time

def env1(envvarname, checkval="1"):
    "return True if environment variable 'envvarname' equals value 'checkval'"
    value = os.environ.get(envvarname)
    return value == checkval

dont_run_all = not (os.environ.get("RUN_ALL", "") == "1")

@cocotb.test(skip=(dont_run_all and not env1("APP_T01")))
async def test_behav_basic(APP_tb):
    """
    Basic demonstration for behavioral model of analog section.
    Generates a number of TOT events.
    """
    # Initial setup
    APP_tb.app_1ch_tb.vcomp.value = 0
    APP_tb.app_1ch_tb.rst_init.value = 0
    
    # Wait after initial setup
    await Timer(110, 'ns')
    
    # Reset pulse
    APP_tb.app_1ch_tb.rst_init.value = 1
    await Timer(50, 'ns')
    APP_tb.app_1ch_tb.rst_init.value = 0
    await Timer(100, 'ns')

    # Single TOT pulse test
    APP_tb.app_1ch_tb.vcomp.value = 1
    await Timer(10, 'ns')
    APP_tb.app_1ch_tb.vcomp.value = 0
    await Timer(100, 'ns')

    # Multiple TOT pulses test
    for i in range(3):
        APP_tb.app_1ch_tb.vcomp.value = 1
        await Timer(10, 'ns')
        APP_tb.app_1ch_tb.vcomp.value = 0
        await Timer(15, 'ns')
    
    await Timer(100, 'ns')

    for i in range(6):
        APP_tb.app_1ch_tb.vcomp.value = 1
        await Timer(10, 'ns')
        APP_tb.app_1ch_tb.vcomp.value = 0
        await Timer(15, 'ns')
    
    await Timer(100, 'ns')

    # Single TOT pulse test
    APP_tb.app_1ch_tb.vcomp.value = 1
    await Timer(10, 'ns')
    APP_tb.app_1ch_tb.vcomp.value = 0
    await Timer(200, 'ns')

async def load_pulse(APP_tb, csv_path, column):
    """
    Load a pulse from a given CSV column and drive vcomp.
    """
    with open(csv_path, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        prev_time = None
        for row in reader:
            time_ns = int(row['Time (ns)'])
            pulse = int(row[column])
            if prev_time is not None:
                wait_time = time_ns - prev_time
                await Timer(wait_time, 'ns')
            prev_time = time_ns
            APP_tb.app_1ch_tb.vcomp.value = pulse
        APP_tb.app_1ch_tb.vcomp.value = 0  # Ensure vcomp is low at the end


@cocotb.test(skip=(dont_run_all and not env1("APP_T02")))
async def test_behav_csv(APP_tb):
    """
    Test behavioral model by sequentially playing pulses from CSV.
    """
    csv_path = os.path.join(os.path.dirname(__file__), '../../waveforms/eos_wbls_thorium_tot.csv')

    # Initial setup
    APP_tb.app_1ch_tb.vcomp.value = 0
    APP_tb.app_1ch_tb.rst_init.value = 0
    
    # Wait after initial setup
    await Timer(110, 'ns')
    
    # Reset pulse
    APP_tb.app_1ch_tb.rst_init.value = 1
    await Timer(50, 'ns')
    APP_tb.app_1ch_tb.rst_init.value = 0
    await Timer(100, 'ns')

    # Play each test case
    await load_pulse(APP_tb, csv_path, "SinglePE")
    await Timer(200, 'ns')
    await load_pulse(APP_tb, csv_path, "DoublePE")
    await Timer(200, 'ns')
    await load_pulse(APP_tb, csv_path, "MultiPE")
    await Timer(200, 'ns')
    await load_pulse(APP_tb, csv_path, "Ringing")
    await Timer(200, 'ns')


@cocotb.test(skip=(dont_run_all and not env1("APP_T03")))
async def test_amem_basic(APP_tb):
    """
    Basic test for analog memory core.
    Send 4 pulses, decode write pointer and WE_time, change states
    """
    # Initial setup
    APP_tb.vcomp.value = 0
    APP_tb.rstb.value = 1
    
    # Wait after initial setup
    await Timer(100, 'ns')
    
    # Reset pulse
    APP_tb.rstb.value = 0
    await Timer(50, 'ns')
    APP_tb.rstb.value = 1
    await Timer(100, 'ns')

    # Single narrow TOT pulse
    APP_tb.vcomp.value = 1 # 250ns
    await Timer(5, 'ns')
    APP_tb.vcomp.value = 0 # 255ns
    await Timer(20, 'ns')
    APP_tb.WE_time_i = 0b00000001 # 275ns
    await Timer(25, 'ns')
    APP_tb.WE_time_i = 0b00000000 # 300ns
    await Timer(100, 'ns')

    # Three closely spaced TOT pulses
    APP_tb.vcomp.value = 1 # 400ns
    await Timer(17, 'ns')
    APP_tb.vcomp.value = 0 # 417ns
    await Timer(23, 'ns')
    APP_tb.WE_time_i = 0b00000010 # 440ns
    await Timer(13, 'ns')

    APP_tb.vcomp.value = 1 # 453ns
    await Timer(27, 'ns')
    APP_tb.vcomp.value = 0 # 480ns
    APP_tb.WE_time_i = 0b00000000
    await Timer(7, 'ns')
    APP_tb.vcomp.value = 1 # 487ns
    await Timer(10, 'ns')
    APP_tb.vcomp.value = 0 # 497ns
    await Timer(20, 'ns')
    APP_tb.WE_time_i = 0b00001100 # 517ns
    await Timer(23, 'ns')
    APP_tb.WE_time_i = 0b00000000 # 540 ns
    await Timer(1200, 'ns')

    # Read out everything
    APP_tb.controller_tb.amem_core_tb.read_next_i = 1;
    await Timer(20, 'ns')
    APP_tb.controller_tb.amem_core_tb.read_next_i = 0;
    await Timer(2000, 'ns') # ADC reading ...
    APP_tb.controller_tb.amem_core_tb.adc_done_i = 1;
    await Timer(20, 'ns')
    APP_tb.controller_tb.amem_core_tb.adc_done_i = 0;
    await Timer(100, 'ns')

    APP_tb.controller_tb.amem_core_tb.read_next_i = 1;
    await Timer(20, 'ns')
    APP_tb.controller_tb.amem_core_tb.read_next_i = 0;
    await Timer(2000, 'ns') # ADC reading ...
    APP_tb.controller_tb.amem_core_tb.adc_done_i = 1;
    await Timer(20, 'ns')
    APP_tb.controller_tb.amem_core_tb.adc_done_i = 0;
    await Timer(100, 'ns')

    APP_tb.controller_tb.amem_core_tb.read_next_i = 1;
    await Timer(20, 'ns')
    APP_tb.controller_tb.amem_core_tb.read_next_i = 0;
    await Timer(2000, 'ns') # ADC reading ...
    APP_tb.controller_tb.amem_core_tb.adc_done_i = 1;
    await Timer(20, 'ns')
    APP_tb.controller_tb.amem_core_tb.adc_done_i = 0;
    await Timer(1000, 'ns')

async def wait_cycle(clk):
    await RisingEdge(clk)
    await RisingEdge(clk)

@cocotb.test(skip=((dont_run_all) and not env1("APP_LICNT")))
async def test_li_control(APP_tb):
    """
    Basic test for LI_control
    """
    
    # initial setup
    APP_tb.li_control_tb.rstb.value = 1
    APP_tb.LI_valid_up_o.value = 0b0000
    APP_tb.LI_length_o.value = 0

    # wait a bit
    await Timer(60, 'ns')

    # Reset Pulse
    APP_tb.li_control_tb.rstb.value = 0
    await Timer(50, 'ns')
    APP_tb.li_control_tb.rstb.value = 1
    await Timer(100, 'ns')

    # test a single LI
    APP_tb.LI_valid_up_o.value = 0b0010
    APP_tb.LI_length_o.value = 4
    # ensure it stays for a full clock cycle
    await wait_cycle(APP_tb.clk)
    APP_tb.LI_valid_up_o.value = 0b0000
    await Timer(200, 'ns')
    APP_tb.LI_length_o.value = 0

    # test double LI window
    clock_len_ns = 20
    li_length = 4
    # Set valid_up to some value, and give an LI length
    APP_tb.LI_valid_up_o.value = 0b0100 # arbitrary bit
    APP_tb.LI_length_o.value = li_length
    await wait_cycle(APP_tb.clk)
    APP_tb.LI_valid_up_o.value = 0b0000
    # wait for that to finish
    # await Timer(clock_len_ns*li_length, 'ns')
    await ClockCycles(APP_tb.clk, li_length-1)
    APP_tb.LI_valid_up_o.value = 0b0001
    APP_tb.LI_length_o = 8
    await RisingEdge(APP_tb.clk)
    APP_tb.LI_valid_up_o.value = 0b0000
    await Timer(300, 'ns')
    APP_tb.LI_length_o.value = 0

@cocotb.test(skip=(dont_run_all and not env1("APP_LIBEHAV")))
async def test_li_control_behav(APP_tb):
    """
    Test LI_control with real TOT stimulus from app_1ch_behav via analog_if.
    Validates LI_start, LI_end, and LI_active signals with real vcomp pulses.
    """
    
    # Initial setup - reset state
    APP_tb.vcomp.value = 0
    APP_tb.rstb.value = 1
    APP_tb.LI_length_behav.value = 0
    
    # Wait after initial setup
    await Timer(100, 'ns')
    
    # Reset pulse
    APP_tb.rstb.value = 0
    await Timer(50, 'ns')
    APP_tb.rstb.value = 1
    await Timer(100, 'ns')
    
    # Verify reset state
    assert APP_tb.LI_active_behav.value == 0, "LI_active should be low after reset"
    
    # Single tot
    APP_tb.LI_length_behav.value = 4
    
    # Pulse vcomp to generate valid_up_o
    APP_tb.vcomp.value = 1
    await Timer(25, 'ns')
    APP_tb.vcomp.value = 0
    
    await ClockCycles(APP_tb.clk, 2)
    
    assert APP_tb.LI_active_behav.value == 1, "LI_active should be high during window"
    
    # Wait for the window to complete
    await ClockCycles(APP_tb.clk, 4)
    await RisingEdge(APP_tb.clk)
    
    assert APP_tb.LI_active_behav.value == 0, "LI_active should be low after window ends"
    
    # Back to back TOT
    APP_tb.LI_length_behav.value = 4
    
    # Pulse vcomp to start first window
    APP_tb.vcomp.value = 1
    await Timer(25, 'ns')
    APP_tb.vcomp.value = 0
    await ClockCycles(APP_tb.clk, 2)
    
    assert APP_tb.LI_active_behav.value == 1, "LI_active should be high for first window"
    await ClockCycles(APP_tb.clk, 2)
    
    APP_tb.LI_length_behav.value = 3
    APP_tb.vcomp.value = 1
    await Timer(25, 'ns')
    APP_tb.vcomp.value = 0
    
    await RisingEdge(APP_tb.clk)
    
    assert APP_tb.LI_active_behav.value == 1, "LI_active should stay high for back-to-back TOT"
    
    await ClockCycles(APP_tb.clk, 3)
    await RisingEdge(APP_tb.clk)
    
    assert APP_tb.LI_active_behav.value == 0, "LI_active should go low after back-to-back windows complete"
    
    await Timer(100, 'ns')