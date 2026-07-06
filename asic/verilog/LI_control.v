`timescale 100ps/1ps
`default_nettype none

  /*
   LI_control figures out the beginning and end of Long Integrate (LI) windows, which also
   corresponds to event windows in triggered mode.
   
   Its inputs are the valid_up vector from analog_if indicating a rising edge of a pulse has
   been seen, and the length of the LI window in clock ticks.
   Its outputs are pulses for the start and end of the LI window and signal indicating whether
   and LI window is active.
   
   It is important to note that if an LI window ends and second one immediately starts, the
   LI active signal will stay high, however, the start and end signals will pulse.
   */
module LI_control(
		    input wire [3:0] 	       valid_up_i,
		    
		    input wire [7:0] 	       LI_length_i, // Length of LI in clocks
		    
		    output wire 	       LI_start_o, // pulses at beginning of LI
		    output wire 	       LI_end_o, // pulses at end of LI
		    output wire 	       LI_active_o, // high during an LI
		    
		    input wire 		       clk,
		    input wire 		       rstb
		    );

        reg li_start = 1'd0;
        reg li_end = 1'd0;
        reg li_active = 1'd0;

        reg [7:0] li_length;

        reg [7:0] cycle_counter;

        always @(posedge clk or negedge rstb) begin
          // active low or active high?
          if (rstb == 1'b0) begin
            cycle_counter <= 8'd0;
            li_start <= 1'b0;
            li_end <= 1'b0;
            li_active <= 1'b0;
            li_length <= 8'd0;
          end else begin
            li_start <= 1'b0;
            li_end <= 1'b0;
            // assuming another LI does not start during one
            // does valid_up_i stay for the whole LI or no? I'm assuming not
            // if ((|valid_up_i) && (cycle_counter == 8'd0) && (!li_active)) begin
            if ((|valid_up_i) && (cycle_counter == 8'd0)) begin
              li_start <= 1'b1;
              li_active <= 1'b1;
              li_length <= LI_length_i;
              cycle_counter <= 8'd1; 
            end else if (li_active) begin
              if ( cycle_counter == li_length ) begin
                li_end <= 1'b1;
                if ((|valid_up_i)) begin
                  li_active <= 1'b1;
                  li_start <= 1'b1;
                  li_length <= LI_length_i;
                  cycle_counter <= 8'd1;
                end else begin
                  li_active <= 1'b0;
                  cycle_counter <= 8'd0;
                end
              end else begin
                // set li_end high, li_active low and reset the counter
                cycle_counter <= cycle_counter + 8'd1; 
              end
            end
          end
        end

        assign LI_start_o = li_start;
        assign LI_end_o = li_end;
        assign LI_active_o = li_active;

endmodule // LI_control
