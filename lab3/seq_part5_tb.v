`timescale 1ns / 1ps

module seq_part5_tb;
    reg clk;
    reg a;
    wire [3:0] q;

    seq_part5 dut (
        .clk(clk),
        .a(a),
        .q(q)
    );

    reg [3:0] expected;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("seq_part5_wave_tb.vcd");
        $dumpvars(0, seq_part5_tb);

        a = 1'b1;
        expected = 4'd4;

        #40 a = 1'b0;
        #120 a = 1'b1;
        #40 a = 1'b0;

        #80 $finish;
    end

    always @(posedge clk) begin
        if (a) begin
            expected <= 4'd4;
        end else begin
            if (expected == 4'd6) begin
                expected <= 4'd0;
            end else begin
                expected <= expected + 4'd1;
            end
        end

        if (q !== expected) begin
            $display("Mismatch at time %0t: a=%0b q=%0d expected=%0d", $time, a, q, expected);
            $fatal;
        end
    end
endmodule
