/******************************************************************************
 * Priority encoder for WE_time_i
 * Indicates highest numbered falling edge, modulo 8
 * Example: TACs 3 and 4 finish at same time:
 *          8'b00011000 -> 8'b00000000
 *          Result: [4]
 * Example: TACs 7 and 0 finish at same time, after writes to those locations:
 *          8'b10000001 -> 8'b00000010
 *          Result: [0] is highest, mod 8, since it wrapped around
 *
 ******************************************************************************
*/

`timescale 100ps/1ps
`default_nettype none

module prio_enc_mod8(
    input        clk,
    input        rstb,
    input [7:0]  signals,
    output reg [2:0] index,
    output reg valid
);

    reg [7:0] prev = 8'b00000000;
    reg [2:0] offset = 3'b000;

    wire [7:0] falling_edges;
    wire [7:0] rotated;
    wire [3:0] sum;
    wire [2:0] next_index;

    // priority encoder
    always @(*) begin
        casex (rotated)
            8'b1???????: offset = 3'b111;
            8'b01??????: offset = 3'b110;
            8'b001?????: offset = 3'b101;
            8'b0001????: offset = 3'b100;
            8'b00001???: offset = 3'b011;
            8'b000001??: offset = 3'b010;
            8'b0000001?: offset = 3'b001;
            8'b00000001: offset = 3'b000;
            default:     offset = 3'b000;
        endcase
    end

    always @(posedge clk or negedge rstb) begin
        if (!rstb) 
        begin
            prev  <= 8'b00000000;
            index <= 3'b000;
            valid <= 1'b0;
        end 
        else
        begin
            prev <= signals;
            valid <= |falling_edges; // if any edges fell
            if (|falling_edges) 
                index <= next_index;
        end
    end

    // Falling edge detect
    assign falling_edges = prev & ~signals;

    // Rotate right by (index + 1), then OR with
    // rotate left by (8 - index + 1) to wrap around bits that "fell off"
    assign rotated = (falling_edges >>            (index + 3'b001)) |
                     (falling_edges << (4'b1000 - (index + 3'b001)));
    // Un-rotate
    // Effectively, next index = (offset + index + 1) mod (8)
    assign next_index = (offset + index + 3'b001) & 3'b111;

endmodule // prio_enc_mod8
