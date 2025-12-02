module task4 (
    input reg clk,
    input reg a,
    output reg q, p
);

    always @(*) begin
        if (clk) begin
            p = a;
        end
    end

    always @(negedge clk) begin
        q = p;
    end
endmodule

