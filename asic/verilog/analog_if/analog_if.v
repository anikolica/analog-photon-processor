`timescale 100ps/1ps
`default_nettype none

  module analog_if (
		    input wire cmp_i,           // async !!

		    output wire [3:0] valid_up_o,
		    output wire [7:0] cnt8_up_0_o,
		    output wire [7:0] cnt8_up_1_o,
		    output wire [7:0] cnt8_up_2_o,
		    output wire [7:0] cnt8_up_3_o,

		    output wire [3:0] valid_down_o,
		    output wire [7:0] cnt8_down_0_o,
		    output wire [7:0] cnt8_down_1_o,
		    output wire [7:0] cnt8_down_2_o,
		    output wire [7:0] cnt8_down_3_o,

		    input wire clk,
		    input wire rstb
		    );


   /*
    * Clock counter
    */
   reg [7:0] clk_cnt;

   always @(posedge clk, negedge rstb ) begin
      if ( rstb == 1'b0 ) clk_cnt <= 8'h00;
      else clk_cnt <= clk_cnt + 1'b1;
   end


   /*
    * Rising edge of comparitor
    */
   wire [3:0] cmp_acks_up;
   wire [3:0] ups;
   
   cmp_sync cs_up( .cmp_i( cmp_i ), .cmp_acks_up_i( cmp_acks_up ),
		.ups_o ( ups ), .rstb( rstb ) );

   cmp_latch cl_up( .ups_i( ups ), .cmp_acks_up_o( cmp_acks_up ),
		 .clk( clk ), .rstb( rstb ));

   reg [7:0]  cnt8_up_0;
   reg [7:0]  cnt8_up_1;
   reg [7:0]  cnt8_up_2;
   reg [7:0]  cnt8_up_3;

   reg [3:0] valid_up;

   assign cnt8_up_0_o = cnt8_up_0;
   assign cnt8_up_1_o = cnt8_up_1;
   assign cnt8_up_2_o = cnt8_up_2;
   assign cnt8_up_3_o = cnt8_up_3;

   assign valid_up_o = valid_up;
   

//   initial
//     $monitor( "%0t: ups = %h valid = %h", $time, ups, valid );

   always @(posedge clk, negedge rstb ) begin
      if ( rstb == 1'b0 ) begin
	 cnt8_up_0 <= 8'h00;
	 cnt8_up_1 <= 8'h00;
	 cnt8_up_2 <= 8'h00;
	 cnt8_up_3 <= 8'h00;

	 valid_up <= 4'b0000;
      end
      else begin
	 if ( ups[0] ) cnt8_up_0 <= clk_cnt;
	 if ( ups[1] ) cnt8_up_1 <= clk_cnt;
	 if ( ups[2] ) cnt8_up_2 <= clk_cnt;
	 if ( ups[3] ) cnt8_up_3 <= clk_cnt;

	 valid_up <= ups;
      end // else: !if( rstb == 1'b0 )

   end // always @ (posedge clk, negedge rstb )
   


   /*
    * Falling edge of comparitor
    */
   wire [3:0] cmp_acks_down;
   wire [3:0] downs;
   
   cmp_sync cs_down( .cmp_i( ~cmp_i ), .cmp_acks_up_i( cmp_acks_down ),
		.ups_o ( downs ), .rstb( rstb ) );

   cmp_latch cl_down( .ups_i( downs ), .cmp_acks_up_o( cmp_acks_down ),
		 .clk( clk ), .rstb( rstb ));

   reg [7:0]  cnt8_down_0;
   reg [7:0]  cnt8_down_1;
   reg [7:0]  cnt8_down_2;
   reg [7:0]  cnt8_down_3;

   reg [3:0] valid_down;

   assign cnt8_down_0_o = cnt8_down_0;
   assign cnt8_down_1_o = cnt8_down_1;
   assign cnt8_down_2_o = cnt8_down_2;
   assign cnt8_down_3_o = cnt8_down_3;

   assign valid_down_o = valid_down;
   

//   initial
//     $monitor( "%0t: ups = %h valid = %h", $time, ups, valid );

   always @(posedge clk, negedge rstb ) begin
      if ( rstb == 1'b0 ) begin
	 cnt8_down_0 <= 8'h00;
	 cnt8_down_1 <= 8'h00;
	 cnt8_down_2 <= 8'h00;
	 cnt8_down_3 <= 8'h00;

	 valid_down <= 4'b0000;
      end
      else begin
	 if ( downs[0] ) cnt8_down_0 <= clk_cnt;
	 if ( downs[1] ) cnt8_down_1 <= clk_cnt;
	 if ( downs[2] ) cnt8_down_2 <= clk_cnt;
	 if ( downs[3] ) cnt8_down_3 <= clk_cnt;

	 valid_down <= downs;
      end // else: !if( rstb == 1'b0 )

   end // always @ (posedge clk, negedge rstb )
   
endmodule // analog_if


	 
