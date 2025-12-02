`timescale 1ns/1ps

module counter2_tb;
    reg clk = 0;
    reg shift_ena = 0;
    reg count_ena = 0;
    reg data = 0;
    reg reset = 1;
    wire [3:0] q;

    counter2 dut (
        .clk(clk),
        .shift_ena(shift_ena),
        .count_ena(count_ena),
        .data(data),
        .reset(reset),
        .q(q)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter2_tb.vcd");
        $dumpvars(0, counter2_tb);
    end

    initial begin
        $display("Starting counter2_tb");

        // reset
        repeat (2) @(posedge clk);
        reset <= 0;

        // SHIFT phase to match 0 -> 1 -> 2 -> 4 -> 9
        shift_ena <= 1;
        data <= 0; @(posedge clk); #1; if (q !== 4'd0)  $fatal(1, "Step 0 expected 0, got %0d", q);
        data <= 1; @(posedge clk); #1; if (q !== 4'd1)  $fatal(1, "Step 1 expected 1, got %0d", q);
        data <= 0; @(posedge clk); #1; if (q !== 4'd2)  $fatal(1, "Step 2 expected 2, got %0d", q);
        data <= 0; @(posedge clk); #1; if (q !== 4'd4)  $fatal(1, "Step 3 expected 4, got %0d", q);
        data <= 1; @(posedge clk); #1; if (q !== 4'd9)  $fatal(1, "Step 4 expected 9, got %0d", q);
        shift_ena <= 0;

        // COUNT phase: 9,8,7,6,5,4
        count_ena <= 1;
        @(posedge clk); #1; if (q !== 4'd8) $fatal(1, "Count expected 8, got %0d", q);
        @(posedge clk); #1; if (q !== 4'd7) $fatal(1, "Count expected 7, got %0d", q);
        @(posedge clk); #1; if (q !== 4'd6) $fatal(1, "Count expected 6, got %0d", q);
        @(posedge clk); #1; if (q !== 4'd5) $fatal(1, "Count expected 5, got %0d", q);
        @(posedge clk); #1; if (q !== 4'd4) $fatal(1, "Count expected 4, got %0d", q);
        count_ena <= 0;

        $display("counter2_tb passed");
        $finish;
    end
endmodule
