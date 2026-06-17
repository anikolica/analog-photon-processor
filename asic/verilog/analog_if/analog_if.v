`timescale 100ps/1ps
`default_nettype none

  /*
   analog_if synchronizes the comparitor signal from the analog domain to the system clock.
   It also captures the value of the clock counter when the comparitor signal goes high and
   again when it goes low.   Because there can be multiple comparitor threshold crossings in
   a single clock cycle, up to four counts are provided for.  A 4-bit vector is also provided
   to indicate which of the four counts are valid.
   
   It is guaranteed that if there are multiple threshold crossings, the valid bits will be
   adjacent, mod 4.
   */
  module analog_if #(parameter CLK_NBITS=8) (
		    input wire 	      cmp_i, // async !!

		    input wire [CLK_NBITS-1:0] clk_cnt_i,

		    output wire [3:0] valid_up_o,
		    output wire [CLK_NBITS-1:0] cnt8_up_0_o,
		    output wire [CLK_NBITS-1:0] cnt8_up_1_o,
		    output wire [CLK_NBITS-1:0] cnt8_up_2_o,
		    output wire [CLK_NBITS-1:0] cnt8_up_3_o,

		    output wire [3:0] valid_down_o,
		    output wire [CLK_NBITS-1:0] cnt8_down_0_o,
		    output wire [CLK_NBITS-1:0] cnt8_down_1_o,
		    output wire [CLK_NBITS-1:0] cnt8_down_2_o,
		    output wire [CLK_NBITS-1:0] cnt8_down_3_o,

		    input wire 	      clk,
		    input wire 	      rstb
		    );

// XXX - need to write a pair of assertions to guarantee the valid bits are always adjacent.

   
   /*
    * Rising edge of comparitor
    */
   wire [3:0] cmp_acks_up;
   wire [3:0] ups;
   
   cmp_sync cs_up( .cmp_i( cmp_i ), .cmp_acks_i( cmp_acks_up ),
		.cmp_syncs_o ( ups ), .rstb( rstb ) );

   cmp_latch cl_up( .cmp_syncs_i( ups ), .cmp_acks_o( cmp_acks_up ),
		 .clk( clk ), .rstb( rstb ));

   reg [CLK_NBITS-1:0]  cnt8_up_0;
   reg [CLK_NBITS-1:0]  cnt8_up_1;
   reg [CLK_NBITS-1:0]  cnt8_up_2;
   reg [CLK_NBITS-1:0]  cnt8_up_3;

   reg [3:0] valid_up;

   assign cnt8_up_0_o = cnt8_up_0;
   assign cnt8_up_1_o = cnt8_up_1;
   assign cnt8_up_2_o = cnt8_up_2;
   assign cnt8_up_3_o = cnt8_up_3;

   assign valid_up_o = valid_up;
   

//   initial
//     $monitor( "%0t: ups = %h valid = %h", $time, ups, valid_up );

   always @(posedge clk, negedge rstb ) begin
      if ( rstb == 1'b0 ) begin
	 cnt8_up_0 <= {CLK_NBITS{1'b0}};
	 cnt8_up_1 <= {CLK_NBITS{1'b0}};
	 cnt8_up_2 <= {CLK_NBITS{1'b0}};
	 cnt8_up_3 <= {CLK_NBITS{1'b0}};

	 valid_up <= 4'b0000;
      end
      else begin
	 if ( ups[0] ) cnt8_up_0 <= clk_cnt_i;
	 if ( ups[1] ) cnt8_up_1 <= clk_cnt_i;
	 if ( ups[2] ) cnt8_up_2 <= clk_cnt_i;
	 if ( ups[3] ) cnt8_up_3 <= clk_cnt_i;

	 valid_up <= ups;
      end // else: !if( rstb == 1'b0 )

   end // always @ (posedge clk, negedge rstb )
   


   /*
    * Falling edge of comparitor
    */
   wire [3:0] cmp_acks_down;
   wire [3:0] downs;
   
   cmp_sync cs_down( .cmp_i( ~cmp_i ), .cmp_acks_i( cmp_acks_down ),
		.cmp_syncs_o ( downs ), .rstb( rstb ) );

   cmp_latch cl_down( .cmp_syncs_i( downs ), .cmp_acks_o( cmp_acks_down ),
		 .clk( clk ), .rstb( rstb ));

   reg [CLK_NBITS-1:0]  cnt8_down_0;
   reg [CLK_NBITS-1:0]  cnt8_down_1;
   reg [CLK_NBITS-1:0]  cnt8_down_2;
   reg [CLK_NBITS-1:0]  cnt8_down_3;

   reg [3:0] valid_down;

   assign cnt8_down_0_o = cnt8_down_0;
   assign cnt8_down_1_o = cnt8_down_1;
   assign cnt8_down_2_o = cnt8_down_2;
   assign cnt8_down_3_o = cnt8_down_3;

   assign valid_down_o = valid_down;
   

//   initial
//     $monitor( "%0t: downs = %h valid = %h", $time, downs, valid_down );

   always @(posedge clk, negedge rstb ) begin
      if ( rstb == 1'b0 ) begin
	 cnt8_down_0 <= {CLK_NBITS{1'b0}};
	 cnt8_down_1 <= {CLK_NBITS{1'b0}};
	 cnt8_down_2 <= {CLK_NBITS{1'b0}};
	 cnt8_down_3 <= {CLK_NBITS{1'b0}};

	 valid_down <= 4'b0000;
      end
      else begin
	 if ( downs[0] ) cnt8_down_0 <= clk_cnt_i;
	 if ( downs[1] ) cnt8_down_1 <= clk_cnt_i;
	 if ( downs[2] ) cnt8_down_2 <= clk_cnt_i;
	 if ( downs[3] ) cnt8_down_3 <= clk_cnt_i;

	 valid_down <= downs;
      end // else: !if( rstb == 1'b0 )

   end // always @ (posedge clk, negedge rstb )
   
endmodule // analog_if


	 
