module rom_top(
    input  wire [1:0] adr,
    output reg  [3:0] dout
);
    always @* begin
        case (adr)
            2'd0: dout = 4'd0;
            2'd1: dout = 4'd1;
            2'd2: dout = 4'd2;
            2'd3: dout = 4'd3;
            default: dout = 4'd0;
        endcase
    end
endmodule
