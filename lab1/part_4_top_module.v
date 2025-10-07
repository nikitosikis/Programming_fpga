module part_4_top_module (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] sum
);

    wire cout_lower;
    wire [15:0] sum_lower;
    wire [15:0] sum_upper_0, sum_upper_1;
    wire cout_upper_0, cout_upper_1;

    add16 lower16 (
        .a(a[15:0]),
        .b(b[15:0]),
        .cin(1'b0),
        .sum(sum_lower),
        .cout(cout_lower)
    );

    add16 upper16_0 (
        .a(a[31:16]),
        .b(b[31:16]),
        .cin(1'b0),
        .sum(sum_upper_0),
        .cout(cout_upper_0)
    );

    add16 upper16_1 (
        .a(a[31:16]),
        .b(b[31:16]),
        .cin(1'b1),
        .sum(sum_upper_1),
        .cout(cout_upper_1)
    );

    assign sum[15:0]  = sum_lower;
    assign sum[31:16] = cout_lower ? sum_upper_1 : sum_upper_0;

endmodule


module add16 (
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);
    assign {cout, sum} = a + b + cin;
endmodule
