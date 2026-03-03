`timescale 100ps/1ps
`default_nettype none

module clk_cnter #(parameter CLK_NBITS=8) (
				   output wire [CLK_NBITS-1:0] clk_cnt_o,
				   input wire 		       clk,
				   input wire 		       rstb
				   );

   reg [7:0] clock_cnt;
   assign clk_cnt_o = clock_cnt;

   always @(posedge clk, negedge rstb ) begin
      if ( rstb == 1'b0 ) clock_cnt <= {CLK_NBITS{1'b0}};
      else clock_cnt <= clock_cnt + 1'b1;
   end

endmodule // clk_cnter
