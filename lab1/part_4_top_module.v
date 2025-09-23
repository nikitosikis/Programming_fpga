module part_4_top_module (
    input [31:0] a,
    input [31:0] b,
    input cin,
    output [31:0] sum,
    output cout
);
    
    wire [3:0] carry; // Переносы между группами
    
    // Группа 0: биты 7:0
    add16 group0 (
        .a({8'b0, a[7:0]}),    // Расширяем до 16 бит
        .b({8'b0, b[7:0]}),
        .cin(cin),
        .sum({carry[0], sum[7:0]}), // Используем старший бит как перенос
        .cout() // Не используется
    );
    
    // Группа 1: биты 15:8  
    add16 group1 (
        .a({8'b0, a[15:8]}),
        .b({8'b0, b[15:8]}),
        .cin(carry[0]),
        .sum({carry[1], sum[15:8]}),
        .cout()
    );
    
    // Группа 2: биты 23:16
    add16 group2 (
        .a({8'b0, a[23:16]}),
        .b({8'b0, b[23:16]}),
        .cin(carry[1]),
        .sum({carry[2], sum[23:16]}),
        .cout()
    );
    
    // Группа 3: биты 31:24
    add16 group3 (
        .a({8'b0, a[31:24]}),
        .b({8'b0, b[31:24]}),
        .cin(carry[2]),
        .sum({carry[3], sum[31:24]}),
        .cout()
    );
    
    assign cout = carry[3]; // Итоговый перенос

endmodule

// 16-битный сумматор
module add16 (
    input [15:0] a,
    input [15:0] b,
    input cin,
    output [15:0] sum,
    output cout
);
    assign {cout, sum} = a + b + cin;
endmodule