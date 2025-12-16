module counter3 (
    input  wire clk,
    input  wire reset,
    input  wire data,
    output reg  start_shifting
);

    localparam S0 = 3'd0;
    localparam S1 = 3'd1;
    localparam S2 = 3'd2;
    localparam S3 = 3'd3;
    localparam S4 = 3'd4;

    reg [2:0] state, next_state;

    always @(posedge clk) begin
        if (reset) begin
            state <= S0;
            start_shifting <= 1'b0;
        end else begin
            state <= next_state;
            if (next_state == S4) begin
                start_shifting <= 1'b1;
                state <= S0;
            end
        end
    end

    always @(*) begin
        case (state)
            S0: begin
                if (data == 1'b1) next_state = S1;
                else              next_state = S0;
            end
            S1: begin
                if (data == 1'b1) next_state = S2;
                else              next_state = S0;
            end
            S2: begin
                if (data == 1'b0) next_state = S3;
                else              next_state = S2;
            end
            S3: begin
                if (data == 1'b1) next_state = S4;
                else              next_state = S0;
            end
            S4: begin
                next_state = S4;
            end
            default: next_state = S0;
        endcase
    end

endmodule