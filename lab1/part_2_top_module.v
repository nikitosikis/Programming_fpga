
module part_2_top_module (input [7:0]d, input [1:0]sel, input clk, output reg [7:0]q);

    wire [7:0] q1, q2, q3;  // Выходы трёх триггеров
    
    // Три последовательных 8-битных триггера
    my_dff8 dff1 (
        .clk(clk),
        .d(d),
        .q(q1)
    );
    
    my_dff8 dff2 (
        .clk(clk),
        .d(q1),
        .q(q2)
    );
    
    my_dff8 dff3 (
        .clk(clk),
        .d(q2),
        .q(q3)
    );
    
    // Мультиплексор 4→1 для выбора выхода
    always @(*) begin
        case (sel)
            2'b00: q = d;     // Прямой вход
            2'b01: q = q1;    // Выход после 1-го триггера
            2'b10: q = q2;    // Выход после 2-го триггера
            2'b11: q = q3;    // Выход после 3-го триггера
        endcase
    end

endmodule



   


// Модуль 8-битного D-триггера
module my_dff8 (
    input clk,
    input [7:0] d,
    output reg [7:0] q
);
    always @(posedge clk) begin
        q <= d;
    end
endmodule