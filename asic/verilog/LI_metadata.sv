`timescale 100ps/1ps
`default_nettype none

  /*
   * LI_metadata - collects the metadata about the Long Integration (LI) windows.
   *   In particular, the time stamp of the first TOT in the window and the
   *   number of TOTs in the window.  Up to 4 simultaneous windows are allowed.
   * 
   */
  module LI_metadata #(parameter CLK_NBITS=8) (
		     input wire [3:0] 		valid_i, // which of the 4 position from analog_if are valid -
					                 //   we only count them to get N TOT
		     input wire [CLK_NBITS-1:0] ts_i,    // Timestamp of TOT - only need the first
		     input wire [1:0] 		w_ptr_i,
		     input wire 		LI_active_i, // True if LI window is open
		     input wire 		LI_end_i,    // Pulses when LI window ends
		     
		     input wire 		clk,
		     input wire 		rstb
		     );

   reg [1:0] ping_pong;

   reg [3:0][CLK_NBITS-1:0] LI_ts;
   reg [3:0][3:0] Ntots;

   wire 	  valid;
   assign valid = |valid_i;
   wire [2:0]	  v_count;
   assign v_count = ((valid_i == 4'b0001 || valid_i == 4'b0010 || valid_i == 4'b0100 || valid_i == 4'b1000) ? 3'h1 :
		     (valid_i == 4'b0011 || valid_i == 4'b0110 || valid_i == 4'b1100 || valid_i == 4'b1001) ? 3'h2 :
		     (valid_i == 4'b0111 || valid_i == 4'b1110 || valid_i == 4'b1101 || valid_i == 4'b1011) ? 3'h3 :
		     (valid_i == 4'b1111) ? 3'h4 : 3'h0);
   
   always_ff @(posedge clk, negedge rstb )
     begin
	if ( rstb == 1'b0 )
	  begin
	     ping_pong <= 2'b00;
	     
	     LI_ts[2'b00] <= {CLK_NBITS{1'b0}};
	     LI_ts[2'b01] <= {CLK_NBITS{1'b0}};
	     LI_ts[2'b10] <= {CLK_NBITS{1'b0}};
	     LI_ts[2'b11] <= {CLK_NBITS{1'b0}};
	  
	     Ntots[2'b00] <= 4'h0;
	     Ntots[2'b01] <= 4'h0;
	     Ntots[2'b10] <= 4'h0;
	     Ntots[2'b11] <= 4'h0;
	  end
	else
	  begin
	     if ( valid && !LI_active_i )   // start of LI
	       begin
		  LI_ts[ping_pong] <= ts_i;
		  Ntots[ping_pong] <= {1'b0, v_count};
	       end
	     else if ( valid && LI_active_i )
	       begin
		  Ntots[ping_pong] <= Ntots[ping_pong] + {1'b0, v_count};
	       end
	     else if ( LI_end_i )
	       begin
		  ping_pong <= (ping_pong == 2'b11) ? 2'b00 : (ping_pong + 2'b01);
	       end
	     
	  end // else: !if( rstb = 1'b0 )
     end // always @ (posedge clk, negedge rstb )
   


endmodule // LI_metadata

   
   
