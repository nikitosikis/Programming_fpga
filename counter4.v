module top_fsm (
    input  wire clk,
    input  wire reset,        
    input  wire data,
    input  wire ack,          

    output wire counting,
    output wire done
);

    localparam S_IDLE  = 2'd0;
    localparam S_SHIFT = 2'd1;
    localparam S_COUNT = 2'd2;
    localparam S_DONE  = 2'd3;

    wire start_shifting;
    wire [3:0] delay;
    reg shift_ena;
    reg count_ena;
    reg counter_done = 0;
    wire [9:0] counter999;


    reg [1:0] state, next_state;
    reg [3:0] repeat_cnt;       
    reg [3:0] delay_reg;        
    reg [1:0] shift_counter;    

    counter3 seq_det (
        .clk(clk),
        .reset(reset),
        .data(data),
        .start_shifting(start_shifting)
    );

    counter2 shift_reg (
        .clk(clk),
        .shift_ena(shift_ena),
        .count_ena(count_ena),
        .data(data),
        .q(delay),
        .reset(reset)
    );

    counter1 cnt_1k (
        .clk(clk),
        .reset(~count_ena),     
        .count(counter999)                
    );
    
    always @(posedge clk) begin
        if (reset) begin
            state        <= S_IDLE;
            repeat_cnt   <= 4'd0;
            delay_reg    <= 4'd0;
            shift_counter <= 2'd0;
        end else begin
            state <= next_state;

            case (state)
                S_SHIFT: begin
                    if (shift_counter == 2'd3) begin
                        delay_reg <= delay;
                    end else if (shift_counter < 2'd3) begin
                        shift_counter <= shift_counter + 1;
                    end else shift_counter <= 0;
                end
                S_COUNT: begin
                    if (counter999 == 10'd999) begin
                        repeat_cnt <= repeat_cnt + 1;
                    end
                end
                default: ;
            endcase
        end
    end

    always @(*) begin
        next_state = state;
        shift_ena  = 1'b0;
        count_ena  = 1'b0;

        case (state)
            S_IDLE: begin
                if (start_shifting) begin
                    next_state = S_SHIFT;
                end
            end

            S_SHIFT: begin
                shift_ena = 1'b1;
                if (shift_counter == 2'd3) begin
                    next_state = S_COUNT;
                end
            end

            S_COUNT: begin
                count_ena = 1'b1;
                if (repeat_cnt == delay_reg) begin
                    next_state = S_DONE;
                end
            end

            S_DONE: begin
                if (ack) begin
                    next_state = S_IDLE;
                end
            end

            default: next_state = S_IDLE;
        endcase
    end

    assign counting = (state == S_COUNT);
    assign done = (state == S_DONE);
endmodule