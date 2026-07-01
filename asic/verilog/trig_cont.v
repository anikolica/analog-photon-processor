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
/*
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
*/
//   reg in_trig;
//   reg LI_end_seen;

   /*
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
*/

   reg [1:0] state;
   reg [1:0] next_state;
   reg [7:0] next_trigd;
   reg [2:0] next_trig_start;
   reg [2:0] next_trig_end;
   reg [2:0] next_trig_idx;
   reg [2:0] last_wptr;
   reg [2:0] next_last_wptr;
   
   
  localparam [1:0]
                IDLE  = 2'h0,
                WAIT_TRIG = 2'h1,
                WAIT_LI_END = 2'h2,
                MARK_TOTS = 2'h3;
   
  
   always @(*) begin
      if ( rstb == 1'b0 ) begin
	 next_state = IDLE;
	 next_trigd = 8'h0;
	 next_trig_start = 3'h00;
	 next_trig_end = 3'h00;
	 next_trig_idx = 3'h00;
	 next_last_wptr = 3'h00;
      end
      
      next_trig_start = trig_start;
      next_trig_end = trig_end;
      next_trig_idx = trig_idx;
      next_state = state;
      next_trigd = trigd;
      next_last_wptr = last_wptr;
      

//      next_trigd = 8'h00;
//      next_state = IDLE;
            
      if ( read_en_i && event_mux_i[3] )  // clear trigd on read
	next_trigd = trigd & ~(1'b1 << event_mux_i[2:0]);

      if ( last_wptr != w_ptr_i )
	next_last_wptr = w_ptr_i;
      
      case ( state )
	// We are not marking ToT as triggered and we are not in an LI window
	IDLE: begin
	   // Marking ToTs as triggered
	   if ( trig_idx != trig_end ) begin
	      next_trigd = trigd | (1'b1 << trig_idx);
	      next_trig_idx = trig_idx + 1'b1;
	   end
	   
	   if ( LI_start_i ) begin
	      next_trig_start = last_wptr;
	      next_state = WAIT_TRIG;
	   end
	   else
	     next_state = IDLE;
	end // case: IDLE
	
	// We are in LI window waint for a trigger or LI end
	WAIT_TRIG: begin
	   if ( trigger_i ) begin
	      next_trig_idx = trig_start;
	      next_state = WAIT_LI_END;
	   end
	   else begin
	      // Marking ToTs as triggered
	      if ( trig_idx != trig_end ) begin
		 next_trigd = trigd | (1'b1 << trig_idx);
		 next_trig_idx = trig_idx + 1'b1;
	      end

	      if ( LI_end_i ) next_state = IDLE;
	      else next_state = WAIT_TRIG;
	   end
	end // case: WAIT_TRIG
	
	// We are waiting for the end of LI window
	WAIT_LI_END: begin
	   next_trig_end = last_wptr;
	   // Marking ToTs as triggered
	   if ( trig_idx != trig_end ) begin
	      next_trigd = trigd | (1'b1 << trig_idx);
	      next_trig_idx = trig_idx + 1'b1;
	   end
	     
	   if ( LI_end_i ) next_state = IDLE;
	   else next_state = WAIT_LI_END;
	end // case: WAIT_LI_END

      endcase // case ( state )
   end // always @ (*)
   
   always @(posedge clk, negedge rstb )
     if ( rstb == 1'b0 ) begin
	state <= IDLE;
	trigd <= 8'h00;
	trig_start <= 3'h0;
	trig_end <= 3'h0;
	trig_idx <= 3'h0;
	last_wptr <= 3'h0;
     end
     else begin
	state <= next_state;
	trigd <= next_trigd;
	trig_start <= next_trig_start;
	trig_end <= next_trig_end;
	trig_idx <= next_trig_idx;
	last_wptr <= next_last_wptr;
     end
   
   
	  
	
	     
	
		
   
endmodule // LI_control
