module comb_part2 (
    input  wire a,
    input  wire b,
    input  wire c,
    input  wire d,
    output wire q
);
    assign q = b | c;
endmodule
