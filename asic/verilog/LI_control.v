`timescale 100ps/1ps
`default_nettype none

  /*
   LI_control figures out the beginning and end of Long Integrate (LI) windows, which also
   corresponds to event windows in triggered mode.
   
   Its inputs are the valid_up vector from analog_if indicating a rising edge of a pulse has
   been seen, and the length of the LI window in clock ticks.
   Its outputs are pulses for the start and end of the LI window and signal indicating whether
   and LI window is active.
   
   It is important to note that if an LI window ends and second one immediately starts, the
   LI active signal will stay high, however, the start and end signals will pulse.
   */
module LI_control(
		    input wire [3:0] 	       valid_up_i,
		    
		    input wire [7:0] 	       LI_length_i, // Length of LI in clocks
		    
		    output wire 	       LI_start_o, // pulses at beginning of LI
		    output wire 	       LI_end_o, // pulses at end of LI
		    output wire 	       LI_active_o, // high during an LI
		    
		    input wire 		       clk,
		    input wire 		       rstb
		    );

endmodule // LI_control
