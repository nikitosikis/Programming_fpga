`timescale 1ns/1ps

module counter1_tb;
    reg clk = 0;
    reg reset = 1;
    wire [9:0] count;

    // DUT
    counter1 dut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter1_tb.vcd");
        $dumpvars(0, counter1_tb);
    end

    initial begin
        $display("Starting counter1_tb");

        // hold reset for a couple of cycles
        repeat (2) @(posedge clk);
        reset <= 0;

        // walk up through the end of the range (990..999)
        repeat (991) @(posedge clk);
        if (count !== 10'd990) $fatal(1, "Expected count=990, got %0d", count);
        repeat (9) @(posedge clk);
        if (count !== 10'd999) $fatal(1, "Expected count=999, got %0d", count);

        // wrap to 0,1,2
        @(posedge clk);
        if (count !== 10'd0) $fatal(1, "Expected wrap to 0, got %0d", count);
        @(posedge clk);
        if (count !== 10'd1) $fatal(1, "Expected count=1, got %0d", count);
        @(posedge clk);
        if (count !== 10'd2) $fatal(1, "Expected count=2, got %0d", count);

        // pulse reset and verify restart at 0 then continue
        reset <= 1;
        repeat (2) @(posedge clk); // hold reset high
        #1;
        if (count !== 10'd0) $fatal(1, "Expected count=0 during reset pulse, got %0d", count);
        reset <= 0;
        @(posedge clk); // first count after reset release
        #1;
        if (count !== 10'd1) $fatal(1, "Expected count=1 after reset, got %0d", count);

        $display("counter1_tb passed");
        $finish;
    end
endmodule
