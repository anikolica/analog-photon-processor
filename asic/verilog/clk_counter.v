`timescale 1ns/1ps

module clk_counter #(
		     parameter WIDTH=32
		     )
   (
    output wire [WIDTH:0] count,
		   
    input wire 	       clk,
    input wire 	       rstb
    );
   

   
   reg [31:0] counter;
   assign count = counter;
   
   always @( posedge clk, negedge rstb ) begin
      if ( rstb == 1'b0 )
	counter <= 0;
      else
	counter <= counter + 1'b1;
   end

endmodule // clk_counter


   
