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

module amem_core #(parameter DEPTH=8)(
    // Intra-chip signals (controller, register map, trigger)
    input wire [2:0] wr_ptr_i, // from controller.sv
    input wire [(DEPTH-1):0] valid_cells_i, // analog mem locations to read, 
                                           // from trigger
	input wire circular_en_i, // chip reg setting to "cycle", 1 -> continuous
    input wire LI_valid_i, // asserted at start of LI and deasserted at end
    input wire triggered_mode_i, // 1 -> triggered, 0 -> untriggered
	input wire [(DEPTH-1):0] WE_time_i, // TACs done on falling edge
	output wire read_en_o, // goes to RE in analog memory
	output wire [3:0] event_mux_o, // to sel_TOT_event[3:1], and outside world
                                   // XXX - sel_TOT_event needs a "Z" state !!
	
	// Signals to/from outside world
	input wire clk,
	input wire rstb,
    input wire trigger_i, // Valid trigger signal from outside world
	input wire adc_done_i, // FPGA done taking a sample
	input wire read_next_i, // FPGA asking to advance to next location
	output wire sample_ready_o, // APP indicating MUX is set
	output wire amem_empty_o, // wr_ptr = rd_ptr + 1
	output wire amem_full_o // asserted if circular_en = 0 and 8 locations full,
                            // or if rd_ptr = wr_ptr. 
                            // Also wired to stopB internally to pause storage
);

    // Registers
    reg [2:0] read_pointer_reg = 3'b000;
    reg [2:0] read_pointer_next_reg = 3'b000;
    reg [3:0] event_mux_reg = 4'b0000;
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

    reg trigger_one_shot = 1'b0;
    wire mux_done;
    
    // States
    reg [4:0] curr_state = 5'b00000;
    reg [4:0] next_state = 5'b00000;
    localparam [4:0]
                INIT  = 0,
                UPDATE_PTR = 1,
                EMPTY_FULL = 2,
                WAIT_READ = 3,
                SWITCH_MUX = 4,
                WAIT_STABLE = 5,
                READY_TO_READ = 6,
                MUX_OFF = 7,
                // unused: 8--30
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

    one_shot_3 mux_timeout(
        .clk(clk),
        .rstb(rstb),
        .trigger(trigger_one_shot),
        .pulse(mux_done)
    );

    // State update
    always @ (posedge clk or negedge rstb)
    begin
        if (!rstb)
            curr_state <= INIT;
        else
            curr_state <= next_state;
    end

    // State machine for main read loop
    always @ (*)
	begin
        case (curr_state)
            INIT: 
            begin
                // Wait for first write after rstb.
                // write pointer from analog_if points to NEXT location to write.
                // read pointer points to location currently reading. 
                empty_reg = 1'b1; // empty because wr_ptr = rd_ptr + 1 (mod 8)
                full_reg = 1'b0; // not full   
                read_en_reg = 1'b0; // do not read     
                event_mux_reg = 4'b1000; // hi-Z state    
                sample_ready_reg = 1'b0; // sample not ready
                read_pointer_reg = 3'b111; // INIT starts at last location
                read_pointer_next_reg = 3'b000; 
                if ((wr_ptr_i != 4'b0000) && WE_valid) // if wr_ptr ++ AND WE_valid (TACs done)
                    next_state = UPDATE_PTR; 
            end
            UPDATE_PTR:
            begin
                if (!triggered_mode_i)
                begin
                    if (read_pointer_reg != WE_last)
                    begin
                        read_pointer_reg = read_pointer_reg + 1;
                        next_state = EMPTY_FULL;
                    end
                    else
                        next_state = EMPTY_FULL;
                end
                else if (triggered_mode_i)
                begin
                    // XXX - in triggered mode, update read_pointer_reg w/ valid_cells_i
                end
            end
            EMPTY_FULL:
            begin // update empty/full based on wr_ptr, WE_valid (TACs), valid_cells_i (trigger)
                if (wr_ptr_i == read_pointer_reg) // full condition
                begin
                    full_reg = 1'b1;
                    empty_reg = 1'b0;   
                    next_state = WAIT_READ; 
                end
                else if (wr_ptr_i == read_pointer_reg + 1) // empty condition
                begin
                    full_reg = 1'b0;
                    empty_reg = 1'b1;
                end
                else // else not empty and not full
                begin
                    full_reg = 1'b0;
                    empty_reg = 1'b0;
                    next_state = WAIT_READ;
                end
            end
            WAIT_READ:
            begin // wait for FPGA to request a read
                if (read_next_i)
                begin
                    next_state = SWITCH_MUX;
                end
            end
            SWITCH_MUX:
            begin
                event_mux_reg = read_pointer_reg;
                trigger_one_shot = 1'b1; // XXX -- programmable wait, or memory_ready_i
                next_state = WAIT_STABLE;
            end
            WAIT_STABLE:
            begin
                trigger_one_shot = 1'b0;
                if (!mux_done)
                    next_state = READY_TO_READ;
            end
            READY_TO_READ:
            begin            
                sample_ready_reg = 1'b1;
                if (adc_done_i)
                begin
                    next_state = MUX_OFF;
                end
            end
            MUX_OFF:
            begin
                event_mux_reg = 4'b1000; // hi-Z
                sample_ready_reg = 1'b0;
                next_state = UPDATE_PTR; // repeat until empty/full
            end
            default: 
            begin
                empty_reg = 1'b1; // empty
                full_reg = 1'b0; // not full   
                read_en_reg = 1'b0; // do not read     
                event_mux_reg = 4'b1000; // hi-Z state    
                sample_ready_reg = 1'b0; // sample not ready
                read_pointer_reg = 3'b111; // INIT starts at last location
                read_pointer_next_reg = 3'b000;
                next_state = INIT;
            end
            // XXX -- if back edge TAC and mem/mempong setting do not agree,
            // do nothing or ERROR ?
            // XXX -- account for circular_en = 0 with full_reg = 1
        endcase
    end

endmodule // amem_core

