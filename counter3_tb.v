`timescale 1ns/1ps

module counter3_tb;
    reg clk = 0;
    reg reset = 1;
    reg data = 0;
    wire start_shifting;

    counter3 dut (
        .clk(clk),
        .reset(reset),
        .data(data),
        .start_shifting(start_shifting)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter3_tb.vcd");
        $dumpvars(0, counter3_tb);
    end

    task send_bit(input bit bitval);
        begin
            data <= bitval;
            @(posedge clk);
        end
    endtask

    initial begin
        $display("Starting counter3_tb");

        // release reset
        repeat (2) @(posedge clk);
        reset <= 0;

        // noise bits that should not trigger 1101
        send_bit(1'b0);
        send_bit(1'b0);
        if (start_shifting !== 1'b0) $fatal(1, "start_shifting asserted early");

        // apply pattern 1 1 0 1 (pulse start_shifting high)
        send_bit(1'b1);
        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b1);
        @(negedge clk);
        if (start_shifting !== 1'b1) $fatal(1, "start_shifting did not assert on 1101");

        // keep high while reset low, then clear on reset pulse
        send_bit(1'b1);
        send_bit(1'b1);
        if (start_shifting !== 1'b1) $fatal(1, "start_shifting deasserted unexpectedly");

        reset <= 1;
        @(posedge clk);
        reset <= 0;
        @(negedge clk);
        if (start_shifting !== 1'b0) $fatal(1, "start_shifting not cleared by reset");

        $display("counter3_tb passed");
        $finish;
    end
endmodule
