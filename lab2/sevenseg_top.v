// segments order: abc_defg (as per Task.md image reference)
module sevenseg_top(
    input  wire [3:0] data,
    output reg  [6:0] segments
);
    always @* begin
        case (data)
            4'd0: segments = 7'b111_1110; // 0
            4'd1: segments = 7'b011_0000; // 1
            4'd2: segments = 7'b110_1101; // 2
            4'd3: segments = 7'b111_1001; // 3
            4'd4: segments = 7'b011_0011; // 4
            4'd5: segments = 7'b101_1011; // 5
            4'd6: segments = 7'b101_1111; // 6
            4'd7: segments = 7'b111_0000; // 7
            4'd8: segments = 7'b111_1111; // 8
            4'd9: segments = 7'b111_1011; // 9
            default: segments = 7'b000_0000;
        endcase
    end
endmodule
