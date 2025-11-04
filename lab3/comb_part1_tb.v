`timescale 1ns / 1ps

module comb_part1_tb;
    reg a, b, c, d;
    wire q;

    comb_part1 dut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .q(q)
    );

    wire expected = (a | b) & (c | d);

    integer i;

    initial begin
        $dumpfile("comb_part1_wave_tb.vcd");
        $dumpvars(0, comb_part1_tb);

        a = 0; b = 0; c = 0; d = 0;
        repeat (2) begin
            for (i = 0; i < 16; i = i + 1) begin
                {a, b, c, d} = i[3:0];
                #5;
            end
        end

        #10 $finish;
    end

    always @* begin
        if (q !== expected) begin
            $display("Mismatch at time %0t: a=%0b b=%0b c=%0b d=%0b -> q=%0b expected=%0b",
                     $time, a, b, c, d, q, expected);
            $fatal;
        end
    end
endmodule
