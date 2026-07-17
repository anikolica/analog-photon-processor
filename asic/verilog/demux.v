// Demultiplexer
// Demultiplexes 3-bit value into 8-bit vector with an enable

module demux(
        input wire enable_i,
        input wire [2:0] val_i,
        output wire [7:0] demux_o
    );

    reg [7:0] out;
    always @(*)
    begin
        if (!enable_i) begin
            out = 1'b0;
        end else begin
            out = 8'b1 << val_i;
        end
    end
    assign demux_o = out;
endmodule