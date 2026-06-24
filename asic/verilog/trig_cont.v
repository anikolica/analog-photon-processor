`timescale 100ps/1ps
`default_nettype none

  /*
   trig_cont
   
   trig_start is the first ToT in the LI window.
   trig_end is one past the last ToT in the LI window
   */
module trig_cont(
		    input wire [2:0]  w_ptr_i,
		    
		    input wire 	      LI_start_i, // pulses at beginning of LI
		    input wire 	      LI_end_i, // pulses at end of LI
//		    input wire 	      LI_active_i, // high during an LI

		    input wire 	      trigger_i, // Global trigger
		    input wire 	      read_en_i,
		    input wire [3:0]  event_mux_i,  // bit 3 is valid
		 
		    output wire [7:0] trigd_o,
		 
		    input wire 	      clk,
		    input wire 	      rstb
		    );

   reg [2:0] trig_start;   // The start of a LI/trigger period
   reg [2:0] trig_end;     // The end of a LI/trigger period
   reg [2:0] trig_idx;     // An index used for stepping through the ToTs

   reg [7:0] trigd;
   assign trigd_o = trigd;

   // Handle trigger start pointer
   always @(posedge clk, negedge rstb )
     begin
	if ( rstb == 1'b0 ) begin  // I don't like the constants, but oh well
	   trig_start <= 3'b000;   
	end
	else begin
	   if ( LI_start_i ) begin
	      trig_start <= w_ptr_i;
	   end
	end
     end

   // Handle trigger end pointer
   always @(posedge clk, negedge rstb )
     begin
	if ( rstb == 1'b0 )
	  ;                            // Don't care about trig_end on reset
	else begin
	   if ( trigger_i )            // On trigger move trig_end
	     trig_end <= w_ptr_i;
	   
	   if ( LI_end_i )             // At end of LI fix trig_end
	     trig_end <= w_ptr_i;  // trig_end is the last written + 1
	   else if ( LI_start_i )
	     trig_end <= w_ptr_i;
	end
     end

   reg in_trig;
   reg LI_end_seen;
   
   always @(posedge clk, negedge rstb )
     begin
	if ( rstb == 1'b0 ) begin
	   trig_idx <= 3'b000;     // I don't like the constant
	   trigd <= 8'h00;
	   in_trig <= 1'b0;
	   LI_end_seen <= 1'b0;
	end	   
	else begin
	   if ( LI_end_i && in_trig ) LI_end_seen <= 1'b1;

	   if ( read_en_i && event_mux_i[3] )  // clear trigd on read
	     trigd[event_mux_i[2:0]] <= 1'b0;
	   // Don't need to clear skipped events as they will not
	   // have been triggered, by definition.
	   
	   if ( trigger_i ) begin
	      in_trig <= 1'b1;
	      trigd[trig_idx] <= 1'b1;
	      trig_idx <= trig_idx + 1'b1;
	   end
	   else begin
	      if ( ! in_trig )
		;                 // If not in triggered LI, do nothing
	      else begin          // We are in a trigger LI
		 if ( trig_idx != w_ptr_i ) begin // NOT caught up to wr ptr
		    trigd[trig_idx] <= 1'b1;   // We can keep setting this
		    
		 if ( (trig_idx + 1'b1) == w_ptr_i ) // We have them all
		   if ( LI_end_seen ) begin       // At end of LI clear in_trig
		      in_trig <= 1'b0;
		      LI_end_seen <= 1'b0;
		      trig_idx <= trig_start;
		   end
		   else         // NOT LI_end_send
		     ;		// 
		 else  // not at end with trigger active
		   trig_idx <= trig_idx + 1'b1;
	      end // if ( in_trig )
	   end // else: !if( trigger_i )
	end // else: !if( rstb == 1'b0 )
     end // always @ (posedge clk, negedge rstb )
   
	
		
   
endmodule // LI_control
