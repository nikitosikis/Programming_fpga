module timer_part3 (
    input  wire clk,
    input  wire reset,
    input  wire data,
    output reg  start_shifting
);
    localparam STATE_IDLE    = 2'd0;
    localparam STATE_HAVE_1  = 2'd1;
    localparam STATE_HAVE_11 = 2'd2;
    localparam STATE_HAVE_110 = 2'd3;

    reg [1:0] state;

    initial begin
        state = STATE_IDLE;
        start_shifting = 1'b0;
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= STATE_IDLE;
            start_shifting <= 1'b0;
        end else begin
            start_shifting <= 1'b0;
            case (state)
                STATE_IDLE: begin
                    if (data) begin
                        state <= STATE_HAVE_1;
                    end
                end
                STATE_HAVE_1: begin
                    if (data) begin
                        state <= STATE_HAVE_11;
                    end else begin
                        state <= STATE_IDLE;
                    end
                end
                STATE_HAVE_11: begin
                    if (data) begin
                        state <= STATE_HAVE_11;
                    end else begin
                        state <= STATE_HAVE_110;
                    end
                end
                STATE_HAVE_110: begin
                    if (data) begin
                        start_shifting <= 1'b1;
                        state <= STATE_HAVE_1;
                    end else begin
                        state <= STATE_IDLE;
                    end
                end
                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule
