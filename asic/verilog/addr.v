`timescale 1ns/1ps

module addr(
		 input wire [3:0] a_i,
		 input wire [3:0] b_i,

		 output wire [4:0] c_o,

		 input clk,
		 input rstb
		 );

   reg [4:0] c;

   assign c_o = c;
   
   always @(posedge clk ) begin
      if ( rstb == 1'b0 )
	c <= 5'b00000;
      else 
	c <= a_i + b_i;
   end

endmodule // dummy_top
