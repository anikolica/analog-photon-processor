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

    LI_LENGTH = 8
    
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

    # set LI_length
    APP_tb.LI_length_o.value = LI_LENGTH 

    # Check that values are correct after reset
    assert APP_tb.LI_active_i.value == 0, "LI_active has improper value after reset"
    assert APP_tb.LI_end_i.value == 0, "LI_end has improper value after reset"
    assert APP_tb.LI_start_i.value == 0, "LI_start has improper value after reset"


    # test a single LI
    APP_tb.LI_valid_up_o.value = 0b0010
    # ensure it stays for a full clock cycle
    await wait_cycle(APP_tb.clk)
    # set valid_up down
    APP_tb.LI_valid_up_o.value = 0b0000
    # make sure LI_start pulses
    assert APP_tb.LI_start_i.value == 1, "LI_start should pulse at the beginning of a TOT"
    await ClockCycles(APP_tb.clk, LI_LENGTH)
    # make sure LI_end pulses
    assert APP_tb.LI_end_i == 1, "LI_end should pulse at the end of a TOT"

    # space the tests out
    await Timer(50, 'ns')
    assert APP_tb.LI_active_i.value == 0, "LI_active must go low after LI window"
    assert APP_tb.LI_start_i.value == 0, "LI_start must be low after LI window"
    assert APP_tb.LI_end_i.value == 0, "LI_end must be low after LI window"

    # test double LI window
    #li_length = 4
    # Set valid_up to some value, and give an LI length
    APP_tb.LI_valid_up_o.value = 0b0100 # arbitrary bit
    #APP_tb.LI_length_o.value = LI_LENGTH 
    await RisingEdge(APP_tb.clk)
    APP_tb.LI_valid_up_o.value = 0b0000
    # wait for that to finish
    # li_length-1 because we want it on the last cycle of the li, and already
    # waited one cycle
    await ClockCycles(APP_tb.clk, LI_LENGTH-1)
    # now a back-to-back TOT
    APP_tb.LI_valid_up_o.value = 0b0001
    #APP_tb.LI_length_o.value = LI_LENGTH
    await RisingEdge(APP_tb.clk)
    APP_tb.LI_valid_up_o.value = 0b0000
    # wait for the next rising edge to verify
    await RisingEdge(APP_tb.clk)
    # check that LI_active stays high
    assert APP_tb.LI_active_i.value == 1, "LI_active_i should stay high for back to back TOTs"
    # check that li_start and li_end pulsed
    assert ((APP_tb.LI_start_i.value == 1) and (APP_tb.LI_end_i == 1)), "LI_start and LI_end should pulse simulatenously for a back-to-back TOT"
    # wait to finish
    #await Timer(100, 'ns')
    # ensure that a valid_up during the LI_window does't cause another LI to start
    await ClockCycles(APP_tb.clk, 2)
    APP_tb.LI_valid_up_o.value = 0b0010
    await RisingEdge(APP_tb.clk)
    APP_tb.LI_valid_up_o.value = 0b0000
    assert APP_tb.LI_start_i.value == 0, "An LI_valid_up during an LI_window should be ignored"
    await Timer(260, 'ns')

    # check that everything is low at the end
    assert APP_tb.LI_active_i.value == 0, "LI_active must go low after LI window"
    assert APP_tb.LI_start_i.value == 0, "LI_start must be low after LI window"
    assert APP_tb.LI_end_i.value == 0, "LI_end must be low after LI window"
    #APP_tb.LI_length_o.value = 0

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

    LI_LENGTH = 4
    
    # Single tot
    APP_tb.LI_length_behav.value = LI_LENGTH
    
    # Pulse vcomp to generate valid_up_o
    APP_tb.vcomp.value = 1
    await Timer(25, 'ns')
    APP_tb.vcomp.value = 0
    
    await ClockCycles(APP_tb.clk, 2)
    
    assert APP_tb.LI_active_behav.value == 1, "LI_active should be high during window"
    
    # Wait for the window to complete
    await ClockCycles(APP_tb.clk, LI_LENGTH)
    await RisingEdge(APP_tb.clk)
    
    assert APP_tb.LI_active_behav.value == 0, "LI_active should be low after window ends"
    
    # Back to back TOT
    
    # Pulse vcomp to start first window
    APP_tb.vcomp.value = 1
    await Timer(25, 'ns')
    APP_tb.vcomp.value = 0
    await ClockCycles(APP_tb.clk, 2)
    
    assert APP_tb.LI_active_behav.value == 1, "LI_active should be high for first window"
    await RisingEdge(APP_tb.clk)
    
    APP_tb.vcomp.value = 1
    await RisingEdge(APP_tb.clk)
    APP_tb.vcomp.value = 0
    
    await RisingEdge(APP_tb.clk)
    
    assert APP_tb.LI_active_behav.value == 1, "LI_active should stay high for back-to-back TOT"
    
    await ClockCycles(APP_tb.clk, LI_LENGTH+1)
    
    assert APP_tb.LI_active_behav.value == 0, "LI_active should go low after back-to-back windows complete"
    
    await Timer(100, 'ns')


@cocotb.test(skip=(dont_run_all and not env1("APP_DEMUX")))
async def test_demux(APP_tb):
    """Test that the demultiplexer properly demuxes values.
    """
    # start with demux disabled
    APP_tb.demux_enable_o.value = 0
    await RisingEdge(APP_tb.clk)
    assert APP_tb.demux_i.value == 0, "demux must output zero when disabled."

    await RisingEdge(APP_tb.clk)
    APP_tb.demux_enable_o.value = 1
    # wait another clock
    # loop through values, feed to demux and then check proper output
    for i in range(8):
        APP_tb.demux_val_o.value = i
        await RisingEdge(APP_tb.clk)
        assert APP_tb.demux_i.value == (1 << i), f"demultiplexer must output {(1<<i)} for value {i}, got {APP_tb.demux_i.value}"

@cocotb.test(skip=(dont_run_all and not env1("APP_ONESHOT")))
async def test_oneshot(APP_tb):
    """Test async oneshot module.
    """

    # Initial Setup
    APP_tb.rstb.value = 1
    APP_tb.trigger_out.value = 0
    await ClockCycles(APP_tb.clk, 2)

    # async pulse
    # wait for next clock dege
    await RisingEdge(APP_tb.clk)
    # plus another 1/4 of a cycle
    await Timer(5, 'ns')

    APP_tb.trigger_out.value = 1
    # check that pulse goes high before next clock edge
    await Timer(1, 'ns')
    APP_tb.trigger_out.value = 0
    assert APP_tb.pulse_in.value == 1, "pulse should go high asynchronously"

    # wait for next rising edge to get back on the clock
    await RisingEdge(APP_tb.clk)
    # wait for another rising edge for pulse to deassert
    await RisingEdge(APP_tb.clk)
    assert APP_tb.pulse_in.value == 0, "pulse should go low on next clock cycle"

    # test for retriggers
    await RisingEdge(APP_tb.clk)
    APP_tb.trigger_out.value = 1
    await Timer(1, 'ns')
    assert APP_tb.pulse_in.value == 1, "pulse should go high asynchronously"
    #re-sync test to clock
    await RisingEdge(APP_tb.clk)
    # wait for another two clock cycles
    await RisingEdge(APP_tb.clk)
    await RisingEdge(APP_tb.clk)
    # ensure on the second clock we don't get a retrigger
    assert APP_tb.pulse_in.value == 0, "pulse should not re-fire on a held trigger"
    await RisingEdge(APP_tb.clk)
    APP_tb.trigger_out.value = 0
    
@cocotb.test(skip=(dont_run_all and not env1("APP_CLOCKDIV")))
async def test_clock_div(APP_tb):
    """Test of clock_div module
    """
    # NOTE this will constantly fire. Do we want a separate clock signal so this
    # only runs during it's own test?
    
    # DIVISOR=2 test
    await RisingEdge(APP_tb.clk)
    await FallingEdge(APP_tb.clk)
    assert APP_tb.clock_out_2.value == 1, "clock_out must go high"
    await RisingEdge(APP_tb.clk)
    await FallingEdge(APP_tb.clk)
    assert APP_tb.clock_out_2.value == 0, "clock_out must go low"

    # DIVISOR=4 test
    await RisingEdge(APP_tb.clk)
    assert APP_tb.clock_out_4.value == 1, "clock_out must go high"
    await RisingEdge(APP_tb.clk)
    await RisingEdge(APP_tb.clk)
    assert APP_tb.clock_out_4.value == 0, "clock_out must go low"

@cocotb.test(skip=(dont_run_all and not env1("APP_CLKCNTER")))
async def test_clk_cnter(APP_tb):
    # Initial setup
    APP_tb.rstb.value = 0
    await RisingEdge(APP_tb.clk)
    APP_tb.rstb.value = 1

    # check if reset has configured things correctly
    assert APP_tb.clk_cnt_i.value == 0, "rstb must reset clock_cnt to zero"
    await RisingEdge(APP_tb.clk)
    for i in range(256):
        assert APP_tb.clk_cnt_i.value == i, f"clock_cnt must have value {i}, got {APP_tb.clk_cnt_i.value}"
        await RisingEdge(APP_tb.clk)

    # test roll-over
    assert APP_tb.clk_cnt_i.value == 0, "clock must roll over once integer limit is hit"