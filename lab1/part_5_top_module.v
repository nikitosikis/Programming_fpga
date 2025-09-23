module part_5_top_module (
    input [31:0] a,
    input [31:0] b,
    input sub,           // 0 - сложение, 1 - вычитание
    output [31:0] sum
);
    
    wire [31:0] b_modified;
    wire carry_in;
    wire carry_out;
    
    // Преобразование операнда b для операции вычитания
    // Если sub=1, то инвертируем b и устанавливаем cin=1 (b_modified = ~b + 1)
    assign b_modified = sub ? ~b : b;
    assign carry_in = sub;  // Для вычитания: cin=1 (дополнение до 2)
    
    // 32-битный сумматор
    add32 adder (
        .a(a),
        .b(b_modified),
        .cin(carry_in),
        .sum(sum),
        .cout(carry_out)
    );

endmodule

// 32-битный сумматор из предыдущей части
module add32 (
    input [31:0] a,
    input [31:0] b,
    input cin,
    output [31:0] sum,
    output cout
);
    
    wire [3:0] carry;
    
    // Группа 0: биты 7:0
    assign {carry[0], sum[7:0]} = a[7:0] + b[7:0] + cin;
    
    // Группа 1: биты 15:8  
    assign {carry[1], sum[15:8]} = a[15:8] + b[15:8] + carry[0];
    
    // Группа 2: биты 23:16
    assign {carry[2], sum[23:16]} = a[23:16] + b[23:16] + carry[1];
    
    // Группа 3: биты 31:24
    assign {carry[3], sum[31:24]} = a[31:24] + b[31:24] + carry[2];
    
    assign cout = carry[3];

endmodule