`timescale 1ns / 1ps

module seq_part4_tb;
    reg clk;
    reg a;
    wire p, q;

    seq_part4 dut (
        .clk(clk),
        .a(a),
        .p(p),
        .q(q)
    );

    reg expected_p, expected_q;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        a = 0;
        expected_p = 0;
        expected_q = 0;

        $dumpfile("seq_part4_wave_tb.vcd");
        $dumpvars(0, seq_part4_tb);

        #12 a = 1;
        #15 a = 0;
        #10 a = 1;
        #10 a = 0;
        #20 a = 1;
        #15 a = 0;
        #25 a = 1;
        #20 a = 0;

        #30 $finish;
    end

    always @(posedge clk) begin
        expected_p <= a;
        expected_q <= expected_p;
        if (p !== expected_p) begin
            $display("Mismatch p at time %0t: a=%0b p=%0b expected=%0b", $time, a, p, expected_p);
            $fatal;
        end
        if (q !== expected_q) begin
            $display("Mismatch q at time %0t: a=%0b q=%0b expected=%0b", $time, a, q, expected_q);
            $fatal;
        end
    end
endmodule
