`timescale 1ns / 1ps

module timer_part4_tb;
    reg clk;
    reg reset;
    reg data;
    reg ack;
    wire [3:0] count;
    wire counting;
    wire done;

    timer_part4 dut (
        .clk(clk),
        .reset(reset),
        .data(data),
        .ack(ack),
        .count(count),
        .counting(counting),
        .done(done)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic send_bit(input reg value);
        begin
            data = value;
            @(posedge clk);
        end
    endtask

    task automatic run_delay(input [3:0] delay_value);
        integer idx;
        integer cycles;
        integer expected_cycles;
        begin
            send_bit(1'b1);
            send_bit(1'b1);
            send_bit(1'b0);
            send_bit(1'b1);

            for (idx = 3; idx >= 0; idx = idx - 1) begin
                send_bit(delay_value[idx]);
            end

            data = 1'b0;
            @(posedge clk);
            #1;

            if (count !== delay_value) begin
                $display("Delay load mismatch at time %0t: expected %0h, got %0h",
                         $time, delay_value, count);
                $fatal;
            end

            if (!counting) begin
                $display("Counting signal did not assert as expected at time %0t", $time);
                $fatal;
            end

            expected_cycles = (delay_value + 5'd1) * 1000;
            cycles = 1;

            while (!done) begin
                @(posedge clk);
                if (counting) begin
                    cycles = cycles + 1;
                end
            end

            if (cycles !== expected_cycles) begin
                $display("Unexpected counting length for delay %0h: got %0d cycles, expected %0d",
                         delay_value, cycles, expected_cycles);
                $fatal;
            end

            if (count !== 4'd0) begin
                $display("Count register not zero after countdown: %0h at time %0t",
                         count, $time);
                $fatal;
            end
        end
    endtask

    task automatic perform_ack;
        begin
            @(posedge clk);
            ack = 1'b1;
            @(posedge clk);
            ack = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("timer_part4_wave_tb.vcd");
        $dumpvars(0, timer_part4_tb);

        reset = 1'b1;
        data  = 1'b0;
        ack   = 1'b0;

        repeat (3) @(posedge clk);
        reset = 1'b0;

        run_delay(4'd0);

        if (!done) begin
            $display("Done signal did not assert after zero delay countdown");
            $fatal;
        end

        repeat (3) begin
            @(posedge clk);
            if (!done) begin
                $display("Done signal dropped before ack");
                $fatal;
            end
        end

        perform_ack();
        @(posedge clk);
        if (done) begin
            $display("Done signal stayed high after ack");
            $fatal;
        end

        run_delay(4'd3);

        if (!done) begin
            $display("Done signal did not assert after delay=3 countdown");
            $fatal;
        end

        perform_ack();
        @(posedge clk);

        if (done) begin
            $display("Done signal stayed high after second ack");
            $fatal;
        end

        #50;
        $display("timer_part4_tb completed successfully");
        $finish;
    end
endmodule
