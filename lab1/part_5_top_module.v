module part_5_top_module (
    input [31:0] a,
    input [31:0] b,
    input sub,
    output [31:0] sum
);
    
    wire cout_lower; 
    wire [15:0] b_lower;
    wire [15:0] b_upper;

    assign b_lower = b[15:0] ^ {16{sub}};
    assign b_upper = b[31:16] ^ {16{sub}};
    
    add16 lower16 (
        .a(a[15:0]),
        .b(b_lower),
        .cin(sub),
        .sum(sum[15:0]),
        .cout(cout_lower)
    );
    
    add16 upper16 (
        .a(a[31:16]),
        .b(b_upper),
        .cin(cout_lower),
        .sum(sum[31:16]),
        .cout() 
    );

endmodule

module add16 (
    input [15:0] a,
    input [15:0] b,
    input cin,
    output [15:0] sum,
    output cout
);
    assign {cout, sum} = a + b + cin;
endmodule

