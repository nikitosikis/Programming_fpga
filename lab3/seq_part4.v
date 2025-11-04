module seq_part4 (
    input  wire clk,
    input  wire a,
    output reg  p,
    output reg  q
);
    initial begin
        p = 1'b0;
        q = 1'b0;
    end

    always @(posedge clk) begin
        p <= a;
        q <= p;
    end
endmodule
