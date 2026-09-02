import sys
import random
import itertools
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
    # initialize, wait for clock_div's counter to be zero
    while APP_tb.clock_div_2_tb.counter.value != 0:
        await RisingEdge(APP_tb.clk)
    
    # DIVISOR=2 test
    await RisingEdge(APP_tb.clk)
    await FallingEdge(APP_tb.clk)
    assert APP_tb.clock_out_2.value == 1, "clock_out must go high"
    await RisingEdge(APP_tb.clk)
    await FallingEdge(APP_tb.clk)
    assert APP_tb.clock_out_2.value == 0, "clock_out must go low"

    # once again, wait for the clock_div counter to be zero
    while APP_tb.clock_div_4_tb.counter.value != 0:
        await RisingEdge(APP_tb.clk)

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

@cocotb.test(skip=(dont_run_all and not env1('APP_ADDR')))
async def test_addr(APP_tb):
    # Initial setup
    APP_tb.addr_a_i.value = 0
    APP_tb.addr_b_i.value = 0
    APP_tb.rstb.value = 0
    await RisingEdge(APP_tb.clk)
    APP_tb.rstb.value = 1
    await RisingEdge(APP_tb.clk)

    # check if everything reset properly
    assert APP_tb.addr_c_o.value == 0b0, "output must be zero after reset"

    # check all possible outputs
    for a in range(16):
        for b in range(16):
            APP_tb.addr_a_i.value = a
            APP_tb.addr_b_i.value = b
            await RisingEdge(APP_tb.clk)
            await RisingEdge(APP_tb.clk)
            assert APP_tb.addr_c_o.value == a + b, f"addr output incorrect, expected {a+b}, got {APP_tb.addr_c_o.value}"

def prio_enc_mod8_reference(prev_index, falling_edges):
    """
    Pure-python mirror of the combinational core of prio_enc_mod8.v.

    Given the current reported index and the mask of falling edges
    (falling_edges = prev & ~signals), returns (next_index, valid):
      - no falling edges   -> index holds, valid = 0
      - some falling edges -> highest-priority bit among the falling set,
                              where priority scans downward from prev_index
                              circularly (prev_index, prev_index-1, ...,
                              0, 7, ..., prev_index+1).
    """
    falling_edges &= 0xFF
    if falling_edges == 0:
        return prev_index, 0

    # rotate right by (index + 1), OR with the wrapped-around bits
    k = (prev_index + 1) & 0x7
    rotated = ((falling_edges >> k) | (falling_edges << (8 - k))) & 0xFF
    offset = rotated.bit_length() - 1  # leftmost set bit == casex priority result
    return (offset + prev_index + 1) & 0x7, 1


if __name__ == "__main__":
    # Sanity checks for the reference model against the module header examples.
    assert prio_enc_mod8_reference(0, 0x00) == (0, 0), "no-edge must hold index"
    assert prio_enc_mod8_reference(0, 0x18) == (4, 1), "TACs 3 & 4 -> index 4"
    assert prio_enc_mod8_reference(0, 0x81) == (0, 1), "TACs 7 & 0 wrap -> index 0"
    assert prio_enc_mod8_reference(0, 0x10) == (4, 1), "single bit -> itself"
    assert prio_enc_mod8_reference(4, 0x04) == (2, 1), "single bit below index"

    # Exhaustive cross-check of the reference model against two independent
    # formulations: a literal translation of the Verilog, and the semantic
    # definition (highest-priority falling bit, scanning circularly downward
    # from the current index).
    def verilog_literal(prev_index, falling_edges):
        """Literal translation of prio_enc_mod8.v lines 69-73."""
        tb = (prev_index + 1) & 0x7            # index + 3'b001 (3-bit add wraps)
        shl = (8 - tb) & 0xF                   # 4'b1000 - (index + 3'b001)
        shifted = ((falling_edges >> tb) |
                   (falling_edges << shl)) & 0xFF
        if falling_edges == 0:
            return prev_index, 0
        if shifted == 0:
            return prev_index, 1  # dangles if the RTL ever produces 0; flag it
        offset = shifted.bit_length() - 1      # casex: leftmost set bit
        return (prev_index + offset + 1) & 0x7, 1

    def scan_descending(prev_index, falling_edges):
        """Semantic: pick (prev_index, prev_index-1, ...) mod 8, first set bit."""
        if falling_edges == 0:
            return prev_index, 0
        for i in range(8):
            bit = (prev_index - i) & 0x7
            if falling_edges & (1 << bit):
                return bit, 1

    checked = 0
    for idx in range(8):
        for falling in range(256):
            ref = prio_enc_mod8_reference(idx, falling)
            assert ref == verilog_literal(idx, falling), \
                f"ref vs verilog_literal mismatch idx={idx} falling={falling:08b}"
            assert ref == scan_descending(idx, falling), \
                f"ref vs scan_descending mismatch idx={idx} falling={falling:08b}"
            checked += 1
    assert checked == 8 * 256, "exhaustive cross-check must cover all cases"
    print(f"prio_enc_mod8_reference sanity checks passed ({checked} cases)")


async def prio_enc_reset(APP_tb):
    """Pulse rstb low for one clock and return to normal operation."""
    APP_tb.rstb.value = 1
    await RisingEdge(APP_tb.clk)
    APP_tb.rstb.value = 0
    await RisingEdge(APP_tb.clk)
    APP_tb.rstb.value = 1
    await RisingEdge(APP_tb.clk)


async def prio_set_index(APP_tb, target):
    """
    Drive prio_enc_mod8_tb to an arbitrary internal index state.

    With index == 0 a single falling bit always reports that bit's own
    index, so falling each bit 0..target in sequence leaves index == target.
    """
    APP_tb.p_signals_out.value = 0
    for i in range(target + 1):
        APP_tb.p_signals_out.value = 1 << i
        await RisingEdge(APP_tb.clk)  # latch signals into prev
        APP_tb.p_signals_out.value = 0
        await RisingEdge(APP_tb.clk)  # detect the falling edge -> index = i


async def prio_drive(APP_tb, signals):
    """
    Apply one clock cycle of `signals` to p_signals_out and return the
    resulting (index, valid) outputs as a tuple.

    A short timer after the clock edge lets the non-blocking register
    updates for index/valid settle before reading back.
    """
    APP_tb.p_signals_out.value = signals
    await RisingEdge(APP_tb.clk)
    await Timer(1, 'ns')  # 1 ns << 20 ns clock period; read NBA-updated outputs
    return int(APP_tb.p_index_in.value), int(APP_tb.p_valid_in.value)


def prio_enc_model_step(state, signals):
    """
    One DUT clock cycle in python.  state = {'prev': int, 'index': int}
    mirrors the DUT's prev/index registers.  Returns (new_state, (index, valid)).
    """
    falling = state['prev'] & (~signals) & 0xFF
    if falling:
        index, _ = prio_enc_mod8_reference(state['index'], falling)
        valid = 1
    else:
        index, valid = state['index'], 0
    return {'prev': signals, 'index': index}, (index, valid)


@cocotb.test(skip=(dont_run_all and not env1('APP_PRIO_ENC')))
async def test_prio_enc_mod8(APP_tb):
    """
    Test prio_enc_mod8.

    Checks reset behavior, the two documented examples from the module
    header, then exhaustively sweeps every (current index, falling_edges)
    combination against a python reference model.  Ends with a seeded
    randomized regression that compares every clock cycle against a full
    python model of the DUT (prev/index registers).
    """

    # Initial Setup
    await prio_enc_reset(APP_tb)
    assert APP_tb.p_signals_out.value == 0, "Input signals not properly reset."
    assert APP_tb.p_index_in.value == 0, "Output indices not properly reset."
    assert APP_tb.p_valid_in.value == 0, "Valid flag not properly reset."

    # Module header examples
    await prio_enc_reset(APP_tb)
    await prio_drive(APP_tb, 0x18)
    got = await prio_drive(APP_tb, 0x00)
    assert got == prio_enc_mod8_reference(0, 0x18), \
        f"TACs 3 and 4 finishing together must report index 4, got {got}"

    # TACs 7 and 0 finish at the same time
    await prio_enc_reset(APP_tb)
    await prio_drive(APP_tb, 0x81)
    got = await prio_drive(APP_tb, 0x00)
    assert got == prio_enc_mod8_reference(0, 0x81), \
        f"TACs 7 and 0 finishing together must report index 0 (mod 8 wrap), got {got}"

    case_count = 0
    for idx, falling in itertools.product(range(8), range(256)):
        await prio_set_index(APP_tb, idx)
        got = await prio_drive(APP_tb, falling)
        assert got == (idx, 0), (
            f"exhaustive idx={idx} falling={falling:08b}: rising edge must not "
            f"set valid or change index, got {got}")
        exp = prio_enc_mod8_reference(idx, falling)
        got = await prio_drive(APP_tb, 0x00)
        assert got == exp, (
            f"exhaustive idx={idx} falling={falling:08b}: expected {exp}, got {got}")
        case_count += 1
    assert case_count == 8 * 256, \
        "exhaustive sweep must cover all index x falling_edges combinations"

    # Seeded randomized regression
    # Cycle-by-cycle comparison against a python model of the full DUT.
    await prio_enc_reset(APP_tb)
    state = {'prev': 0, 'index': 0}
    rng = random.Random(1234)
    for i in range(2000):
        sig = rng.randrange(256)
        state, exp = prio_enc_model_step(state, sig)
        got = await prio_drive(APP_tb, sig)
        assert got == exp, \
            f"random case {i}: signals={sig:08b}, expected {exp}, got {got}"