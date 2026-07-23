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

        reg li_start;
        reg li_end;
        reg li_active;

        reg [7:0] cycle_counter;

        wire valid_le;

        always @(posedge clk or negedge rstb) begin
          if (rstb == 1'b0) begin
            cycle_counter <= 8'd0;
            li_start <= 1'b0;
            li_end <= 1'b0;
            li_active <= 1'b0;
          end else begin
            li_start <= 1'b0;
            li_end <= 1'b0;
            if ((valid_le) && (cycle_counter == 8'd0) && (!li_active)) begin
              li_start <= 1'b1;
              li_active <= 1'b1;
              cycle_counter <= 8'd1; 
            end else if (li_active) begin
              //if ( (cycle_counter == LI_length_i) || ( (valid_le) && (cycle_counter + 8'd1 == LI_length_i)) ) begin
              if ( (cycle_counter == LI_length_i) ) begin
                li_end <= 1'b1;
                if ((valid_le)) begin
                  li_active <= 1'b1;
                  li_start <= 1'b1;
                  li_end <= 1'b1;
                  cycle_counter <= 8'd1;
                end else begin
                  li_active <= 1'b0;
                  cycle_counter <= 8'd0;
                end
              end else begin
                cycle_counter <= cycle_counter + 8'd1; 
              end
            end
          end
        end

        assign LI_start_o = li_start;
        assign LI_end_o = li_end;
        assign LI_active_o = li_active;
        assign valid_le = |valid_up_i;

endmodule // LI_control
