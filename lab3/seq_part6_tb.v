`timescale 1ns / 1ps

module seq_part6_tb;
    reg clk;
    reg a;
    reg b;
    wire q;
    wire state;

    seq_part6 dut (
        .clk(clk),
        .a(a),
        .b(b),
        .q(q),
        .state(state)
    );

    reg expected_state;
    reg expected_q;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("seq_part6_wave_tb.vcd");
        $dumpvars(0, seq_part6_tb);

        a = 0;
        b = 0;
        expected_state = 0;
        expected_q = 0;

        #45 a = 1;
        #20 b = 1;
        #15 b = 0;
        #20 a = 0;
        #20 a = 1;
        #20 a = 0;
        #15 b = 1;
        #20 b = 0;
        #10 $finish;
    end

    always @(posedge clk) begin
        expected_q     <= expected_state ? b : a;
        expected_state <= expected_state ? a : b;

        if (q !== expected_q) begin
            $display("Mismatch q at time %0t: a=%0b b=%0b q=%0b expected=%0b",
                     $time, a, b, q, expected_q);
            $fatal;
        end
        if (state !== expected_state) begin
            $display("Mismatch state at time %0t: a=%0b b=%0b state=%0b expected=%0b",
                     $time, a, b, state, expected_state);
            $fatal;
        end
    end
endmodule
