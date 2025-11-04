module timer_part2 (
    input  wire      clk,
    input  wire      shift_ena,
    input  wire      count_ena,
    input  wire      data,
    output reg [3:0] q
);
    initial q = 4'd0;

    always @(posedge clk) begin
        if (shift_ena) begin
            q <= {q[2:0], data};
        end else if (count_ena) begin
            q <= q - 4'd1;
        end
    end
endmodule
