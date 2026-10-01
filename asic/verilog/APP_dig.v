`timescale 100ps/1ps
`default_nettype none

  /*
   * APP_dig is the top-level digital block.  All other digital logic is
   * instantiated in it.
   * 
   * There are a lot of missing interface bits that will get filled in as
   * more of the digital logic gets implemented.
   */

  module APP_dig(
		 // From analog block
		 input wire 	   cmp_i,
		 input wire [7:0]  WE_time_i,

		 // From external control
		 input wire 	   trigger_i,


		 // To analog block
		 output wire 	   read_en_o,
		 output wire [3:0] event_mux_o,
		 output wire 	   LI_end_o,
		 
		 input wire 	   clk,
		 input wire 	   rstb
		 );

   localparam CLK_NBITS = 8;  // Number of bits in TimeStamp
   
   wire [CLK_NBITS-1:0]     clk_cnt;
   
   clk_cnter #(.CLK_NBITS(CLK_NBITS)) clock_cnt (
						 .clk_cnt_o( clk_cnt ),
						 .clk( clk ), 
						 .rstb( rstb )
						 );
			 

   wire [3:0] valid_up, valid_down;
   wire [CLK_NBITS-1:0] cnt_up,
			cnt_down;
   
   analog_if #(.CLK_NBITS(CLK_NBITS)) ai ( 
                  .cmp_i( cmp_i ), .clk_cnt_i( clk_cnt ),
                  .valid_up_o( valid_up ),
		  .cnt_up_o( cnt_up ),
		  .valid_down_o( valid_down ),
		  .cnt_down_o( cnt_down ),
		  .clk( clk ), 
		  .rstb( rstb )
		  );

   wire [2:0] w_ptr_up;
   wire [2:0] w_ptr_down;

   wire [3:0] event_mux;
   wire       sample_ready_o;
   wire       amem_empty_o;
   wire       amem_full_o;

   wire       LI_active;
   
   
   controller #(.CLK_NBITS(CLK_NBITS)) cntl (
                  .clk_cnt_i( clk_cnt ),
                  .valid_up_i( valid_up ),
		  .cnt_up_i( cnt_up_0 ),
		  .valid_down_i( valid_down ),
		  .cnt8_down_i( cnt_down ),
		  .WE_time_i( WE_time_i ),
		  .trigger_i( trigger_i ),
	
	          .w_ptr_up_o( w_ptr_up ), .w_ptr_down_o( w_ptr_down ),
                  .read_en_o( read_en_o ),
		  .event_mux_o( event_mux ),
		  .sample_ready_o( sample_ready_o ),
		  .amem_empty_o( amem_empty_o ),
	          .amem_full_o( amem_full_o ),
		  .LI_active_o( LI_active ),
		  .LI_end_o( LI_end_o ),
					     
		  .clk( clk ), 
		  .rstb( rstb )
		  );

   LI_metadata #(.CLK_NBITS(CLK_NBITS)) LI_meta (
						 .valid_i( valid_up ),
						 .ts_i( cnt_up ),
						 .LI_active_i( LI_active ),
						 .LI_end_i( LI_end_o ),
						 .clk( clk ),
						 .rstb( rstb )
						 );
   
   

endmodule // APP_dig
