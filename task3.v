module task3 (
    input [3:0] a, b, c, d, e,
    output reg [3:0] q
);

    always @(*) begin
        case(c) 
            0: q <= b;
            1: q <= e;
            2: q <= a;
            3: q <= d;
        default: q <= 4'hf;
        endcase 
    end
    
endmodule