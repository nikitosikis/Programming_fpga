module counter1 (
    input wire clk,       
    input wire reset,     
    output reg [9:0] count = 10'd0
);

    always @(posedge clk) begin
        if (reset)
            count <= 10'd0;           
        else if (count == 10'd999)
            count <= 10'd0;           
        else
            count <= count + 10'd1;  
    end

endmodule