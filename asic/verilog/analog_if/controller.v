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

		    input wire [8:1] 	       WE_ampl, 
		    input wire [8:1] 	       WE_time,
					      
		    input wire 		       clk,
		    input wire 		       rstb
		    );

   /*
    * Dummy placeholder
    */
   
endmodule // controller



	 
