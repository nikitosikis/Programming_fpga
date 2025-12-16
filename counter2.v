module counter2 (
    input  wire       clk,        
    input  wire       shift_ena, 
    input  wire       count_ena,  
    input  wire       data,
    input  wire       reset, 
    output reg  [3:0] q          
);
    always @(posedge clk) begin
        if (reset) q <= 4'd0;
        if (shift_ena) begin
            q <= {q[2:0], data};
        end
        if (count_ena) begin
            q <= q - 1;
        end
    end

endmodule