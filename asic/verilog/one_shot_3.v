module one_shot_3 (
    input  wire clk,
    input  wire rstb,
    input  wire trigger,
    output reg  pulse
);

    reg trigger_d;
    reg [1:0] cnt;

    // Rising-edge detector
    wire trigger_rise = trigger & ~trigger_d;

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            trigger_d <= 1'b0;
            pulse     <= 1'b0;
            cnt       <= 2'd0;
        end else begin
            trigger_d <= trigger;

            if (trigger_rise) begin
                // Retrigger: restart the 3-cycle pulse
                pulse <= 1'b1;
                cnt   <= 2'd2;
            end
            else if (pulse) begin
                if (cnt == 0)
                    pulse <= 1'b0;
                else
                    cnt <= cnt - 1'b1;
            end
        end
    end

endmodule
