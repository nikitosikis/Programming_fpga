module part_3_top_module (
    input [31:0] a,
    input [31:0] b,
    input cin,
    output [31:0] sum
);
    
    wire cout_lower; // Перенос из младшего 16-битного сумматора
    
    // Младшие 16 бит (биты 15:0)
    add16 lower16 (
        .a(a[15:0]),
        .b(b[15:0]),
        .cin(cin),
        .sum(sum[15:0]),
        .cout(cout_lower)
    );
    
    // Старшие 16 бит (биты 31:16)
    add16 upper16 (
        .a(a[31:16]),
        .b(b[31:16]),
        .cin(cout_lower),
        .sum(sum[31:16]),
        .cout() // Выходной перенос не используется
    );

endmodule

// 16-битный сумматор (уже определен в системе)
module add16 (
    input [15:0] a,
    input [15:0] b,
    input cin,
    output [15:0] sum,
    output cout
);
    assign {cout, sum} = a + b + cin;
endmodule