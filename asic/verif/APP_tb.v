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
	    .WE_ampl_i(), 
	    .WE_time_i(WE_time_i)
    );

    // Instantiate app 1ch behavioral model
    // XXX - needs update based on Ravi's simulations,
    // then we can generate WE here, instead of APP_cocotb.py
    app_1ch_behav app_1ch_tb (
        .clk(clk),
        .rst_init(rst_init),
        .vcomp(vcomp)
    );

    always #10 clk = ~clk; // 50MHz clock
    always #20 timestamp = timestamp + 1;

    initial begin
        #0 rstb = 1'b0;
    end

endmodule
