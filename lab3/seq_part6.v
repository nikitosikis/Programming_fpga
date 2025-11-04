module seq_part6 (
    input  wire clk,
    input  wire a,
    input  wire b,
    output reg  q,
    output reg  state
);
    initial begin
        state = 1'b0;
        q     = 1'b0;
    end

    always @(posedge clk) begin
        q <= state ? b : a;
        state <= (state ? a : b);
    end
endmodule
