`timescale 100ps/1ps
`default_nettype none

  module controller #(parameter CLK_NBITS=8) (
		    input wire [CLK_NBITS-1:0] clk_cnt_i,

		    input wire [3:0] 	       valid_up_i,
		    input wire [CLK_NBITS-1:0] cnt_up_i,

		    input wire [3:0] 	       valid_down_i,
		    input wire [CLK_NBITS-1:0] cnt_down_i,

		    input wire [7:0] 	       WE_time_i,
		    input wire 		       trigger_i,
					      
		    output wire [2:0] 	       w_ptr_up_o,
		    output wire [2:0] 	       w_ptr_down_o,

		    output wire 	       read_en_o,
		    output wire [3:0] 	       event_mux_o,
		    output wire 	       sample_ready_o,
		    output wire 	       amem_empty_o,
		    output wire 	       amem_full_o,
		    output wire 	       LI_active_o,
		    output wire 	       LI_end_o,

		    input wire 		       clk,
		    input wire 		       rstb
		    );

   reg [7:0][CLK_NBITS-1:0] ts_up;
   reg [7:0][CLK_NBITS-1:0] ts_down;
   
   /*
    * Write pointer (up)-
    *   Points to NEXT location to write to
    *   Clear on reset
    *   Advance on valid_up
    *   Wrap (for now -- need to add control)
    */
   reg [2:0] w_ptr_up;
   assign w_ptr_up_o = w_ptr_up;
   

   always @(posedge clk, negedge rstb ) begin
      if ( rstb == 1'b0 )
	begin
	   w_ptr_up <= 3'h0;
	   
	   ts_up[0] <= 8'h00;
	   ts_up[1] <= 8'h00;
	   ts_up[2] <= 8'h00;
	   ts_up[3] <= 8'h00;
	   ts_up[4] <= 8'h00;
	   ts_up[5] <= 8'h00;
	   ts_up[6] <= 8'h00;
	   ts_up[7] <= 8'h00;
	end
      else begin
	 // ONE valid
	 if ( (valid_up_i == 4'b0001) || (valid_up_i == 4'b0010) ||
	      (valid_up_i == 4'b0100) || (valid_up_i == 4'b1000) ) begin
	    ts_up[w_ptr_up] <= cnt_up_i;
	    w_ptr_up <= (w_ptr_up + 3'h1) % 4'h8;
	 end
	 else
	   // TWO valids
	   if ( (valid_up_i == 4'b0011) || (valid_up_i == 4'b0110) ||
		(valid_up_i == 4'b1100) || (valid_up_i == 4'b1001)  ) begin
	      ts_up[w_ptr_up] <= cnt_up_i;
	      ts_up[w_ptr_up+1'b1] <= cnt_up_i;
	      w_ptr_up <= (w_ptr_up + 3'h2) % 4'h8;
	   end
	   else
	     // THREE valids
	     if ( (valid_up_i == 4'b0111) || (valid_up_i == 4'b1110) ||
		  (valid_up_i == 4'b1101) || (valid_up_i == 4'b1011)  ) begin
		ts_up[w_ptr_up] <= cnt_up_i;
		ts_up[w_ptr_up+3'h1] <= cnt_up_i;
		ts_up[w_ptr_up+3'h2] <= cnt_up_i;
		w_ptr_up <= (w_ptr_up + 3'h3) % 4'h8;
	     end
	     else 
	       // FOUR valids
	       if ( valid_up_i == 4'b1111 ) begin    // XXX - Where do we start?
		  ts_up[w_ptr_up] <= cnt_up_i;
		  ts_up[w_ptr_up+3'h1] <= cnt_up_i;
		  ts_up[w_ptr_up+3'h2] <= cnt_up_i;
		  ts_up[w_ptr_up+3'h3] <= cnt_up_i;
		  w_ptr_up <= (w_ptr_up + 3'h4) % 4'h8;
	       end
      end // else: !if( rstb == 1'b0 )
   end // always @ (posedge clk, negedge rstb )

   

   
   /*
    * Write pointer (down)-
    *   Points to NEXT location to write to
    *   Clear on reset
    *   Advance on valid_down
    *   Wrap (for now -- need to add control)
    */
   reg [2:0] w_ptr_down;
   assign w_ptr_down_o = w_ptr_down;

   always @(posedge clk, negedge rstb ) begin
      if ( rstb == 1'b0 )
	begin
	   w_ptr_down <= 3'h0;
	   
	   ts_down[0] <= 8'h00;
	   ts_down[1] <= 8'h00;
	   ts_down[2] <= 8'h00;
	   ts_down[3] <= 8'h00;
	   ts_down[4] <= 8'h00;
	   ts_down[5] <= 8'h00;
	   ts_down[6] <= 8'h00;
	   ts_down[7] <= 8'h00;
	end
      else begin
	 // ONE valid
	 if ( (valid_down_i == 4'b0001) || (valid_down_i == 4'b0010) ||
	      (valid_down_i == 4'b0100) || (valid_down_i == 4'b1000) ) begin
	    ts_down[w_ptr_down] <= cnt_down_i;
	    w_ptr_down <= (w_ptr_down + 3'h1) % 4'h8;
	 end
	 else
	   // TWO valids
	   if ( (valid_down_i == 4'b0011) || (valid_down_i == 4'b0110) ||
		(valid_down_i == 4'b1100) || (valid_down_i == 4'b1001)  ) begin
	      ts_down[w_ptr_down] <= cnt_down_i;
	      ts_down[w_ptr_down+1'b1] <= cnt_down_i;
	      w_ptr_down <= (w_ptr_down + 3'h2) % 4'h8;
	   end
	   else
	     // THREE valids
	     if ( (valid_down_i == 4'b0111) || (valid_down_i == 4'b1110) ||
		  (valid_down_i == 4'b1101) || (valid_down_i == 4'b1011)  ) begin
		ts_down[w_ptr_down] <= cnt_down_i;
		ts_down[w_ptr_down+3'h1] <= cnt_down_i;
		ts_down[w_ptr_down+3'h2] <= cnt_down_i;
		w_ptr_down <= (w_ptr_down + 3'h3) % 4'h8;
	     end
	     else 
	       // FOUR valids
	       if ( valid_down_i == 4'b1111 ) begin    // XXX - Where do we start?
		  ts_down[w_ptr_down] <= cnt_down_i;
		  ts_down[w_ptr_down+3'h1] <= cnt_down_i;
		  ts_down[w_ptr_down+3'h2] <= cnt_down_i;
		  ts_down[w_ptr_down+3'h3] <= cnt_down_i;
		  w_ptr_down <= (w_ptr_down + 3'h4) % 4'h8;
	       end
      end // else: !if( rstb == 1'b0 )
   end // always @ (posedge clk, negedge rstb )

   wire LI_active;
   wire LI_start;
   wire LI_end;
   assign LI_active_o = LI_active;
   assign LI_end_o = LI_end;


   wire [7:0] triggered;
   
   
   // Instantiate analog memory core
   amem_core #(.DEPTH(8)) amem_core_tb (
      .clk(clk),
      .rstb(rstb),
      .trigger_i(1'b0),
      .valid_cells_i(triggered),   
      .LI_valid_i( LI_active ),     
      .triggered_mode_i(1'b0),
      .wr_ptr_i(w_ptr_down),
      .circular_en_i(1'b1),
      .WE_time_i(WE_time_i),
      .adc_done_i(1'b0),
      .read_next_i(1'b0),
      .read_en_o( read_en_o ),
      .event_mux_o( event_mux_o ),
      .sample_ready_o( sample_ready_o ),
      .amem_empty_o( amem_empty_o ),
      .amem_full_o( amem_full_o )
   );   

   // Instantiate LI controller
   LI_control LI_cont (
		       .valid_up_i( valid_up_i ),
		       .LI_length_i( 8'hA ),     // XXX -- from register
		       .LI_start_o( LI_start ),
		       .LI_end_o( LI_end ),
		       .LI_active_o( LI_active ),
		       .clk( clk ),
		       .rstb( rstb )
		       );

   trig_cont trigger (
		      .w_ptr_i( w_ptr_up ),
		      .LI_start_i( LI_start ),
		      .LI_end_i( LI_end ),
		      .trigger_i( trigger_i ),
		      .read_en_i( read_en_o ),
		      .event_mux_i( event_mux_o ),
		      .trigd_o( triggered ),
		      .clk( clk ),
		      .rstb( rstb )
		      );
   
   
endmodule // controller



	 
