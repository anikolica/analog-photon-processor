`timescale 100ps/1ps
// `default_nettype none

  module tb_analog_if();

   reg cmp;

   wire [3:0] valid_up;
   wire [7:0] cnt8_up_0;
   wire [7:0] cnt8_up_1;
   wire [7:0] cnt8_up_2;
   wire [7:0] cnt8_up_3;
   
   wire [3:0] valid_down;
   wire [7:0] cnt8_down_0;
   wire [7:0] cnt8_down_1;
   wire [7:0] cnt8_down_2;
   wire [7:0] cnt8_down_3;
   
   
   reg clk;
   reg rstb;

   initial
     begin
	clk = 1'b0;
	
	forever
	  #100 clk = ~clk;
     end

   initial
     begin
	cmp = 1'b0;
	rstb = 1'b0;

	//cmp_ack_ping = 1'b0;
	//cmp_ack_pong = 1'b0;

	#10 rstb = 1'b1;

	#10 cmp = 1'b1;
	#205 cmp = 1'b0;

	#500 //cmp_ack_ping = 1'b1;
	#500 //cmp_ack_ping = 1'b0;

	#1000 cmp = 1'b1;
	#5 cmp = 1'b0;

	#500 //cmp_ack_pong = 1'b1;

	#500 cmp = 1'b1;
	//cmp_ack_pong = 1'b0;
	#5 cmp = 1'b0;
	#5 cmp = 1'b1;
	#5 cmp = 1'b0;
	#5 cmp = 1'b1;
	#5 cmp = 1'b0;
	#5 cmp = 1'b1;
	#5 cmp = 1'b0;

	#25000 cmp = 1'b1;
	#5 cmp = 1'b0;
	
	
	#50000 $finish;
	
     end

   analog_if ai ( .cmp_i( cmp ), .valid_up_o( valid_up ),
		  .cnt8_up_0_o( cnt8_up_0 ), .cnt8_up_1_o( cnt8_up_1 ),
		  .cnt8_up_2_o( cnt8_up_2 ), .cnt8_up_3_o( cnt8_up_3 ),
		  .valid_down_o( valid_down ),
		  .cnt8_down_0_o( cnt8_down_0 ), .cnt8_down_1_o( cnt8_down_1 ),
		  .cnt8_down_2_o( cnt8_down_2 ), .cnt8_down_3_o( cnt8_down_3 ),
		  .clk( clk ), .rstb( rstb )
		  );
   
   
endmodule // tb_cmp_sync

	
