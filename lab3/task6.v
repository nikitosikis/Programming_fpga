module task6(
    input  wire clk,
    input  wire a,
    input  wire b,
    output q,
    output reg state
);
    

assign q = a ^ b ^ state;

always @(posedge clk) begin
    if (b == a)
        state <= a;
end
endmodule