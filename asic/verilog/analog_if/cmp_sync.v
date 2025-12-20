`timescale 100ps/1ps
`default_nettype none
  
module cmp_sync (
		 input wire cmp_i,            // async !!!
		 input wire [3:0] cmp_acks_up_i,

		 output wire [3:0] ups_o,

		 //input wire clk,
		 input wire rstb
		 );

	
   reg [3:0] ping;
   reg [3:0] ups;

   wire [3:0] rst_ups;
   
   assign ups_o = ups;


   always @(posedge cmp_i, negedge rstb)
     begin
	if ( rstb == 1'b0 )
	  ping <= 4'b0001;
	else
	  ping <= (ping == 4'b1000) ? 4'b0001 : (ping << 1);
     end

/*
   assign rst_ping_up = (rstb == 1'b0) | cmp_ack_ping_up_i;

   always @( posedge cmp_i, posedge rst_ping_up )
     begin
	if ( rst_ping_up == 1'b1) begin
	   if ( rstb == 1'b0 ) begin
	      ping_up <= 1'b0;
	   end
	   else begin
	      if ( cmp_ack_ping_up_i == 1'b1 ) ping_up <= 1'b0;
	   end
	end
	else
	  if ( cmp_i == 1'b1 )
	    if ( ping ) ping_up <= 1'b1;
     end // always @ ( posedge cmp_i, posedge rst_ping_up )
   

*/   

   genvar i;
   generate
      for (i=0; i<4; i=i+1 ) begin : pings
	 assign rst_ups[i] = (rstb == 1'b0) | ((cmp_acks_up_i[i] == 1'b1) && 
					       (ups[i] == 1'b1));

	 always @( posedge cmp_i, posedge rst_ups[i] )
	   begin
	      if ( rst_ups[i] == 1'b1) begin
		 if ( rstb == 1'b0 ) begin
		    ups[i] <= 1'b0;
		 end
		 else begin
		    if ( cmp_acks_up_i[i] == 1'b1 ) ups[i] <= 1'b0;
		 end
	      end
	      else
		if ( cmp_i == 1'b1 )
		  if ( ping[i] ) ups[i] <= 1'b1;
	   end // always @ ( posedge cmp_i, posedge rst_ping_up )
      end
   endgenerate
   

   

endmodule // cmp_sync

   
   
      
   
