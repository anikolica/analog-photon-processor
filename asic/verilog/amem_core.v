/******************************************************************************
 * Digital interface to analog memory cells, APP core logic, and outside
 * world.
 *
 * 1. APP updates amem_empty/full and event_mux_o
 * 2. FPGA asserts read_next_i when external ADCs are ready
 * 3. APP switches column MUX and asserts sample_ready_o when settled  
 * 4. FPGA tells ADCs to sample, and asserts adc_done_i when conversion done  
 * 5. Cycle repeats until amem_empty=1 and event_mux_o agrees with last read
 * NOTE: the metadata need not be read syncronously with this interface
 * NOTE: triggered mode can increment/decrement read pointer depending on 
 *       which analog memory locations need to be read out
 *
 ******************************************************************************
*/

`timescale 100ps/1ps
`default_nettype none

module amem_core(
    // Intra-chip signals (controller, register map)
    input wire [2:0] w_ptr_down_i, // next location to write
    input wire incr_rd_ptr_i, // trigger increment read pointer
    input wire decr_rd_prt_i, // trigger decrement read pointer
	input wire circular_en_i, // chip reg setting to "cycle", 1 -> continuous

	// Signals to/from APP analog measurement circuitry
	input wire [7:0] WE_time_i, // TACs done on falling edge
	output wire read_en_o, // goes to RE
	output wire [2:0] event_mux_o, // goes to sel_TOT_event[3:1], outside world
	
	// Signals to/from outside world
	input wire clk,
	input wire rstb,
	input wire adc_done_i, // FPGA done taking a sample
	input wire read_next_i, // FPGA asking to advance to next location
	output wire sample_ready_o, // APP indicating MUX is set
	output wire amem_empty_o, // no new data
	output wire amem_full_o // asserted if circular_en = 0 and 8 locations full
);

endmodule // amem_core

