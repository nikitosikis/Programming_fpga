module sevenseg_top(
    input  wire [3:0] data,
    output reg  [6:0] segments
);
    always @* begin
        case (data)
            4'd0: segments = 7'b111_1110; 
            4'd1: segments = 7'b011_0000; 
            4'd2: segments = 7'b110_1101; 
            4'd3: segments = 7'b111_1001; 
            4'd4: segments = 7'b011_0011; 
            4'd5: segments = 7'b101_1011; 
            4'd6: segments = 7'b101_1111; 
            4'd7: segments = 7'b111_0000; 
            4'd8: segments = 7'b111_1111; 
            4'd9: segments = 7'b111_1011; 
            default: segments = 7'b000_0000;
        endcase
    end
endmodule
