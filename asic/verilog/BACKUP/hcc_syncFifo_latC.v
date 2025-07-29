`timescale 1ns/1ps
`default_nettype none

module hcc_syncFifo_latC #(
		      parameter WORDWIDTH=8,
		      parameter logDEPTH=3,
		      parameter almostFULL=1
		      )
   (
    input wire [WORDWIDTH - 1:0] data_i,  // dIn,
    output wire [WORDWIDTH - 1:0] data_o, // dOut,
    input wire we_i,
    input wire re_i,
    output wire full_o,
//    output wire overflow,
    output wire almostFull_o,
//    output wire almostAlmostFull,
    output wire empty_o,
    output wire [logDEPTH:0] occupancy_o,
    input wire clk,
    input wire rstb
//    output wire detErr
    );

   

   wire [ logDEPTH : 0] ptrDelta;  // DOOM

   parameter MAX = 2 ** logDEPTH;


   wire [WORDWIDTH - 1:0] dataOut;
   assign data_o = dataOut;
   
   
   reg  [logDEPTH-1 : 0] rPtr, nextrPtr; 
   wire [logDEPTH-1 : 0] nextrPtrVoted = nextrPtr;
//   wire [logDEPTH-1 : 0] rPtrVoted = rPtr;
   reg  [logDEPTH-1 : 0] wPtr, nextwPtr; 
   wire [logDEPTH-1 : 0] nextwPtrVoted = nextwPtr;


   reg  [logDEPTH : 0]   occupancy, nextoccupancy;  //room to detect overflow
   wire [logDEPTH : 0]   nextoccupancyVoted = nextoccupancy;

   assign occupancy_o = occupancy;
   
   wire 		 we_iVoted = we_i;

   assign empty_o = ( occupancy == {(logDEPTH+1){1'b0}});
   assign full_o = ( occupancy == MAX );
   assign almostFull_o = ( occupancy >= (MAX - almostFULL) );

   reg UpdateWptr, nextUpdateWptr;
   wire nextUpdateWptrVoted = nextUpdateWptr;
   reg UpdateRptr, nextUpdateRptr;
   wire nextUpdateRptrVoted = nextUpdateRptr;
   
   
   
   always @* begin
      if(rstb==0) begin
	 nextUpdateWptr  = 1'b0;
	 nextUpdateRptr  = 1'b0;
	 nextoccupancy   = {(logDEPTH+1){1'b0}};
      end else begin
	 nextUpdateWptr  = 1'b0;
	 nextUpdateRptr  = 1'b0;
	 nextoccupancy = occupancy;

	 case({we_i, re_i})
           2'b00: begin   // do nothing
	      nextUpdateWptr  = 1'b0;
	      nextUpdateRptr  = 1'b0;
	      nextoccupancy = occupancy;
            end
           2'b01: begin  // read
              if(~empty_o) begin
		 nextUpdateRptr = 1'b1;
		 nextoccupancy = occupancy - 1'b1;
              end
           end
           2'b10: begin  // write
	      nextUpdateWptr = 1'b1;
              if ( full_o == 1'b1 ) begin //Increment read as well if full: loose oldest data
		 nextUpdateRptr = 1'b1;
              end else begin
		 nextoccupancy = occupancy + 1'b1;
	      end
           end
           2'b11: begin
	      nextUpdateWptr = 1'b1;
	      nextUpdateRptr = 1'b1;
           end
           default: begin
	      nextUpdateWptr  = 1'b0;
	      nextUpdateRptr  = 1'b0;
	      nextoccupancy = occupancy;
           end
	 endcase
      end // else: !if(rstb==0)
   end // always @ *
   
   always @(posedge clk ) begin
      if(rstb==0) begin
	 UpdateWptr  <= 1'b0;
	 UpdateRptr  <= 1'b0;
	 occupancy   <= {(logDEPTH+1){1'b0}};
      end else begin
	 UpdateWptr <= nextUpdateWptrVoted;
	 UpdateRptr <= nextUpdateRptrVoted;
	 occupancy <= nextoccupancyVoted;
      end
   end

   always @* begin
      if(rstb==0) begin
	 nextwPtr        = {logDEPTH{1'b0}};
	 nextrPtr        = {logDEPTH{1'b0}};
      end else begin
	 if ( UpdateWptr )
              nextwPtr = wPtr + 1'b1;
	 else
	   nextwPtr = wPtr;
	 
	 if ( UpdateRptr )
              nextrPtr = rPtr + 1'b1;
	 else
	   nextrPtr = rPtr;
      end // else: !if(rstb==0)
   end // always @ *
   
   
   always @(posedge clk ) begin
      wPtr <= nextwPtrVoted;
      rPtr <= nextrPtrVoted;
   end

   // tmrg do_not_triplicate we_mono rPtr_mono wPtr_mono data_in data_out
   wire we_mono = we_iVoted;
   wire [logDEPTH-1 : 0] rPtr_mono = rPtr;
   wire [logDEPTH-1 : 0] wPtr_mono = wPtr;

    CW_ram_2r_w_a_lat #( .data_width(WORDWIDTH),
			.depth( 2**logDEPTH ),
			.rst_mode( 1 ) ) fifo_mem (
						   .rst_n( 1'b1 ),
						   .cs_n( 1'b0 ),
						   .wr_n( !we_mono ),
						   .rd1_addr( rPtr_mono ),
						   .rd2_addr( {logDEPTH{1'b0}} ),
						   .wr_addr( wPtr_mono ),
						   .data_in( data_i ),
						   .data_rd1_out( dataOut )
						   );
  
endmodule // hcc_syncFifo_latC


