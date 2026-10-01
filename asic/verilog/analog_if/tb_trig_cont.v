`timescale 10ps/1ps
// `default_nettype none


  module tb_trig_cont();


   reg [2:0] w_ptr;
   reg LI_start;
   reg LI_end;
   reg trigger;
   reg read_en;
   reg [3:0] event_mux;
      
   reg clk;
   reg rstb;

   wire [7:0] trigd;
   

   initial
     begin
	clk = 1'b0;
	
	forever
	  #1000 clk = ~clk;
     end

   initial
     begin
	//$sdf_annotate( "../../syn/output/r2g.sdf", tb_analog_if, "", "sdf_annotate.log", "MAXIMUM" );

	$monitor( "Time = %0t w_ptr = 0x%0h trigd = 0x%0h", $time, w_ptr, trigd );
	
	w_ptr = 3'h0;
	LI_start = 1'b0;
	LI_end = 1'b0;
	trigger = 1'b0;
	read_en = 1'b0;
	event_mux = 4'h0;

	rstb = 1'b0;
	#11000
	rstb = 1'b1;

	/*
	 * First LI window -- one ToT, trigger
	 */
	#10000
	  // ToT
	  w_ptr = w_ptr + 1'b1;
	  LI_start = 1'b1;      // LI_end @ +20000 (10 clks)
	#2000                   //        @ +18000
	  LI_start = 1'b0;

	#6000                   //        @ +12000
	  trigger = 1'b1;
	#2000                   //        @ +10000
	  trigger = 1'b0;

	#10000
	  LI_end = 1'b1;
	#2000
	  LI_end = 1'b0;
	
	#4000
	  event_mux = 4'b0000;
	#2000
	  event_mux = 4'b1000;

	#4000
	  read_en = 1'b1;

	#4000
	  read_en = 1'b0;
	  event_mux = 4'b0000;
	
	/*
	 * Second LI window -- one ToT, no trigger
	 */
	#10000
	  // ToT
	  w_ptr = w_ptr + 1'b1;
	  LI_start = 1'b1;      // LI_end @ +20000 (10 clks)
	#2000                   //        @ +18000
	  LI_start = 1'b0;

	#6000                   //        @ +12000
	  //trigger = 1'b1;
	#2000                   //        @ +10000
	  trigger = 1'b0;

	#10000
	  LI_end = 1'b1;
	#2000
	  LI_end = 1'b0;
	
	#4000
	  //event_mux = 4'b0000;
	#2000
	  //event_mux = 4'b1000;

	#4000
	  //read_en = 1'b1;

	#4000
	  read_en = 1'b0;
	  event_mux = 4'b0000;
	
	/*
	 * Third LI window -- two ToTs, trigger
	 */
	#10000
	  // ToT
	  w_ptr = w_ptr + 1'b1;
	  LI_start = 1'b1;      // LI_end @ +20000 (10 clks)
	#2000                   //        @ +18000
	  LI_start = 1'b0;

	#2000
	  // ToT
	  w_ptr = w_ptr + 1'b1;
	  
	#4000                   //        @ +12000
	  trigger = 1'b1;
	#2000                   //        @ +10000
	  trigger = 1'b0;

	#10000
	  LI_end = 1'b1;
	#2000
	  LI_end = 1'b0;
	
	#4000
	  event_mux = 4'b0010;
	#2000
	  event_mux = 4'b1010;

	#4000
	  read_en = 1'b1;

	#2000
	  // ToT
	  w_ptr = w_ptr + 1'b1;
	  LI_start = 1'b1;      // LI_end @ +20000 (10 clks)
	#2000                   //        @ +18000
	  LI_start = 1'b0;


	// #4000
	  read_en = 1'b0;
	  event_mux = 4'b0011;

	#2000
	  event_mux = 4'b1011;

	  trigger = 1'b1;
	#2000                   //        @ +10000
	  trigger = 1'b0;
	
	#2000
	  read_en = 1'b1;

	#4000
	  read_en = 1'b0;
	  event_mux = 4'b0011;

	#8000
	  LI_end = 1'b1;
	#2000
	  LI_end = 1'b0;
	  
	  
	
	#10000 $finish;
	
     end


   trig_cont tc (
		 .w_ptr_i( w_ptr ),
		 .LI_start_i( LI_start ),
		 .LI_end_i( LI_end ),
		 .trigger_i( trigger ),
		 .read_en_i( read_en ),
		 .event_mux_i( event_mux ),
		 .trigd_o( trigd ),
		 .clk( clk ),
		 .rstb( rstb )
		 );
   
      
endmodule // tb_cmp_sync

	
