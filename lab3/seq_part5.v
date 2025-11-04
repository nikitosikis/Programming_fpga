module seq_part5 (
    input  wire       clk,
    input  wire       a,
    output reg [3:0]  q
);
    initial q = 4'd4;

    always @(posedge clk) begin
        if (a) begin
            q <= 4'd4;
        end else begin
            if (q == 4'd6) begin
                q <= 4'd0;
            end else begin
                q <= q + 4'd1;
            end
        end
    end
endmodule
