module full_add_3b( 
    input [2:0] a, b,
    input cin,
    output [2:0] cout,
    output [2:0] sum
);

    // Разряд 0
    full_adder fa0 (
        .A(a[0]),
        .B(b[0]),
        .C_in(cin),
        .S(sum[0]),
        .C_out(cout[0])
    );

    // Разряд 1
    full_adder fa1 (
        .A(a[1]),
        .B(b[1]),
        .C_in(cout[0]),
        .S(sum[1]),
        .C_out(cout[1])
    );

    // Разряд 2
    full_adder fa2 (
        .A(a[2]),
        .B(b[2]),
        .C_in(cout[1]),
        .S(sum[2]),
        .C_out(cout[2])
    );

endmodule


// Модуль полного сумматора (можно включить в тот же файл)
module full_adder (
    input A, B, C_in,
    output S, C_out
);
    assign S = A ^ B ^ C_in;
    assign C_out = (A & B) | (C_in & (A ^ B));
endmodule
