/******************************************************************************
 * Digital interface to analog memory cells, APP core logic, and outside
 * world.
 *
 * 1. APP updates amem_empty/full after TOT events
 * 2. FPGA asserts read_next_i when external ADCs are ready
 * 3. APP switches event_mux_o and asserts sample_ready_o when settled  
 * 4. FPGA tells ADCs to sample, and asserts adc_done_i when conversion done  
 * 5. Cycle repeats until amem_empty=1 and event_mux_o agrees with last read
 * NOTE: the metadata need not be read syncronously with this interface
 * NOTE: triggered mode can increment/decrement read pointer depending on 
 *       which analog memory locations need to be read out. If amem_full_o 
 *       is asserted, analog storage should be paused with stopB
 *
 ******************************************************************************
*/

`timescale 100ps/1ps
`default_nettype none

module amem_core(
    // Intra-chip signals (controller, register map)
    input wire [2:0] wr_ptr_i, // from controller.sv
    input wire incr_rd_ptr_i, // trigger increment read pointer
    input wire decr_rd_ptr_i, // trigger decrement read pointer
	input wire circular_en_i, // chip reg setting to "cycle", 1 -> continuous

	// Signals to/from APP analog measurement circuitry
	input wire [7:0] WE_time_i, // TACs done on falling edge
	output wire read_en_o, // goes to RE
	output wire [2:0] event_mux_o, // goes to sel_TOT_event[3:1], outside world
	
	// Signals to/from outside world
	input wire clk,
	input wire rstb,
	input wire adc_done_i, // FPGA done taking a sample
	input wire read_next_i, // FPGA asking to advance to next location
	output wire sample_ready_o, // APP indicating MUX is set
	output wire amem_empty_o, // no new data
	output wire amem_full_o // asserted if circular_en = 0 and 8 locations full
                            // also wired to stopB internally to pause storage
);

    // Registers
    reg [2:0] read_pointer_reg = 3'b000;
    reg [2:0] read_pointer_next_reg = 3'b000;
    reg [2:0] event_mux_reg = 3'b000;
	assign event_mux_o = event_mux_reg;

    reg empty_reg = 1'b1;
	reg full_reg = 1'b0;
	assign amem_empty_o = empty_reg;
	assign amem_full_o = full_reg;

	reg read_en_reg = 1'b0;
    reg sample_ready_reg = 1'b0;
	assign read_en_o = read_en_reg;
    assign sample_ready_o = sample_ready_reg;

    wire [2:0] WE_last;
    wire WE_valid;
    
    // States
    reg [4:0] curr_state = 5'b00000;
    reg [4:0] next_state = 5'b00000;
    localparam [4:0]
                INIT  = 0,
                WAIT0 = 1,
                READ0 = 2,
                DONE0 = 3,
                WAIT1 = 4,
                READ1 = 5,
                DONE1 = 6,
                WAIT2 = 7,
                READ2 = 8,
                DONE2 = 9,
                WAIT3 = 10,
                READ3 = 11,
                DONE3 = 12,
                WAIT4 = 13,
                READ4 = 14,
                DONE4 = 15,
                WAIT5 = 16,
                READ5 = 17,
                DONE5 = 18,
                WAIT6 = 19,
                READ6 = 20,
                DONE6 = 21,
                WAIT7 = 22,
                READ7 = 23,
                DONE7 = 24,
                // unused: 25--30
                ERROR = 31;

    // Keep track of how many analog memories have been written to.
    // WE_time_i[7:0] can have adjacent bits asserted, i.e. 
    // TACs for [0] and [1] can trigger at same time for different ToT.
    // XXX -- assumption is that these always change monotonically, modulo 8 
    prio_enc_mod8 WE_decode(
        .clk(clk),
        .rstb(rstb),
        .signals(WE_time_i),
        .index(WE_last),
        .valid(WE_valid)
    );

    // State update
    always @ (posedge clk or negedge rstb)
    begin
        if (!rstb)
            curr_state <= INIT;
        else
            curr_state <= next_state;
    end

    // Read pointer update
    always @ (posedge clk or negedge rstb)
    begin
        if (!rstb)
        begin
            read_pointer_reg <= 3'b000;
            read_pointer_next_reg <= 3'b000;
        end
        else
        begin
            // triggered mode allowed to change read pointer
            if (incr_rd_ptr_i)
                read_pointer_reg <= read_pointer_next_reg + 1;
            else if (decr_rd_ptr_i)
                read_pointer_reg <= read_pointer_next_reg - 1;
            else
                read_pointer_reg <= read_pointer_next_reg;
        end
    end

    // State machine for main read loop
    // Go through WAITx, READx, DONEx for each state
    // If we got to WAITx and READx, FPGA should finish sampling
    // If we get to DONEx and triggers have happened, then
    // jump to corrent new x+n state
    always @ (*)
	begin
        case (curr_state)
            INIT: 
            begin
                // Wait for first write after rstb.
                // write_pointer from analog_if points to NEXT location.
                if (WE_valid && WE_last == 3'b000 && wr_ptr_i == 4'b0001) 
                    next_state = WAIT0; // XXX -- what happens if read
                                         // pointer updates from trigger?
            end
            WAIT0:
            begin
                // signal outside world that there is data
                // set read pointer and internal MUX
                // wait for FPGA to signal it's ready to sample
                empty_reg = 1'b0; // not empty
                read_pointer_next_reg = 3'b000;
                event_mux_reg = 3'b000; // XXX -- need explicit settling time?
                if (read_next_i)
                    next_state = READ0;
            end
            READ0:
            begin
                sample_ready_reg = 1'b1; // ready to FPGA
                read_en_reg = 1'b1;      // RE to APP
                if (adc_done_i)
                    next_state = DONE0;
            end
            DONE0:
            begin
                sample_ready_reg = 1'b0;
                read_en_reg = 1'b0;
                // if trigger overrides read pointer, branch
                if (read_pointer_reg != read_pointer_next_reg)
                begin
                    case (read_pointer_reg)
                        3'b000: next_state = WAIT1;
                        3'b001: next_state = WAIT2;
                        3'b010: next_state = WAIT3;
                        3'b011: next_state = WAIT4;
                        3'b100: next_state = WAIT5;
                        3'b101: next_state = WAIT6;
                        3'b110: next_state = WAIT7;
                        3'b111: next_state = WAIT0;
                    endcase
                end
                else if (WE_valid && WE_last == 3'b001 && wr_ptr_i == 4'b0010) 
                    next_state = WAIT1;
            end                
            // XXX -- repeat WAIT/READ/DONE 1 ... 7
            // XXX -- account for circular_en = 0 with full_reg = 1
            default: 
            begin
                empty_reg = 1'b1; // empty
                full_reg = 1'b0;  // not full
                read_en_reg = 1'b0;
                sample_ready_reg = 1'b0;
                read_pointer_next_reg = 3'b111;
                next_state = INIT;
            end
            // XXX -- if back edge TAC and mem/mempong setting do not agree,
            // do nothing or ERROR ?
        endcase
    end

endmodule // amem_core

