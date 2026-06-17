`timescale 100ps/1ps
`default_nettype none

  module controller #(parameter CLK_NBITS=8) (
		    input wire [CLK_NBITS-1:0] clk_cnt_i,

		    input wire [3:0] 	       valid_up_i,
		    input wire [CLK_NBITS-1:0] cnt8_up_0_i,
		    input wire [CLK_NBITS-1:0] cnt8_up_1_i,
		    input wire [CLK_NBITS-1:0] cnt8_up_2_i,
		    input wire [CLK_NBITS-1:0] cnt8_up_3_i,

		    input wire [3:0] 	       valid_down_i,
		    input wire [CLK_NBITS-1:0] cnt8_down_0_i,
		    input wire [CLK_NBITS-1:0] cnt8_down_1_i,
		    input wire [CLK_NBITS-1:0] cnt8_down_2_i,
		    input wire [CLK_NBITS-1:0] cnt8_down_3_i,

		    input wire [7:0] 	       WE_time_i,

		    output wire [2:0] 	       w_ptr_up_o,
		    output wire [2:0] 	       w_ptr_down_o,

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
	 if ( valid_up_i == 4'b0001 ) begin
	    ts_up[w_ptr_up] <= cnt8_up_0_i;
	    w_ptr_up <= (w_ptr_up + 3'h1) % 4'h8;
	 end
	 else if ( valid_up_i == 4'b0010 ) begin
	    ts_up[w_ptr_up] <= cnt8_up_1_i;
	    w_ptr_up <= (w_ptr_up + 3'h1) % 4'h8;
	 end
	 else if ( valid_up_i == 4'b0100 ) begin
	    ts_up[w_ptr_up] <= cnt8_up_2_i;
	    w_ptr_up <= (w_ptr_up + 3'h1) % 4'h8;
	 end
	 else if ( valid_up_i == 4'b1000 ) begin
	    ts_up[w_ptr_up] <= cnt8_up_3_i;
	    w_ptr_up <= (w_ptr_up + 3'h1) % 4'h8;
	 end
	 else
	   // TWO valids
	   if ( valid_up_i == 4'b0011 ) begin
	      ts_up[w_ptr_up] <= cnt8_up_0_i;
	      ts_up[w_ptr_up+1'b1] <= cnt8_up_1_i;
	      w_ptr_up <= (w_ptr_up + 3'h2) % 4'h8;
	   end
	   else if ( valid_up_i == 4'b0110 ) begin
	      ts_up[w_ptr_up] <= cnt8_up_1_i;
	      ts_up[w_ptr_up+1'b1] <= cnt8_up_2_i;
	      w_ptr_up <= (w_ptr_up + 3'h2) % 4'h8;
	   end
	   else if ( valid_up_i == 4'b1100 ) begin
	      ts_up[w_ptr_up] <= cnt8_up_2_i;
	      ts_up[w_ptr_up+1'b1] <= cnt8_up_3_i;
	      w_ptr_up <= (w_ptr_up + 3'h2) % 4'h8;
	   end
	   else if ( valid_up_i == 4'b1001 ) begin
	      ts_up[w_ptr_up] <= cnt8_up_3_i;
	      ts_up[w_ptr_up+1'b1] <= cnt8_up_0_i;
	      w_ptr_up <= (w_ptr_up + 3'h2) % 4'h8;
	   end
	   else
	     // THREE valids
	     if ( valid_up_i == 4'b0111 ) begin
		ts_up[w_ptr_up] <= cnt8_up_0_i;
		ts_up[w_ptr_up+3'h1] <= cnt8_up_1_i;
		ts_up[w_ptr_up+3'h2] <= cnt8_up_2_i;
		w_ptr_up <= (w_ptr_up + 3'h3) % 4'h8;
	     end
	     else if ( valid_up_i == 4'b1110 ) begin
		ts_up[w_ptr_up] <= cnt8_up_1_i;
		ts_up[w_ptr_up+3'h1] <= cnt8_up_2_i;
		ts_up[w_ptr_up+3'h2] <= cnt8_up_3_i;
		w_ptr_up <= (w_ptr_up + 3'h3) % 4'h8;
	     end
	     else if ( valid_up_i == 4'b1101 ) begin
		ts_up[w_ptr_up] <= cnt8_up_2_i;
		ts_up[w_ptr_up+3'h1] <= cnt8_up_3_i;
		ts_up[w_ptr_up+3'h2] <= cnt8_up_0_i;
		w_ptr_up <= (w_ptr_up + 3'h3) % 4'h8;
	     end
	     else if ( valid_up_i == 4'b1011 ) begin
		ts_up[w_ptr_up] <= cnt8_up_3_i;
		ts_up[w_ptr_up+3'h1] <= cnt8_up_0_i;
		ts_up[w_ptr_up+3'h2] <= cnt8_up_1_i;
	     end
	     else 
	       // FOUR valids
	       if ( valid_up_i == 4'b1111 ) begin    // XXX - Where do we start?
		  ts_up[w_ptr_up] <= cnt8_up_0_i;
		  ts_up[w_ptr_up+3'h1] <= cnt8_up_1_i;
		  ts_up[w_ptr_up+3'h2] <= cnt8_up_2_i;
		  ts_up[w_ptr_up+3'h3] <= cnt8_up_3_i;
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
	 if ( valid_down_i == 4'b0001 ) begin
	    ts_down[w_ptr_down] <= cnt8_down_0_i;
	    w_ptr_down <= (w_ptr_down + 3'h1) % 8;
	 end
	 else if ( valid_down_i == 4'b0010 ) begin
	    ts_down[w_ptr_down] <= cnt8_down_1_i;
	    w_ptr_down <= (w_ptr_down + 3'h1) % 8;
	 end
	 else if ( valid_down_i == 4'b0100 ) begin
	    ts_down[w_ptr_down] <= cnt8_down_2_i;
	    w_ptr_down <= (w_ptr_down + 3'h1) % 8;
	 end
	 else if ( valid_down_i == 4'b1000 ) begin
	    ts_down[w_ptr_down] <= cnt8_down_3_i;
	    w_ptr_down <= (w_ptr_down + 3'h1) % 8;
	 end
	 else
	   // TWO valids
	   if ( valid_down_i == 4'b0011 ) begin
	      ts_down[w_ptr_down] <= cnt8_down_0_i;
	      ts_down[w_ptr_down+1'b1] <= cnt8_down_1_i;
	      w_ptr_down <= (w_ptr_down + 3'h2) % 8;
	   end
	   else if ( valid_down_i == 4'b0110 ) begin
	      ts_down[w_ptr_down] <= cnt8_down_1_i;
	      ts_down[w_ptr_down+1'b1] <= cnt8_down_2_i;
	      w_ptr_down <= (w_ptr_down + 3'h2) % 8;
	   end
	   else if ( valid_down_i == 4'b1100 ) begin
	      ts_down[w_ptr_down] <= cnt8_down_2_i;
	      ts_down[w_ptr_down+1'b1] <= cnt8_down_3_i;
	      w_ptr_down <= (w_ptr_down + 3'h2) % 8;
	   end
	   else if ( valid_down_i == 4'b1001 ) begin
	      ts_down[w_ptr_down] <= cnt8_down_3_i;
	      ts_down[w_ptr_down+1'b1] <= cnt8_down_0_i;
	      w_ptr_down <= (w_ptr_down + 3'h2) % 8;
	   end
	   else
	     // THREE valids
	     if ( valid_down_i == 4'b0111 ) begin
		ts_down[w_ptr_down] <= cnt8_down_0_i;
		ts_down[w_ptr_down+3'h1] <= cnt8_down_1_i;
		ts_down[w_ptr_down+3'h2] <= cnt8_down_2_i;
		w_ptr_down <= (w_ptr_down + 3'h3) % 8;
	     end
	     else if ( valid_down_i == 4'b1110 ) begin
		ts_down[w_ptr_down] <= cnt8_down_1_i;
		ts_down[w_ptr_down+3'h1] <= cnt8_down_2_i;
		ts_down[w_ptr_down+3'h2] <= cnt8_down_3_i;
		w_ptr_down <= (w_ptr_down + 3'h3) % 8;
	     end
	     else if ( valid_down_i == 4'b1101 ) begin
		ts_down[w_ptr_down] <= cnt8_down_2_i;
		ts_down[w_ptr_down+3'h1] <= cnt8_down_3_i;
		ts_down[w_ptr_down+3'h2] <= cnt8_down_0_i;
		w_ptr_down <= (w_ptr_down + 3'h3) % 8;
	     end
	     else if ( valid_down_i == 4'b1011 ) begin
		ts_down[w_ptr_down] <= cnt8_down_3_i;
		ts_down[w_ptr_down+3'h1] <= cnt8_down_0_i;
		ts_down[w_ptr_down+3'h2] <= cnt8_down_1_i;
	     end
	     else 
	       // FOUR valids
	       if ( valid_down_i == 4'b1111 ) begin    // XXX - Where do we start?
		  ts_down[w_ptr_down] <= cnt8_down_0_i;
		  ts_down[w_ptr_down+3'h1] <= cnt8_down_1_i;
		  ts_down[w_ptr_down+3'h2] <= cnt8_down_2_i;
		  ts_down[w_ptr_down+3'h3] <= cnt8_down_3_i;
		  w_ptr_down <= (w_ptr_down + 3'h4) % 8;
	       end
      end // else: !if( rstb == 1'b0 )
   end // always @ (posedge clk, negedge rstb )

   // Instantiate analog memory core
   amem_core #(.DEPTH(8)) amem_core_tb (
      .clk(clk),
      .rstb(rstb),
      .trigger_i(1'b0),
      .valid_cells_i(8'b11111111),   
      .LI_valid_i(1'b0),     
      .triggered_mode_i(1'b0),
      .wr_ptr_i(w_ptr_down),
      .circular_en_i(1'b1),
      .WE_time_i(WE_time_i),
      .adc_done_i(1'b0),
      .read_next_i(1'b0)
   );   

endmodule // controller



	 
