module timer_part4 (
    input  wire clk,
    input  wire reset,
    input  wire data,
    input  wire ack,
    output wire [3:0] count,
    output wire counting,
    output wire done
);
    localparam STATE_IDLE     = 4'd0;
    localparam STATE_HAVE_1   = 4'd1;
    localparam STATE_HAVE_11  = 4'd2;
    localparam STATE_HAVE_110 = 4'd3;
    localparam STATE_SHIFT_0  = 4'd4;
    localparam STATE_SHIFT_1  = 4'd5;
    localparam STATE_SHIFT_2  = 4'd6;
    localparam STATE_SHIFT_3  = 4'd7;
    localparam STATE_COUNT    = 4'd8;
    localparam STATE_WAIT     = 4'd9;

    reg [3:0] state;
    reg [3:0] next_state;

    reg first_tick_consumed;
    wire count_ena;

    wire shift_ena = (state == STATE_SHIFT_0) ||
                     (state == STATE_SHIFT_1) ||
                     (state == STATE_SHIFT_2) ||
                     (state == STATE_SHIFT_3);

    wire counter_reset = reset | (state != STATE_COUNT);

    wire [9:0] ms_counter_q;
    wire       ms_tick = (ms_counter_q == 10'd999);
    wire       final_tick = ms_tick &&
                            ((!first_tick_consumed && (count == 4'd0)) ||
                             (first_tick_consumed && (count == 4'd1)));
    assign count_ena = (state == STATE_COUNT) &&
                       first_tick_consumed &&
                       ms_tick &&
                       (count != 4'd0);

    timer_part1 ms_counter (
        .clk(clk),
        .reset(counter_reset),
        .q(ms_counter_q)
    );

    timer_part2 delay_reg (
        .clk(clk),
        .shift_ena(shift_ena),
        .count_ena(count_ena),
        .data(data),
        .q(count)
    );

    assign counting = (state == STATE_COUNT);
    assign done     = (state == STATE_WAIT);

    initial begin
        state = STATE_IDLE;
        first_tick_consumed = 1'b0;
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= STATE_IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @* begin
        next_state = state;
        case (state)
            STATE_IDLE: begin
                if (data) begin
                    next_state = STATE_HAVE_1;
                end
            end
            STATE_HAVE_1: begin
                if (data) begin
                    next_state = STATE_HAVE_11;
                end else begin
                    next_state = STATE_IDLE;
                end
            end
            STATE_HAVE_11: begin
                if (data) begin
                    next_state = STATE_HAVE_11;
                end else begin
                    next_state = STATE_HAVE_110;
                end
            end
            STATE_HAVE_110: begin
                if (data) begin
                    next_state = STATE_SHIFT_0;
                end else begin
                    next_state = STATE_IDLE;
                end
            end
            STATE_SHIFT_0: next_state = STATE_SHIFT_1;
            STATE_SHIFT_1: next_state = STATE_SHIFT_2;
            STATE_SHIFT_2: next_state = STATE_SHIFT_3;
            STATE_SHIFT_3: next_state = STATE_COUNT;
            STATE_COUNT: begin
                if (final_tick) begin
                    next_state = STATE_WAIT;
                end
            end
            STATE_WAIT: begin
                if (ack) begin
                    next_state = STATE_IDLE;
                end
            end
            default: begin
                next_state = STATE_IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            first_tick_consumed <= 1'b0;
        end else if (state != STATE_COUNT && next_state == STATE_COUNT) begin
            first_tick_consumed <= 1'b0;
        end else if (state == STATE_COUNT && ms_tick && !first_tick_consumed) begin
            first_tick_consumed <= 1'b1;
        end else if (state != STATE_COUNT) begin
            first_tick_consumed <= 1'b0;
        end
    end

endmodule
