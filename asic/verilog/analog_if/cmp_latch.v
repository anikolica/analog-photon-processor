`timescale 100ps/1ps
`default_nettype none

/*
 * WARNING -- XXX --
 * This module is UNSAFE.  It does not take into account cases where cmp is
 * changing near the clock edge.  TB Fixed!
 */
module cmp_latch (
		 input wire  [3:0] cmp_syncs_i, // async !!!
		  
		 output wire [3:0] cmp_acks_o,

		 input wire clk,
		 input wire  rstb
		 );

	
//   reg ping_up;
//   reg pong_up;

   reg [3:0] cmp_acks;
   

   assign cmp_acks_o = cmp_acks;


   genvar    i;
   generate
      for (i=0; i<4; i=i+1 ) begin : acks
	 
	 always @(posedge clk, negedge rstb)
	   begin
	      if ( rstb == 1'b0 )
		begin
		   cmp_acks[i] <= 1'b0;
		end
	      else
		begin
		   if ( cmp_syncs_i[i] == 1'b1 ) cmp_acks[i] <= 1'b1;
		   else cmp_acks[i] <= 1'b0;
		end
	   end // always @ (posedge clk, negedge rstb)
      end // block: acks
   endgenerate
   
   
endmodule // cmp_latch


   
   
      
   
