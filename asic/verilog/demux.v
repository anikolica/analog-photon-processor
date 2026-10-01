// Demultiplexer
// Demultiplexes 3-bit value into 8-bit vector with an enable

module demux(
        input wire enable_i,
        input wire [2:0] val_i,
        output wire [7:0] demux_o
    );

    //reg [7:0] out;   -- out is a keyword
    reg [7:0] d_out;
    always @(*)
    begin
        if (!enable_i) begin
            d_out = 8'h00;
        end else begin
            d_out = 8'h01 << val_i;
        end
    end
    assign demux_o = d_out;
endmodule
