`timescale 1ns / 1ps

module APP_tb;

    reg clk = 1'b0;
    reg rstb = 1'b0;
    reg [31:0] timestamp = 32'h00000000;

    // Analog memory signals
    wire [3:0] valid_up_o, valid_down_o;
    wire [7:0] cnt8_up_0_o, cnt8_up_1_o, cnt8_up_2_o, cnt8_up_3_o,
               cnt8_down_0_o, cnt8_down_1_o, cnt8_down_2_o, cnt8_down_3_o;
    reg [7:0] WE_time_i = 8'b00000000; // eventually from behavioral model
    reg [2:0] wr_ptr = 3'b000;

    // App 1ch signals
    reg vcomp = 0; // from tb
    wire rst_init;
    assign rst_init = !rstb;
    
    // LI Control signals
    wire [3:0] LI_valid_up_o;
    wire [7:0] LI_length_o;
    wire LI_start_i;
    wire LI_end_i;
    wire LI_active_i;

    // demux signals
    wire demux_enable_o;
    wire [2:0] demux_val_o;
    wire [7:0] demux_i;

    //oneshot signals
    wire pulse_in;
    wire trigger_out;

    // clock_div signals for DIVISOR=2 and DIVISOR=4
    wire clock_out_2;
    wire clock_out_4;

    // clock_cnter signals
    wire [7:0] clk_cnt_i;

    // addr signals
    wire [3:0] addr_a_i;
    wire [3:0] addr_b_i;
    wire [4:0] addr_c_o;

    // prio_enc_mod8 signals
    // p_signals_out is driven from APP_cocotb.py
    wire [7:0] p_signals_out = 8'b0;
    wire [2:0] p_index_in;
    wire p_valid_in;

    // Behavioral test signals for LI_control (separate from existing manual test)
    reg [7:0] LI_length_behav = 8'hA;
    wire LI_start_behav, LI_end_behav, LI_active_behav;

    // analog interface to amem_core
    analog_if analog_if_tb (
        .clk(clk),
        .rstb(rstb),
        .cmp_i(vcomp),
        .clk_cnt_i(timestamp[7:0]),
	    .cnt8_up_0_o(cnt8_up_0_o),
	    .cnt8_up_1_o(cnt8_up_1_o),
	    .cnt8_up_2_o(cnt8_up_2_o),
	    .cnt8_up_3_o(cnt8_up_3_o),
	    .cnt8_down_0_o(cnt8_down_0_o),
	    .cnt8_down_1_o(cnt8_down_1_o),
	    .cnt8_down_2_o(cnt8_down_2_o),
	    .cnt8_down_3_o(cnt8_down_3_o),
        .valid_up_o(valid_up_o),
        .valid_down_o(valid_down_o)
    );

    // amem_core lives inside controller
    controller controller_tb (
        .clk(clk),
        .rstb(rstb),
        .clk_cnt_i(timestamp[7:0]),
	    .valid_up_i(valid_up_o),
	    .cnt8_up_0_i(cnt8_up_0_o),
	    .cnt8_up_1_i(cnt8_up_1_o),
	    .cnt8_up_2_i(cnt8_up_2_o),
	    .cnt8_up_3_i(cnt8_up_3_o),
	    .valid_down_i(valid_down_o),
	    .cnt8_down_0_i(cnt8_down_0_o),
	    .cnt8_down_1_i(cnt8_down_1_o),
	    .cnt8_down_2_i(cnt8_down_2_o),
	    .cnt8_down_3_i(cnt8_down_3_o),
        // WE_ampl_i is not defined
	    //.WE_ampl_i(), 
	    .WE_time_i(WE_time_i)
    );

    // Instantiate app 1ch behavioral model
    // XXX - needs update based on Ravi's simulations,
    // then we can generate WE here, instead of APP_cocotb.py
    app_1ch_behav app_1ch_tb (
        .clk(clk),
        .rst_init(rst_init),
        .vcomp(vcomp),
        .sample(),
        .sampleP(),
        .VP_front(),
        .VP_back(),
        .count(),
        .read_en(),
        .timeout()
    );

    prio_enc_mod8 prio_enc_mod8_tb (
        .clk(clk),
        .rstb(rstb),
        .signals(p_signals_out),
        .index(p_index_in),
        .valid(p_valid_in)
    );

    LI_control li_control_behav (
        .valid_up_i(valid_up_o),
        .LI_length_i(LI_length_behav),
        .LI_start_o(LI_start_behav),
        .LI_end_o(LI_end_behav),
        .LI_active_o(LI_active_behav),
        .clk(clk),
        .rstb(rstb)
    );

    LI_control li_control_tb (
        .valid_up_i(LI_valid_up_o),
        .LI_length_i(LI_length_o),
        .LI_start_o(LI_start_i),
        .LI_end_o(LI_end_i),
        .LI_active_o(LI_active_i),
        .clk(clk),
        .rstb(rstb)
    );

    demux demux_tb (
        .enable_i(demux_enable_o),
        .val_i(demux_val_o),
        .demux_o(demux_i)
    );

    oneshot oneshot_tb (
        .clk(clk),
        .trigger_in(trigger_out),
        .pulse_out(pulse_in)
    );

    clock_div clock_div_2_tb (
        .clock_in(clk),
        .clock_out(clock_out_2)
    );

    clock_div #(.DIVISOR(28'd4)) clock_div_4_tb (
        .clock_in(clk),
        .clock_out(clock_out_4)
    );
    
    // TODO do I need to change nbits ever? Should I test that?
    clk_cnter clk_cnter_tb (
        .clk(clk),
        .rstb(rstb),
        .clk_cnt_o(clk_cnt_i)
    );

    addr addr_tb (
        .clk(clk),
        .rstb(rstb),
        .a_i(addr_a_i),
        .b_i(addr_b_i),
        .c_o(addr_c_o)
    );

    always #10 clk = ~clk; // 50MHz clock
    always #20 timestamp = timestamp + 1;

    initial begin
        #0 rstb = 1'b0;
        $shm_open("waves.shm");
        $shm_probe(APP_tb, "AS");
    end

endmodule
