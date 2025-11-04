`timescale 1ns / 1ps

module timer_part1_tb;
    reg clk;
    reg reset;
    wire [9:0] q;

    timer_part1 dut (
        .clk(clk),
        .reset(reset),
        .q(q)
    );

    reg [9:0] expected;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("timer_part1_wave_tb.vcd");
        $dumpvars(0, timer_part1_tb);

        reset = 1'b1;
        expected = 10'd0;

        #12 reset = 1'b0;
        repeat (1205) @(posedge clk);

        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
        repeat (12) @(posedge clk);

        #20 $finish;
    end

    always @(posedge clk) begin
        if (reset) begin
            expected <= 10'd0;
        end else if (expected == 10'd999) begin
            expected <= 10'd0;
        end else begin
            expected <= expected + 10'd1;
        end

        if (q !== expected) begin
            $display("Mismatch at time %0t: reset=%0b q=%0d expected=%0d",
                     $time, reset, q, expected);
            $fatal;
        end
    end
endmodule
