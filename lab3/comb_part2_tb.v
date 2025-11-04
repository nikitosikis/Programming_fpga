`timescale 1ns / 1ps

module comb_part2_tb;
    reg a, b, c, d;
    wire q;

    comb_part2 dut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .q(q)
    );

    wire expected = b | c;
    integer i;

    initial begin
        $dumpfile("comb_part2_wave_tb.vcd");
        $dumpvars(0, comb_part2_tb);

        for (i = 0; i < 16; i = i + 1) begin
            {a, b, c, d} = i[3:0];
            #10;
            if (q !== expected) begin
                $display("Mismatch at time %0t: a=%0b b=%0b c=%0b d=%0b -> q=%0b expected=%0b",
                         $time, a, b, c, d, q, expected);
                $fatal;
            end
        end
        #10 $finish;
    end
endmodule
