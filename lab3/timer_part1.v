module timer_part1 (
    input  wire       clk,
    input  wire       reset,
    output reg  [9:0] q
);
    initial q = 10'd0;

    always @(posedge clk) begin
        if (reset) begin
            q <= 10'd0;
        end else if (q == 10'd999) begin
            q <= 10'd0;
        end else begin
            q <= q + 10'd1;
        end
    end
endmodule
