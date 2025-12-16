module task5 (
    input wire clk, a,
    output reg [2:0] q = 3'b100
);
    always @(posedge clk) begin
        if (!a) begin
            q <= q+1;
            if (q == 3'b110) q <= 0; 
        end
        else q <= 3'b100;
    end
    
endmodule
